include("model.jl")
include("code_gen.jl")
include("fast_methods.jl")

################################################################################
# Particle (flat)
################################################################################
dir = joinpath(@__DIR__, "particle")
model = deepcopy(particle)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Particle (quadratic)
################################################################################
dir = joinpath(@__DIR__, "particle")
model = deepcopy(particle_quadratic)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "quadratic/residual.jld2")
path_jac = joinpath(dir, "quadratic/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "quadratic/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Particle (sinusoidal)
################################################################################
dir = joinpath(@__DIR__, "particle")
model = deepcopy(particle_sinusoidal)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "sinusoidal/residual.jld2")
path_jac = joinpath(dir, "sinusoidal/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "sinusoidal/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Particle 2D (flat)
################################################################################
dir = joinpath(@__DIR__, "particle_2D")
model = deepcopy(particle_2D)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Particle 2D (slope)
################################################################################
dir = joinpath(@__DIR__, "particle_2D")
model = deepcopy(particle_2D_slope)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "slope/residual.jld2")
path_jac = joinpath(dir, "slope/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "slope/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Hopper (2D)
################################################################################
dir = joinpath(@__DIR__, "hopper_2D")
model = deepcopy(hopper_2D)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Hopper (2D) vertical hop
################################################################################
dir = joinpath(@__DIR__, "hopper_2D")
model = deepcopy(hopper_2D_vertical)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "vertical/residual.jld2")
path_jac = joinpath(dir, "vertical/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "vertical/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Hopper (2D) (sinusoidal)
################################################################################
dir = joinpath(@__DIR__, "hopper_2D")
model = deepcopy(hopper_2D_sinusoidal)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "sinusoidal/residual.jld2")
path_jac = joinpath(dir, "sinusoidal/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "sinusoidal/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Hopper (2D) (stairs)
################################################################################
dir = joinpath(@__DIR__, "hopper_2D")
model = deepcopy(hopper_2D_stairs)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "stairs/residual.jld2")
path_jac = joinpath(dir, "stairs/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "stairs/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Hopper (3D)
################################################################################
dir = joinpath(@__DIR__, "hopper_3D")
model = deepcopy(hopper_3D)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Hopper (3D) (sinusoidal)
################################################################################
dir = joinpath(@__DIR__, "hopper_3D")
model = deepcopy(hopper_3D_sinusoidal)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "sinusoidal/residual.jld2")
path_jac = joinpath(dir, "sinusoidal/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "sinusoidal/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Quadruped
################################################################################
dir = joinpath(@__DIR__, "quadruped")
model = deepcopy(quadruped)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Quadruped Payload
################################################################################
dir = joinpath(@__DIR__, "quadruped")
model = deepcopy(quadruped_payload)

path_base = joinpath(dir, "dynamics_payload/base.jld2")
path_dyn = joinpath(dir, "dynamics_payload/dynamics.jld2")
path_res = joinpath(dir, "payload/residual.jld2")
path_jac = joinpath(dir, "payload/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "payload/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Quadruped Sinusoidal
################################################################################
dir = joinpath(@__DIR__, "quadruped")
model = deepcopy(quadruped_sinusoidal)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "sinusoidal/residual.jld2")
path_jac = joinpath(dir, "sinusoidal/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "sinusoidal/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Quadruped (Piecewise)
################################################################################
dir = joinpath(@__DIR__, "quadruped")
model = deepcopy(quadruped_piecewise)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "piecewise/residual.jld2")
path_jac = joinpath(dir, "piecewise/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "piecewise/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

################################################################################
# Quadruped (3D)
################################################################################
dir = joinpath(@__DIR__, "quadruped_3D")
model = deepcopy(quadruped_3D)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Quadruped (Linear)
################################################################################
dir = joinpath(@__DIR__, "quadruped")
model = deepcopy(quadruped)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Biped
################################################################################
dir = joinpath(@__DIR__, "biped")
model = deepcopy(biped)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Biped (sinusoidal)
################################################################################
dir = joinpath(@__DIR__, "biped")
model = deepcopy(biped_sinusoidal)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "sinusoidal/residual.jld2")
path_jac = joinpath(dir, "sinusoidal/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "sinusoidal/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Biped (5-link)
################################################################################
dir = joinpath(@__DIR__, "biped5")
model = deepcopy(biped5)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Flamingo (flat)
################################################################################
dir = joinpath(@__DIR__, "flamingo")
model = deepcopy(flamingo)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Flamingo (sinusoidal)
################################################################################
dir = joinpath(@__DIR__, "flamingo")
model = deepcopy(flamingo_sinusoidal)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "sinusoidal/residual.jld2")
path_jac = joinpath(dir, "sinusoidal/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "sinusoidal/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# Flamingo (smooth slope)
################################################################################
dir = joinpath(@__DIR__, "flamingo")
model = deepcopy(flamingo_smooth_slope)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "smooth_slope/residual.jld2")
path_jac = joinpath(dir, "smooth_slope/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "smooth_slope/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
@load path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# PushBot
################################################################################
dir = joinpath(@__DIR__, "pushbot")
model = deepcopy(pushbot)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)

################################################################################
# PlanarPush
################################################################################
dir = joinpath(@__DIR__, "planarpush")
model = deepcopy(planarpush)

path_base = joinpath(dir, "dynamics/base.jld2")
path_dyn = joinpath(dir, "dynamics/dynamics.jld2")
path_res = joinpath(dir, "flat/residual.jld2")
path_jac = joinpath(dir, "flat/sparse_jacobians.jld2")
path_linearized = joinpath(dir, "flat/linearized.jld2")

instantiate_base!(model, path_base)
instantiate_dynamics!(model, path_dyn)

expr_res, rz_sp, rθ_sp = generate_residual_expressions(model)
save_expressions(expr_res, path_res, overwrite=true)
@save path_jac rz_sp rθ_sp
instantiate_residual!(model, path_res)

expr_linearized = generate_linearized_expressions(model)
save_expressions(expr_linearized, path_linearized, overwrite=true)
instantiate_linearized!(model, path_linearized)
