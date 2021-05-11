@with_kw struct SimulatorOptions{T}
    warmstart::Bool = true
    z_warmstart::T = 0.001
    κ_warmstart::T = 0.001
end

struct Simulator{T}
    model::ContactDynamicsModel

    traj::ContactTraj
    deriv_traj::ContactDerivTraj

    p::Policy
    uL::Vector{T}
    uU::Vector{T}

    d::Disturbances

    ip::InteriorPoint{T}

    opts::SimulatorOptions{T}
end

function simulator(model, q0::SVector, q1::SVector, h::S, H::Int;
    p = no_policy(model),
    uL = -Inf * ones(model.dim.u),
    uU = Inf * ones(model.dim.u),
    d = no_disturbances(model),
    r! = model.res.r!,
    rz! = model.res.rz!,
    rθ! = model.res.rθ!,
    rz = model.spa.rz_sp,
    rθ = model.spa.rθ_sp,
    ip_opts = InteriorPointOptions{S}(),
    sim_opts = SimulatorOptions{S}()) where S

    # initialize trajectories
    traj = contact_trajectory(H, h, model)
    traj.q[1] .= q0
    traj.q[2] .= q1
    traj.u[1] .= control_saturation(policy(p, traj.q[2], traj, 1), uL, uU)
    traj.w[1] .= disturbances(d, traj.q[2], 1)

    # initialize interior point solver (for pre-factorization)
    z = zeros(num_var(model))
    θ = zeros(num_data(model))
    z_initialize!(z, model, traj.q[2])
    θ_initialize!(θ, model, traj.q[1], traj.q[2], traj.u[1], traj.w[1], model.μ_world, h)

    ip = interior_point(z, θ,
        idx_ineq = inequality_indices(model),
        r! = r!,
        rz! = rz!,
        rθ! = rθ!,
        rz = rz,
        rθ = rθ,
        opts = ip_opts)

    # allocate gradients
    traj_deriv = contact_derivative_trajectory(ip.δz, H, model)

    Simulator(
        model,
        traj,
        traj_deriv,
        p, uL, uU,
        d,
        ip,
        sim_opts)
end


function step!(sim::Simulator, t)
    # unpack
    model = sim.model
    q = sim.traj.q
    u = sim.traj.u
    w = sim.traj.w
    h = sim.traj.h
    ip = sim.ip
    z = ip.z
    θ = ip.θ

    # policy
    u[t] = control_saturation(policy(sim.p, q[t+1], sim.traj, t), sim.uL, sim.uU)

    # disturbances
    w[t] = disturbances(sim.d, q[t], t)

    # initialize
    if sim.opts.warmstart
        z .+= sim.opts.z_warmstart * rand(ip.num_var)
        sim.ip.opts.κ_init = sim.opts.κ_warmstart
    else
        z_initialize!(z, model, q[t+1])
    end
    θ_initialize!(θ, model, q[t], q[t+1], u[t], w[t], model.μ_world, h)

    # solve
    status = interior_point!(ip)

    if status
        # parse result
        q2, γ, b, _ = unpack_z(model, z)
        sim.traj.z[t] = z
        sim.traj.θ[t] = θ
        sim.traj.q[t+2] = q2
        sim.traj.γ[t] = γ
        sim.traj.b[t] = b
        sim.traj.κ[1] = ip.κ[1]

        if sim.ip.opts.diff_sol
            sim.deriv_traj.dq2dq0[t] = sim.deriv_traj.vqq
            sim.deriv_traj.dq2dq1[t] = sim.deriv_traj.vqqq
            sim.deriv_traj.dq2du[t] = sim.deriv_traj.vqu
            sim.deriv_traj.dγdq0[t] = sim.deriv_traj.vγq
            sim.deriv_traj.dγdq1[t] = sim.deriv_traj.vγqq
            sim.deriv_traj.dγdu[t] = sim.deriv_traj.vγu
            sim.deriv_traj.dbdq0[t] = sim.deriv_traj.vbq
            sim.deriv_traj.dbdq1[t] = sim.deriv_traj.vbqq
            sim.deriv_traj.dbdu[t] = sim.deriv_traj.vbu
        end
    end

    return status
end

"""
    simulate
    - solves 1-step feasibility problem for H time steps
    - initial configurations: q0, q1
    - time step: h
"""
function simulate!(sim::Simulator; verbose = false)

    verbose && println("\nSimulation")

    # initialize configurations for first step
    z_initialize!(sim.ip.z, sim.model, sim.traj.q[2])

    status = true

    # simulate
    for t = 1:sim.traj.H
        verbose && println("t = $t / $(sim.traj.H)")
        status = step!(sim, t)
        !status && (@error "failed step (t = $t)")
    end

    return status
end
