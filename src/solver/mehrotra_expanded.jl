# interior-point solver options
@with_kw mutable struct Mehrotra12Options{T} <: AbstractIPOptions
    r_tol::T = 1.0e-5
    κ_tol::T = 1.0e-5
    max_iter_inner::Int = 100 #TODO rename
    max_time::T = 60.0
    diff_sol::Bool = false
    reg::Bool = false
    ϵ_min = 0.05 # ∈ [0.005, 0.25]
        # smaller -> faster
        # larger  -> slower, more robust
    κ_reg = 1e-3 # bilinear constraint violation level at which regularization is triggered [1e-3, 1e-4]
    γ_reg = 1e-1 # regularization scaling parameters ∈ [0, 0.1]:
        # 0   -> faster & ill-conditioned
        # 0.1 -> slower & better-conditioned
    solver::Symbol = :lu_solver
    verbose::Bool = false


    res_norm::Real = Inf #useless
    κ_init::T = 1.0   # useless
    reg_pr_init = 0.0 #useless
    reg_du_init = 0.0 #useless
end

mutable struct Mehrotra12{T,nx,ny,R,RZ,Rθ} <: AbstractIPSolver
    s::Space
    methods::ResidualMethods
    z::Vector{T}                 # current point
    Δaff::Vector{T}              # affine search direction
    Δ::Vector{T}                 # corrector search direction
    r::R                            # residual
    r̄::R #useless                            # candidate residual
    rz::RZ                           # residual Jacobian wrt z
    rθ::Rθ                           # residual Jacobian wrt θ
    idx_ineq::Vector{Int}        # indices for inequality constraints
    idx_soc::Vector{Vector{Int}} # indices for second-order cone constraints
    idx_pr::Vector{Int}          # indices for primal variables
    idx_du::Vector{Int}          # indices for dual variables
    δz::Matrix{T}                # solution gradients (this is always dense)
    δzs::Matrix{T}               # solution gradients (in optimization space; δz = δzs for Euclidean)
    θ::Vector{T}                 # problem data
    κ::Vector{T}                 # barrier parameter
    num_var::Int
    num_data::Int
    solver::LinearSolver
    v_pr # view
    v_du # view
    z_y1 # view into z corresponding to the first set of variables in the bilinear constraints y1 .* y2 = 0 (/!\this is z space)
    z_y2 # view into z corresponding to the second set of variables in the bilinear constraints y1 .* y2 = 0 (/!\this is z space)
    Δaff_y1 # view into Δaff corresponding to the first set of variables in the bilinear constraints y1 .* y2 = 0 (/!\this is Δ space)
    Δaff_y2 # view into Δaff corresponding to the second set of variables in the bilinear constraints y1 .* y2 = 0 (/!\this is Δ space)
    Δ_y1 # view into Δ corresponding to the first set of variables in the bilinear constraints y1 .* y2 = 0 (/!\this is Δ space)
    Δ_y2 # view into Δ corresponding to the second set of variables in the bilinear constraints y1 .* y2 = 0 (/!\this is Δ space)
    ix::SVector{nx,Int}
    iy1::SVector{ny,Int}
    iy2::SVector{ny,Int}
    idyn::SVector{nx,Int}
    irst::SVector{ny,Int}
    ibil::SVector{ny,Int}
    reg_pr #useless
    reg_du #useless
    reg_val::T
    τ::T
    σ::T
    μ::T
    αaff::T
    α::T
    iterations::Int
    opts::Mehrotra12Options
end

