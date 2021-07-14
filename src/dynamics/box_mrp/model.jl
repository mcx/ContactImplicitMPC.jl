# rigid body with MRP representation (sphere w/ radius r)
mutable struct BoxMRP{T} <: ContactModel
    dim::Dimensions

    m::T # mass
	J::Vector{T} # inertia
    g::T # gravity
    μ_world::T # friction coefficient

	n_corners::Int
	corner_offset

	base::BaseMethods
	dyn::DynamicsMethods

	joint_friction::SVector
end

function lagrangian(model::BoxMRP, q, q̇)
	# TODO verify how qdot is computed: finite difference?

	m = 1.0
	J = Diagonal([1.0, 1.0, 1.0])

	p = q[1:3]
	mrp = q[4:6]
	v = q̇[1:3]
	ω = q̇[4:6]

	L = 0.0

	# linear
	L += 0.5 * m * transpose(v) * v
	L -= m * model.g * p[3]

	# angular
	L += 0.5 * transpose(ω) * J * ω

	return L
end

function kinematics(model::BoxMRP, q)
    p = q[1:3]
    mrp = q[4:6]

    # R = MRP(mrp...)
	R = mrp_rotation_matrix(mrp)

	p1 = p + R * model.corner_offset[1]
	p2 = p + R * model.corner_offset[2]
	p3 = p + R * model.corner_offset[3]
	p4 = p + R * model.corner_offset[4]
	p5 = p + R * model.corner_offset[5]
	p6 = p + R * model.corner_offset[6]
	p7 = p + R * model.corner_offset[7]
	p8 = p + R * model.corner_offset[8]

    SVector{3 * model.n_corners}([p1;
	                              p2;
								  p3;
								  p4;
								  p5;
								  p6;
								  p7;
								  p8])
end

# mass matrix
function M_func(model::BoxMRP, q)
    m = model.m
	J = model.J
    Diagonal(SVector{6}([m, m, m, J...]))
end

# gravity
function C_func(model::BoxMRP, q, q̇)
	# TODO verify how qdot is computed: finite difference?

    m = model.m
    g = model.g

	ω = q̇[4:6]

    SVector{6}([0.0, 0.0, m * g, cross(ω, Diagonal(model.J) * ω)...]) #TODO confirm cross product
end

# signed distance function
function ϕ_func(model::BoxMRP, env::Environment, q)
    k = kinematics(model, q)

    SVector{model.n_corners}([k[3]  - env.surf(k[1:2]),
							  k[6]  - env.surf(k[4:5]),
							  k[9]  - env.surf(k[7:8]),
							  k[12] - env.surf(k[10:11]),
							  k[15] - env.surf(k[13:14]),
							  k[18] - env.surf(k[16:17]),
							  k[21] - env.surf(k[19:20]),
							  k[24] - env.surf(k[22:23])])
end

# control Jacobian
function B_func(::BoxMRP, q)
    mrp = q[4:6]
    # R = MRP(mrp...)
	R = mrp_rotation_matrix(mrp)
    SMatrix{3, 6}([0.0 0.0 0.0 R[1,1] R[2,1] R[3,1];
                   0.0 0.0 0.0 R[1,2] R[2,2] R[3,2];
                   0.0 0.0 0.0 R[1,3] R[2,3] R[3,3]])
end

# disturbance Jacobian
function A_func(model::BoxMRP, q)
	SMatrix{3, 6}([1.0 0.0 0.0 0.0 0.0 0.0
				   0.0 1.0 0.0 0.0 0.0 0.0
				   0.0 0.0 1.0 0.0 0.0 0.0])
end

# contact Jacobian
function J_func(model::BoxMRP, env::Environment, q)
	k(z) = kinematics(model, z)
	ForwardDiff.jacobian(k, q)
end

function contact_forces(model::BoxMRP, env::Environment{<:World, LinearizedCone}, γ1, b1, q2, k)
	k = kinematics(model, q2)
	m = friction_mapping(env)

	SVector{24}([transpose(rotation(env, k[1:2]))   * [m * b1[1:4];   γ1[1]];
				 transpose(rotation(env, k[4:5]))   * [m * b1[5:8];   γ1[2]];
				 transpose(rotation(env, k[7:8]))   * [m * b1[9:12];  γ1[3]];
				 transpose(rotation(env, k[10:11])) * [m * b1[13:16]; γ1[4]];
				 transpose(rotation(env, k[13:14])) * [m * b1[17:20]; γ1[5]];
				 transpose(rotation(env, k[16:17])) * [m * b1[21:24]; γ1[6]];
				 transpose(rotation(env, k[19:20])) * [m * b1[25:28]; γ1[7]];
				 transpose(rotation(env, k[22:23])) * [m * b1[29:32]; γ1[8]]])
