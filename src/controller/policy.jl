"""
    linearized model-predictive control policy
"""

@with_kw mutable struct LinearizedMPCOptions{T}
	altitude_update::Bool = false
	altitude_impact_threshold::T = 1.0
	altitude_verbose::Bool = false
    ip_max_time::T = 60.0     # maximum time allowed for an InteriorPoint solve
    live_plotting::Bool=false # Use the live plotting tool to debug
end

mutable struct LinearizedMPC <: Policy
	traj
	ref_traj
	im_traj
	stride
	altitude
	κ
	newton
	model
	q0
	N_sample
	cnt
	opts
end

function linearized_mpc_policy(traj, model, cost;
	H_mpc = traj.H,
	N_sample = 1,
	κ_mpc = traj.κ[1],
	n_opts = NewtonOptions(
		r_tol = 3e-4,
		max_iter = 5,
		verbose = false,
		live_plotting = false),
	mpc_opts = LinearizedMPCOptions())

	traj = deepcopy(traj)
	ref_traj = deepcopy(traj)

	im_traj = ImplicitTraj(traj, model, κ = κ_mpc, max_time = mpc_opts.ip_max_time)
	stride = get_stride(model, traj)
	altitude = zeros(model.dim.c)
	newton = Newton(H_mpc, traj.h, model, cost = cost, opts = n_opts)

	LinearizedMPC(traj, ref_traj, im_traj, stride, altitude, κ_mpc, newton, model, copy(ref_traj.q[1]),
		N_sample, N_sample, mpc_opts)
end

function policy(p::LinearizedMPC, x, traj, t)
	# reset
	if t == 1
		p.cnt = p.N_sample
		p.q0 = copy(p.ref_traj.q[1])
		# p.traj = deepcopy(p.ref_traj)
	end

    if p.cnt == p.N_sample
		(p.opts.altitude_update && t > 1) && (update_altitude!(p.altitude, p.model,
									p.traj, t, p.N_sample,
									threshold = p.opts.altitude_impact_threshold,
									verbose = p.opts.altitude_verbose))
		update!(p.im_traj, p.traj, p.model, p.altitude, κ = p.κ)
		newton_solve!(p.newton, p.model, p.im_traj, p.traj,
			verbose = p.newton.opts.verbose, warm_start = t > 1, q0 = copy(p.q0), q1 = copy(x))
		rot_n_stride!(p.traj, p.stride)
		p.q0 .= copy(x)
		p.cnt = 0

		p.opts.live_plotting && live_plotting(p.model, p.traj, traj, p.newton)
    end

    p.cnt += 1

    return p.newton.traj.u[1] / p.N_sample # rescale output
end