function mehrotra(z::AbstractVector{T}, θ::AbstractVector{T};
        s = Euclidean(length(z)),
        num_var = length(z),
        num_data = length(θ),
        idx_ineq = collect(1:0),
        idx_soc = Vector{Int}[],
        idx_pr = collect(1:s.n),
        idx_du = collect(1:0),
        ix = collect(1:0),
        iy1 = collect(1:0),
        iy2 = collect(1:0),
        idyn = collect(1:0),
        irst = collect(1:0),
        ibil = collect(1:0),
        r! = r!, rm! = rm!, rz! = rz!, rθ! = rθ!,
        r  = zeros(s.n),
        rz = spzeros(s.n, s.n),
        rθ = spzeros(s.n, num_data),
        reg_pr = [0.0], reg_du = [0.0],
        v_pr = view(rz, CartesianIndex.(idx_pr, idx_pr)),
        v_du = view(rz, CartesianIndex.(idx_du, idx_du)),
        opts::Mehrotra12Options = Mehrotra12Options()) where T

    rz!(rz, z, θ) # compute Jacobian for pre-factorization

    # Search direction
    Δaff = zeros(s.n)
    Δ = zeros(s.n)

    # Indices
    nx = length(ix)
    ny = length(iy1)
    ix = SVector{nx, Int}(ix)
    iy1 = SVector{ny, Int}(iy1)
    iy2 = SVector{ny, Int}(iy2)
    idyn = SVector{nx, Int}(idyn)
    irst = SVector{ny, Int}(irst)
    ibil = SVector{ny, Int}(ibil)
    ny == 0 && @warn "ny == 0, we will get NaNs during the Mehrotra12 solve."

    # Views
    z_y1 = view(z, iy1)
    z_y2 = view(z, iy2)
    Δaff_y1 = view(Δaff, iy1) # TODO this should be in Δ space
    Δaff_y2 = view(Δaff, iy2) # TODO this should be in Δ space
    Δ_y1 = view(Δ, iy1) # TODO this should be in Δ space
    Δ_y2 = view(Δ, iy2) # TODO this should be in Δ space

    Ts = typeof.((r, rz, rθ))
    Mehrotra12{T,nx,ny,Ts...}(
        s,
        ResidualMethods(r!, rm!, rz!, rθ!),
        z,
        Δaff,
        Δ,
        r,
        deepcopy(r), #useless
        rz,
        rθ,
        idx_ineq,
        idx_soc,
        idx_pr,
        idx_du,
        zeros(length(z), num_data),
        zeros(s.n, num_data),
        θ,
        zeros(1),
        num_var,
        num_data,
        eval(opts.solver)(rz),
        v_pr,
        v_du,
        z_y1,
        z_y2,
        Δaff_y1,
        Δaff_y2,
        Δ_y1,
        Δ_y2,
        ix,
        iy1,
        iy2,
        idyn,
        irst,
        ibil,
        reg_pr, reg_du,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0,
        opts,
        )
end

# interior point solver

function interior_point_solve!(ip::Mehrotra12{T}, z::AbstractVector{T}, θ::AbstractVector{T}) where T
    ip.z .= z
    ip.θ .= θ
    interior_point_solve!(ip)
end