end

function velocity_stack(model::BoxMRP, env::Environment{<:World, LinearizedCone}, q1, q2, k, h)
	p1 = q1[1:3]
	mrp1 = q1[4:6]

	p2 = q2[1:3]
	mrp2 = q2[4:6]

	# TODO verify this finite difference
	v = J_func(model, env, q2) * (q2 - q1) / h[1]

	v1_surf = rotation(env, k[1:3])   * v[1:3]
	v2_surf = rotation(env, k[4:6])   * v[4:6]
	v3_surf = rotation(env, k[7:9])   * v[7:9]
	v4_surf = rotation(env, k[10:12]) * v[10:12]
	v5_surf = rotation(env, k[13:15]) * v[13:15]
	v6_surf = rotation(env, k[16:18]) * v[16:18]
	v7_surf = rotation(env, k[19:21]) * v[19:21]
	v8_surf = rotation(env, k[22:24]) * v[22:24]

	SVector{32}([transpose(friction_mapping(env)) * v1_surf[1:2];
	             transpose(friction_mapping(env)) * v2_surf[1:2];
				 transpose(friction_mapping(env)) * v3_surf[1:2];
				 transpose(friction_mapping(env)) * v4_surf[1:2];
				 transpose(friction_mapping(env)) * v5_surf[1:2];
				 transpose(friction_mapping(env)) * v6_surf[1:2];
				 transpose(friction_mapping(env)) * v7_surf[1:2];
				 transpose(friction_mapping(env)) * v8_surf[1:2]])
end

function velocity_stack(model::BoxMRP, env::Environment{<:World,NonlinearCone}, q1, q2, k, h)
	nc = model.dim.c
	ne = dim(env)

	# p1 = q1[1:3]
	# quat1 = q1[4:7]
	#
	# p2 = q2[1:3]
	# quat2 = q2[4:7]

	v = J_func(model, env, q2) * (q2 - q1) / h[1]

	v_surf = [rotation(env, k[(i-1) * ne .+ (1:ne)]) * v[(i-1) * ne .+ (1:ne)] for i = 1:nc]
	vT_stack = vcat([v_surf[i][1:ne-1] for i = 1:nc]...)
end

function dynamics(model::BoxMRP, h, q0, q1, u1, w1, Λ1, q2)

	# p0 = q0[1:3]
	# quat0 = q0[4:7]
	#
	# p1 = q1[1:3]
	# quat1 = q1[4:7]
	#
	# p2 = q2[1:3]
	# quat2 = q2[4:7]
	#
	# # evalutate at midpoint
	# ω1 = ω_finite_difference(quat0, quat1, h)
	# ω2 = ω_finite_difference(quat1, quat2, h)

	# TODO verify that those finite differences are correct
	qm1 = 0.5 * (q0 + q1)
    vm1 = (q1 - q0) / h[1]
    qm2 = 0.5 * (q1 + q2)
    vm2 = (q2 - q1) / h[1]

	D1L1, D2L1 = lagrangian_derivatives(model, qm1, vm1)
	D1L2, D2L2 = lagrangian_derivatives(model, qm2, vm2)

	return (0.5 * h[1] * D1L1 + D2L1 + 0.5 * h[1] * D1L2 - D2L2
		+ transpose(B_fast(model, q2)) * u1
		+ transpose(A_fast(model, q2)) * w1
		+ Λ1)
end

function dynamics(model::BoxMRP, env::Environment, h, q0, q1, u1, w1, λ1, q2)
	Λ1 = transpose(J_func(model, env, q2)) * λ1
	dynamics(model, h, q0, q1, u1, w1, Λ1, q2)
end


# Kinematics
r = 0.5
c1 = @SVector [r, r, r]
c2 = @SVector [r, r, -r]
c3 = @SVector [r, -r, r]
c4 = @SVector [r, -r, -r]
c5 = @SVector [-r, r, r]
c6 = @SVector [-r, r, -r]
c7 = @SVector [-r, -r, r]
c8 = @SVector [-r, -r, -r]

corner_offset = @SVector [c1, c2, c3, c4, c5, c6, c7, c8]

# Model
box_mrp = BoxMRP(
	Dimensions(6, 3, 3, 8),
	1.0,
	[1.0 / 12.0 * (1.0^2.0 + 1.0^2.0), 1.0 / 12.0 * (1.0^2.0 + 1.0^2.0), 1.0 / 12.0 * (1.0^2.0 + 1.0^2.0)],
	9.81,
	1.0,
	8,
	corner_offset,
	BaseMethods(),
	DynamicsMethods(),
	SVector{6}(zeros(6)))
