include("model_struct.jl")
include("quadruped_model.jl")
include("code_gen.jl")
include("model_methods.jl")
include("fast_model_methods.jl")

T = Float64

model = deepcopy(quadruped)
# expr_bas = generate_base_expressions(model)
# save_expressions(expr_bas, joinpath(@__DIR__, ".expr/quadruped_base.jld2"), overwrite=true)
instantiate_base!(model, joinpath(@__DIR__, ".expr/quadruped_base.jld2"))

# expr_dyn = generate_dynamics_expressions(model)
# save_expressions(expr_dyn, joinpath(@__DIR__, ".expr/quadruped_dynamics.jld2"), overwrite=true)
instantiate_dynamics!(model, joinpath(@__DIR__, ".expr/quadruped_dynamics.jld2"))

# expr_res = generate_residual_expressions(model)
# save_expressions(expr_res, joinpath(@__DIR__, ".expr/quadruped_residual.jld2"), overwrite=true)
instantiate_residual!(model, joinpath(@__DIR__, ".expr/quadruped_residual.jld2"))


nq = model.dim.q
nu = model.dim.u
nγ = model.dim.γ
nb = model.dim.b
ny = model.dim.y

q0s = rand(SizedVector{nq,T})
q1s = rand(SizedVector{nq,T})
u1s = rand(SizedVector{nu,T})
γ1s = rand(SizedVector{nγ,T})
b1s = rand(SizedVector{nb,T})
q2s = rand(SizedVector{nq,T})
q̇0s = rand(SizedVector{nq,T})

M1s   = rand(SizedMatrix{nq,nq,T})
∇ys   = rand(SizedMatrix{nq,ny,T})
∇q0s  = rand(SizedMatrix{nq,nq,T})
∇q1s  = rand(SizedMatrix{nq,nq,T})
∇u1s  = rand(SizedMatrix{nq,nu,T})
∇γ1s  = rand(SizedMatrix{nq,nγ,T})
∇b1s  = rand(SizedMatrix{nq,nb,T})
∇q2s  = rand(SizedMatrix{nq,nq,T})


M_fast(model, q0s)
B_fast(model, q0s)
N_fast(model, q0s)
P_fast(model, q0s)
C_fast(model, q0s, q̇0s)
dynamics_fast(model, q0s, q1s, u1s, γ1s, b1s, q2s)
∇y_dynamics_fast!(model, ∇ys, q0s, q1s, u1s, γ1s, b1s, q2s)
∇q_1_dynamics_fast!(model, ∇q0s, q0s, q1s, u1s, γ1s, b1s, q2s)
∇q_dynamics_fast!(model,   ∇q1s, q0s, q1s, u1s, γ1s, b1s, q2s)
∇u_dynamics_fast!(model,   ∇u1s, q0s, q1s, u1s, γ1s, b1s, q2s)
∇γ_dynamics_fast!(model,   ∇γ1s, q0s, q1s, u1s, γ1s, b1s, q2s)
∇b_dynamics_fast!(model,   ∇b1s, q0s, q1s, u1s, γ1s, b1s, q2s)
∇q1_dynamics_fast!(model,  ∇q2s, q0s, q1s, u1s, γ1s, b1s, q2s)

∇ys
∇q0s
∇q1s
∇u1s
∇γ1s
∇b1s
∇q2s












function generate_residual_expressions(model::ContactDynamicsModel)
	nq = model.dim.q
	nu = model.dim.u
	nγ = model.dim.γ
	nb = model.dim.b
	# # Declare variables
	# @variables q0[1:nq]
	# @variables q1[1:nq]
	# @variables u1[1:nu]
	# @variables γ1[1:nγ]
	# @variables b1[1:nb]
	# @variables q2[1:nq]
	# @variables dt[1:1]
	#
	# # Dynamics
	# d = dynamics(model,dt[1],q0,q1,u1,γ1,b1,q2)
	# d = ModelingToolkit.simplify.(d)
	# dz  = ModelingToolkit.jacobian(d, [q0; q1; u1; γ1; b1; q2], simplify=true)
	# dq0 = ModelingToolkit.jacobian(d, q0, simplify=true)
	# dq1 = ModelingToolkit.jacobian(d, q1,   simplify=true)
	# du1 = ModelingToolkit.jacobian(d, u1,   simplify=true)
	# dγ1 = ModelingToolkit.jacobian(d, γ1,   simplify=true)
	# db1 = ModelingToolkit.jacobian(d, b1,   simplify=true)
	# dq2 = ModelingToolkit.jacobian(d, q2,  simplify=true)
	#
	# # Build function
	# expr = Dict{Symbol, Expr}()
	# expr[:d]   = build_function(d,   dt, q0, q1, u1, γ1, b1, q2)[1]
	# expr[:dz]  = build_function(dz,  dt, q0, q1, u1, γ1, b1, q2)[2]
	# expr[:dq0] = build_function(dq0, dt, q0, q1, u1, γ1, b1, q2)[2]
	# expr[:dq1] = build_function(dq1, dt, q0, q1, u1, γ1, b1, q2)[2]
	# expr[:du1] = build_function(du1, dt, q0, q1, u1, γ1, b1, q2)[2]
	# expr[:dγ1] = build_function(dγ1, dt, q0, q1, u1, γ1, b1, q2)[2]
	# expr[:db1] = build_function(db1, dt, q0, q1, u1, γ1, b1, q2)[2]
	# expr[:dq2] = build_function(dq2, dt, q0, q1, u1, γ1, b1, q2)[2]
	# return expr
end


model = deepcopy(quadruped)
instantiate_base!(model, joinpath(@__DIR__, ".expr/quadruped_base.jld2"))
instantiate_dynamics!(model, joinpath(@__DIR__, ".expr/quadruped_dynamics.jld2"))

expr_res = generate_residual_expressions(model)
save_expressions(expr_res, joinpath(@__DIR__, ".expr/quadruped_residual.jld2"), overwrite=true)
instantiate_residual!(model, joinpath(@__DIR__, ".expr/quadruped_residual.jld2"))



r(model, zs, θs)
rz!(model, ∇zs, zs, θs)
rθ!(model, ∇θs, zs, θs)