function interior_point_solve!(ip::Mehrotra12{T,nx,ny,R,RZ,Rθ}) where {T,nx,ny,R,RZ,Rθ}

    # space
    s = ip.s

    # options
    opts = ip.opts
    r_tol = opts.r_tol
    κ_tol = opts.κ_tol
    max_iter_inner = opts.max_iter_inner
    max_time = opts.max_time
    diff_sol = opts.diff_sol
    res_norm = opts.res_norm
    reg = opts.reg
    ϵ_min = opts.ϵ_min
    κ_reg = opts.κ_reg
    γ_reg = opts.γ_reg
    verbose = opts.verbose

    # unpack pre-allocated data
    z = ip.z
    Δaff = ip.Δaff
    Δ = ip.Δ
    r = ip.r
    rz = ip.rz
    idx_ineq = ip.idx_ineq
    idx_soc = ip.idx_soc
    θ = ip.θ
    κ = ip.κ
    v_pr = ip.v_pr
    v_du = ip.v_du
    z_y1 = ip.z_y1
    z_y2 = ip.z_y2
    Δaff_y1 = ip.Δaff_y1
    Δaff_y2 = ip.Δaff_y2
    Δ_y1 = ip.Δ_y1
    Δ_y2 = ip.Δ_y2
    ix = ip.ix
    iy1 = ip.iy1
    iy2 = ip.iy2
    reg_pr = ip.reg_pr
    reg_du = ip.reg_du
    solver = ip.solver

    # Initialization
    ip.iterations = 0
    ip.reg_val = 0.0
    comp = false

    # initialize regularization
    reg_pr[1] = opts.reg_pr_init
    reg_du[1] = opts.reg_du_init

    # compute residual, residual Jacobian
    ip.methods.rm!(r, z, 0.0 .* Δaff, θ, 0.0) # here we set κ = 0, Δ = 0
    comp && println("**** rl:", scn(norm(r, res_norm), digits=4))

    least_squares!(ip, z, θ, r, rz) # this one uses indices from global scope in nonlinear mode
    z .= initial_state!(z, ix, iy1, iy2; comp = comp)

    ip.methods.rm!(r, z, 0.0 .* Δaff, θ, 0.0) # here we set κ = 0, Δ = 0
    comp && println("**** rinit:", scn(norm(r, res_norm), digits=4))

    r_vio = residual_violation(ip, r)
    κ_vio = bilinear_violation(ip, r)
    elapsed_time = 0.0

    for j = 1:max_iter_inner
        elapsed_time >= max_time && break
        elapsed_time += @elapsed begin
            # check for converged residual
            if (r_vio < r_tol) && (κ_vio < κ_tol)
                break
            end
            ip.iterations += 1
            comp && println("************************** ITERATION :", ip.iterations)

            # Compute regularization level
            κ_vio = bilinear_violation(ip, r)
            ip.reg_val = κ_vio < κ_reg ? κ_vio * γ_reg : 0.0

            # compute residual Jacobian
            rz!(ip, rz, z, θ, reg = ip.reg_val)

            # regularize (fixed, TODO: adaptive)
            reg && regularize!(v_pr, v_du, reg_pr[1], reg_du[1])

            # compute affine search direction
            linear_solve!(solver, Δaff, rz, r, reg = ip.reg_val)
            # @show scn(norm(rz * Δaff - r, Inf))

            αaff = step_length(z, Δaff, iy1, iy2; τ = 1.0)
            # println("αaff: ", scn(αaff, digits=6))

            centering!(ip, z, Δaff, iy1, iy2, αaff)

            # Compute corrector residual
            # @warn "changed"
            ip.methods.rm!(r, z, Δaff, θ, max(ip.σ*ip.μ, κ_tol/5)) # here we set κ = σ*μ, Δ = Δaff
            # ip.methods.rm!(r, z, Δaff, θ, max(ip.σ*ip.μ, 0.0)) # here we set κ = σ*μ, Δ = Δaff
            # println("μ: ", scn(ip.μ, digits=6))
            # println("σ: ", scn(ip.σ, digits=6))

            # Compute corrector search direction
            linear_solve!(solver, Δ, rz, r, reg = ip.reg_val, fact=false)
            progress!(ip, max(r_vio, κ_vio), ϵ_min=ϵ_min)
            α = step_length(z, Δ, iy1, iy2; τ = ip.τ)
            comp && println("**** Δ1:", scn(norm(α*Δ[ix]), digits=4))
            comp && println("**** Δ2:", scn(norm(α*Δ[iy1]), digits=4))
            comp && println("**** Δ3:", scn(norm(α*Δ[iy2]), digits=4))

            verbose && println("iter:", j,
                "  r: ", scn(norm(r, res_norm)),
                "  r_vio: ", scn(r_vio),
                "  κ_vio: ", scn(κ_vio),
                "  Δ: ", scn(norm(Δ)),
                # "  Δ[ix]: ", scn(norm(Δ[ix])),
                # "  Δ[iy1]: ", scn(norm(Δ[iy1])),
                # "  Δ[iy2]: ", scn(norm(Δ[iy2])),
                "  Δaff: ", scn(norm(Δaff)),
                "  τ: ", scn(norm(ip.τ)),
                "  α: ", scn(norm(α)))

            # candidate point
            candidate_point!(z, s, z, Δ, α)

            # update
            ip.methods.r!(r, z, θ, 0.0) # we set κ= 0.0 to measure the bilinear constraint violation

            r_vio = residual_violation(ip, r)
            κ_vio = bilinear_violation(ip, r)
        end
    end
    verbose && println("iter : ", ip.iterations,
                     "  r_vio: ", scn(r_vio),
                     "  κ_vio: ", scn(κ_vio),
                     )

    if (r_vio > r_tol) || (κ_vio > κ_tol)
        @error "Mehrotra12 solver failed to reduce residual below r_tol."
        return false
    end
    # differentiate solution
    # @warn "wrong reg_val"
    # diff_sol && differentiate_solution!(ip, reg = ip.reg_val)
    # We regularize the Jacobian rz in the implicit function theorem to regularize the gradients.
    # We choose reg = κ_tol * γ as this is small (typically 1e-5) and always strictly positive,
    # avoiding NaN gradients when the bilinear constraints are satisfied perfectly rbil = 0.
    # I think that κ_tol * γ_reg > ip.reg_val is ALWAYS true.
    diff_sol && differentiate_solution!(ip, reg = max(ip.reg_val, κ_tol * γ_reg))
    return true
