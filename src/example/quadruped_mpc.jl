include(joinpath(@__DIR__, "..", "dynamics", "quadruped", "visuals.jl"))
T = Float64
vis = Visualizer()
open(vis)

# get hopper model
model = get_model("quadruped")
nq = model.dim.q
nu = model.dim.u
nc = model.dim.c
nb = model.dim.b
nd = nq + nc + nb
nr = nq + nu + nc + nb + nd

# get trajectory
ref_traj = get_trajectory("quadruped", "gait1", load_type=:split_traj)
H = ref_traj.H
h = ref_traj.h
κ = 1.0e-4

ref_traj0 = deepcopy(ref_traj)
n_opts0 = NewtonOptions(r_tol=3e-4, κ_init=κ, κ_tol=2κ, solver_inner_iter=5)
m_opts0 = MPCOptions{T}(
            N_sample=2,
            M=100,
            H_mpc=10,
            κ=κ,
            κ_sim=1e-8,
            r_tol_sim=1e-8,
            open_loop_mpc=false,
            w_amp=0.0*[-0.10, -0.90],
            ip_max_time=0.1,
            live_plotting=false)
cost0 = CostFunction(H, model.dim,
    q = [Diagonal(1e-2 * [0.02,0.02,1,.15,.15,.15,.15,.15,.15,.15,.15,]) for t = 1:m_opts0.H_mpc],
    u = [Diagonal(3e-2 * ones(nu)) for t = 1:m_opts0.H_mpc],
    γ = [Diagonal(1.0e-100 * ones(nc)) for t = 1:m_opts0.H_mpc],
    b = [Diagonal(1.0e-100 * ones(nb)) for t = 1:m_opts0.H_mpc])
core0 = Newton(m_opts0.H_mpc, h, model, cost=cost0, opts=n_opts0)
mpc0 = MPC(model, ref_traj0, m_opts=m_opts0)
@time dummy_mpc(model, core0, mpc0, verbose=true)
# @profiler dummy_mpc(model, core0, mpc0, verbose=true)

# mpc0.impl.ip[1].solver

# mpc0.impl
# lin0 = mpc0.impl.lin[1]
# r  = RLin(model, lin0.z, lin0.θ, lin0.r, lin0.rz, lin0.rθ)
# rz = RZLin(model, lin0.rz)
# rθ = RθLin(model, lin0.rθ)
#
#
# 2.9/(100*h)


plt = plot(layout=(2,1), legend=false)
plot!(plt[1,1], hcat(Vector.(vcat([fill(ref_traj.q[i], m_opts0.N_sample) for i=1:H]...))...)',
    color=:red, linewidth=3.0)
plot!(plt[1,1], hcat(Vector.(mpc0.q_sim)...)', color=:blue, linewidth=1.0)
plot!(plt[2,1], hcat(Vector.(vcat([fill(ref_traj.u[i][1:nu], m_opts0.N_sample) for i=1:H]...))...)',
    color=:red, linewidth=3.0)
plot!(plt[2,1], hcat(Vector.([u[1:nu] for u in mpc0.u_sim]*m_opts0.N_sample)...)', color=:blue, linewidth=1.0)

visualize!(vis, model, mpc0.q_sim[1:10:end], Δt=10*h/m_opts0.N_sample, name=:mpc)

filename = "quadruped_mpc_downwind"
MeshCat.convert_frames_to_video(
    "/home/simon/Downloads/$filename.tar",
    "/home/simon/Documents/$filename.mp4", overwrite=true)

convert_video_to_gif(
    "/home/simon/Documents/$filename.mp4",
    "/home/simon/Documents/$filename.gif", overwrite=true)
11/(100*h)
