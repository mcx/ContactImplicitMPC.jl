s = get_simulation("rigidbody", "flat_3D_nc", "flat_nc")

# time
h = 0.01
T = 500

# Rn + quaternion space
rq_space = rn_quaternion_space(num_var(model, env) - 1,
			collect([(1:3)..., (8:num_var(model, env))...]),
			collect([(1:3)..., (7:num_var(model, env)-1)...]),
			collect((4:7)),
			collect((4:6)))

# initial conditions
r0 = [0.0; 0.0; 1.0]
v0 = [7.5; 5.0; 0.0]

quat0 = [1.0; 0.0; 0.0; 0.0]
ω0 = [0.0; 0.0; 0.0]

q0 = SVector{model.dim.q}([r0; quat0])
q1 = SVector{model.dim.q}([r0 + v0 * h; 0.5 * h * L_multiply(quat0) * [sqrt((2.0 / h)^2.0 - ω0' * ω0); ω0]])

@assert norm(q0[4:7]) ≈ 1.0
@assert norm(q1[4:7]) ≈ 1.0

# simulator
sim = ContactControl.simulator(s, q0, q1, h, T,
	space = rq_space,

	ip_opts = ContactControl.InteriorPointOptions(
		r_tol = 1.0e-6, κ_tol = 1.0e-6,
		diff_sol = false,
		solver = :lu_solver),
	sim_opts = ContactControl.SimulatorOptions(warmstart = false))

# simulate
@time status = ContactControl.simulate!(sim)
@test status

include(joinpath(pwd(), "src/dynamics/rigidbody/visuals.jl"))
vis = Visualizer()
render(vis)
open(vis)
visualize!(vis, model, sim.traj.q, Δt = h)

@assert all([norm(q[4:7]) ≈ 1.0 for q in sim.traj.q])