end

function least_squares!(ip::Mehrotra12{T}, z::AbstractVector{T}, θ::AbstractVector{T},
        r::AbstractVector{T}, rz::AbstractMatrix{T}) where {T}
    # doing nothing gives the best result if z_t is correctly initialized with z_t-1 in th simulator
        # A = rz[[ip.idyn; ip.irst], [ip.ix; ip.iy1; ip.iy2]]
        # z[[ip.ix; ip.iy1; ip.iy2]] .+= A' * ((A * A') \ r[[ip.idyn; ip.irst]])
    return nothing
end

function residual_violation(ip::Mehrotra12{T}, r::AbstractVector{T}) where {T}
    max(norm(r[ip.idyn], Inf), norm(r[ip.irst], Inf))
end

function bilinear_violation(ip::Mehrotra12{T}, r::AbstractVector{T}) where {T}
    norm(r[ip.ibil], Inf)
end

function initial_state!(z::AbstractVector{T}, ix::SVector{nx,Int},
        iy1::SVector{ny,Int}, iy2::SVector{ny,Int}; comp::Bool=true, ϵ::T=1e-20) where {T,nx,ny}

    xt = z[ix]
    y1t = z[iy1]
    y2t = z[iy2]
    comp && println("**** xt :", scn(norm(xt), digits=4))
    comp && println("**** y1t :", scn(norm(y1t), digits=4))
    comp && println("**** y2t :", scn(norm(y2t), digits=4))

    δy1 = max(-1.5 * minimum(y1t), 0)
    δy2 = max(-1.5 * minimum(y2t), 0)
    comp && println("**** δw2:", scn(norm(δy1), digits=4))
    comp && println("**** δw3:", scn(norm(δy2), digits=4))

    y1h = y1t .+ δy1
    y2h = y2t .+ δy2
    # comp && println("**** w2h:", scn.(y1h[1:3], digits=4))
    # comp && println("**** w3h:", scn.(y2h[1:3], digits=4))

    δhy1 = 0.5 * y1h'*y2h / (sum(y2h) + ϵ)
    δhy2 = 0.5 * y1h'*y2h / (sum(y1h) + ϵ)
    comp && println("**** sum(y1h):", scn(sum(y1h), digits=4))
    comp && println("**** sum(y2h):", scn(sum(y2h), digits=4))
    comp && println("****  dot:", scn(norm(0.5 * y1h'*y2h), digits=4))
    comp && println("**** δhw2:", scn(norm(δhy1), digits=4))
    comp && println("**** δhw3:", scn(norm(δhy2), digits=4))

    x0 = xt
    y10 = y1h .+ δhy1
    y20 = y2h .+ δhy2
    z[ix] .= x0
    z[iy1] .= y10
    z[iy2] .= y20
    return z
end

function progress!(ip::Mehrotra12{T}, violation::T; ϵ_min::T = 0.05) where {T}
    ϵ = min(ϵ_min, violation^2)
    ip.τ = 1 - ϵ
end

function step_length(z::AbstractVector{T}, Δ::AbstractVector{T},
		iy1::SVector{n,Int}, iy2::SVector{n,Int}; τ::T=0.9995) where {n,T}
    ατ_p = 1.0
    ατ_d = 1.0
    for i in eachindex(iy1)
        if Δ[iy1[i]] > 0.0
            ατ_p = min(ατ_p, τ * z[iy1[i]] / Δ[iy1[i]])
        end
        if Δ[iy2[i]] > 0.0
            ατ_d = min(ατ_d, τ * z[iy2[i]] / Δ[iy2[i]])
        end
    end
    α = min(ατ_p, ατ_d)
    return α
end

function centering!(ip::Mehrotra12{T}, z::AbstractVector{T}, Δaff::AbstractVector{T},
		iy1::SVector{n,Int}, iy2::SVector{n,Int}, αaff::T) where {n,T}
	μaff = (z[iy1] - αaff * Δaff[iy1])' * (z[iy2] - αaff * Δaff[iy2]) / n
	ip.μ = z[iy1]' * z[iy2] / n
	ip.σ = (μaff / ip.μ)^3
	return nothing
end

function rz!(ip::Mehrotra12{T}, rz::AbstractMatrix{T}, z::AbstractVector{T},
        θ::AbstractVector{T}; reg = 0.0) where {T}
    z_reg = deepcopy(z)
    z_reg[ip.iy1] = max.(z[ip.iy1], reg)
    z_reg[ip.iy2] = max.(z[ip.iy2], reg)
    ip.methods.rz!(rz, z_reg, θ)
    return nothing
end

function differentiate_solution!(ip::Mehrotra12; reg = 0.0)
    s = ip.s
    z = ip.z
    θ = ip.θ
    rz = ip.rz
    rθ = ip.rθ
    δz = ip.δz
    δzs = ip.δzs

    κ = ip.κ

    rz!(ip, rz, z, θ, reg = reg)
    rθ!(ip, rθ, z, θ)

    linear_solve!(ip.solver, δzs, rz, rθ, reg = reg)
    @inbounds @views @. δzs .*= -1.0
    mapping!(δz, s, δzs, z)

    nothing
end


################################################################################
# Linearized Solver
################################################################################

function least_squares!(ip::Mehrotra12{T}, z::Vector{T}, θ::AbstractVector{T},
		r::RLin{T}, rz::RZLin{T}) where {T}
	# @warn "wrong"
	δθ = θ - r.θ0
	δrdyn = r.rdyn0 - r.rθdyn * δθ
	δrrst = r.rrst0 - r.rθrst * δθ

	δw1 = rz.A1 * δrdyn + rz.A2 * δrrst
	δw2 = rz.A3 * δrdyn + rz.A4 * δrrst
	δw3 = rz.A5 * δrdyn + rz.A6 * δrrst

	@. @inbounds z[r.ix]  .= r.x0  .+ δw1
	@. @inbounds z[r.iy1] .= r.y10 .+ δw2
	@. @inbounds z[r.iy2] .= r.y20 .+ δw3
	return nothing
end

function residual_violation(ip::Mehrotra12{T}, r::RLin{T}) where {T}
    max(norm(r.rdyn, Inf), norm(r.rrst, Inf))
end

function bilinear_violation(ip::Mehrotra12{T}, r::RLin{T}) where {T}
    norm(r.rbil, Inf)
end

function rz!(ip::Mehrotra12{T}, rz::RZLin{T}, z::AbstractVector{T},
		θ::AbstractVector{T}; reg::T = 0.0) where {T}
	rz!(rz, z, θ, reg = reg)
	return nothing
end

function rz!(rz::RZLin{T}, z::AbstractVector{T},
		θ::AbstractVector{T}; reg::T = 0.0) where {T}
	rz!(rz, z, reg = reg)
	return nothing
end

function rθ!(ip::Mehrotra12{T}, rθ::RθLin{T}, z::AbstractVector{T},
		θ::AbstractVector{T}) where {T}
	return nothing
end

function rθ!(rθ::RθLin{T}, z::AbstractVector{T},
		θ::AbstractVector{T}) where {T}
	return nothing
end







################################################################################
# Mehrotra12 Structure
################################################################################

# STRUCT
#
# Mehrotra12
# Mehrotra12Options
#
#
# METHODS
#
# mehrotra
# interior_point_solve!
# least_squares!
# residual_violation
# bilinear_violation
# initial_state!
# progress!
# step_length!
# centering!
# interior_point_solve!
# rz!
# differentiate_solution!
