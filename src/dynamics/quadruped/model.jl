struct Quadruped{T} <: ContactDynamicsModel
	dim::Dimensions

	g::T
	μ_world::T
	μ_joint::T

    # torso
    l_torso::T
    d_torso::T
    m_torso::T
    J_torso::T

    # leg 1
        # thigh
    l_thigh1::T
    d_thigh1::T
    m_thigh1::T
    J_thigh1::T
        # calf
    l_calf1::T
    d_calf1::T
    m_calf1::T
    J_calf1::T

    # leg 2
        # thigh
    l_thigh2::T
    d_thigh2::T
    m_thigh2::T
    J_thigh2::T
        # calf
    l_calf2::T
    d_calf2::T
    m_calf2::T
    J_calf2::T

	# leg 3
        # thigh
    l_thigh3::T
    d_thigh3::T
    m_thigh3::T
    J_thigh3::T
        # calf
    l_calf3::T
    d_calf3::T
    m_calf3::T
    J_calf3::T

	# leg 4
        # thigh
    l_thigh4::T
    d_thigh4::T
    m_thigh4::T
    J_thigh4::T
        # calf
    l_calf4::T
    d_calf4::T
    m_calf4::T
    J_calf4::T

	alt

	# fast methods
	base
	dyn
	res
	approx

	spa::SparseStructure

	joint_friction

	env::Environment
end

# kinematics
function kinematics_1(model::Quadruped, q; body = :torso, mode = :ee)
	x = q[1]
	z = q[2]

	if body == :torso
		l = model.l_torso
		d = model.d_torso
		θ = q[3]
	elseif body == :thigh_1
		l = model.l_thigh1
		d = model.d_thigh1
		θ = q[4]
	elseif body == :thigh_2
		l = model.l_thigh2
		d = model.d_thigh2
		θ = q[6]
	else
		@error "incorrect body specification"
	end

	if mode == :ee
		return [x + l * sin(θ); z - l * cos(θ)]
	elseif mode == :com
		return [x + d * sin(θ); z - d * cos(θ)]
	else
		@error "incorrect mode specification"
	end
end

function jacobian_1(model::Quadruped, q; body = :torso, mode = :ee)
	jac = zeros(eltype(q), 2, model.dim.q)
	jac[1, 1] = 1.0
	jac[2, 2] = 1.0
	if body == :torso
		r = mode == :ee ? model.l_torso : model.d_torso
		θ = q[3]
		jac[1, 3] = r * cos(θ)
		jac[2, 3] = r * sin(θ)
	elseif body == :thigh_1
		r = mode == :ee ? model.l_thigh1 : model.d_thigh1
		θ = q[4]
		jac[1, 4] = r * cos(θ)
		jac[2, 4] = r * sin(θ)
	elseif body == :thigh_2
		r = mode == :ee ? model.l_thigh2 : model.d_thigh2
		θ = q[6]
		jac[1, 6] = r * cos(θ)
		jac[2, 6] = r * sin(θ)
	else
		@error "incorrect body specification"
	end

	return jac
end

function kinematics_2(model::Quadruped, q; body = :calf_1, mode = :ee)

	if body == :calf_1
		p = kinematics_1(model, q, body = :thigh_1, mode = :ee)
		θb = q[5]

		lb = model.l_calf1
		db = model.d_calf1
	elseif body == :calf_2
		p = kinematics_1(model, q, body = :thigh_2, mode = :ee)
		θb = q[7]

		lb = model.l_calf2
		db = model.d_calf2
	elseif body == :thigh_3
		p = kinematics_1(model, q, body = :torso, mode = :ee)
		θb = q[8]

		lb = model.l_thigh3
		db = model.d_thigh3
	elseif body == :thigh_4
		p = kinematics_1(model, q, body = :torso, mode = :ee)
		θb = q[10]

		lb = model.l_thigh4
		db = model.d_thigh4
	else
		@error "incorrect body specification"
	end

	if mode == :ee
		return p + [lb * sin(θb); -1.0 * lb * cos(θb)]
	elseif mode == :com
		return p + [db * sin(θb); -1.0 * db * cos(θb)]
	else
		@error "incorrect mode specification"
	end
end

function jacobian_2(model::Quadruped, q; body = :calf_1, mode = :ee)

	if body == :calf_1
		jac = jacobian_1(model, q, body = :thigh_1, mode = :ee)

		θb = q[5]

		r = mode == :ee ? model.l_calf1 : model.d_calf1

		jac[1, 5] += r * cos(θb)
		jac[2, 5] += r * sin(θb)
	elseif body == :calf_2
		jac = jacobian_1(model, q, body = :thigh_2, mode = :ee)

		θb = q[7]

		r = mode == :ee ? model.l_calf2 : model.d_calf2

		jac[1, 7] += r * cos(θb)
		jac[2, 7] += r * sin(θb)
	elseif body == :thigh_3
		jac = jacobian_1(model, q, body = :torso, mode = :ee)
		θb = q[8]

		r = mode == :ee ? model.l_thigh3 : model.d_thigh3

		jac[1, 8] += r * cos(θb)
		jac[2, 8] += r * sin(θb)
	elseif body == :thigh_4
		jac = jacobian_1(model, q, body = :torso, mode = :ee)

		θb = q[10]

		r = mode == :ee ? model.l_thigh4 : model.d_thigh4

		jac[1, 10] += r * cos(θb)
		jac[2, 10] += r * sin(θb)
	else
		@error "incorrect body specification"
	end

	return jac
end

function kinematics_3(model::Quadruped, q; body = :calf_3, mode = :ee)

	if body == :calf_3
		p = kinematics_2(model, q, body = :thigh_3, mode = :ee)
		θc = q[9]


		lb = model.l_calf3
		db = model.d_calf3
	elseif body == :calf_4
		p = kinematics_2(model, q, body = :thigh_4, mode = :ee)

		θc = q[11]

		lb = model.l_calf4
		db = model.d_calf4
	else
		@error "incorrect body specification"
	end

	if mode == :ee
		return p + [lb * sin(θc); -1.0 * lb * cos(θc)]
	elseif mode == :com
		return p + [db * sin(θc); -1.0 * db * cos(θc)]
	else
		@error "incorrect mode specification"
	end
end

function jacobian_3(model::Quadruped, q; body = :calf_3, mode = :ee)

	if body == :calf_3
		jac = jacobian_2(model, q, body = :thigh_3, mode = :ee)

		θc = q[9]

		r = mode == :ee ? model.l_calf3 : model.d_calf3

		jac[1, 9] += r * cos(θc)
		jac[2, 9] += r * sin(θc)

	elseif body == :calf_4
		jac = jacobian_2(model, q, body = :thigh_4, mode = :ee)

		θc = q[11]

		r = mode == :ee ? model.l_calf4 : model.d_calf4

		jac[1, 11] += r * cos(θc)
		jac[2, 11] += r * sin(θc)
	else
		@error "incorrect body specification"
	end

	return jac
end

# Lagrangian
function lagrangian(model::Quadruped, q, q̇)
	L = 0.0

	# # torso
	p_torso = kinematics_1(model, q, body = :torso, mode = :com)
	J_torso = jacobian_1(model, q, body = :torso, mode = :com)
	v_torso = J_torso * q̇
	#
	L += 0.5 * model.m_torso * transpose(v_torso) * v_torso
	L += 0.5 * model.J_torso * q̇[3]^2.0
	L -= model.m_torso * model.g * p_torso[2]

	# thigh 1
	p_thigh_1 = kinematics_1(model, q, body = :thigh_1, mode = :com)
	J_thigh_1 = jacobian_1(model, q, body = :thigh_1, mode = :com)
	v_thigh_1 = J_thigh_1 * q̇

	L += 0.5 * model.m_thigh1 * transpose(v_thigh_1) * v_thigh_1
	L += 0.5 * model.J_thigh1 * q̇[4]^2.0
	L -= model.m_thigh1 * model.g * p_thigh_1[2]

	# leg 1
	p_calf_1 = kinematics_2(model, q, body = :calf_1, mode = :com)
	J_calf_1 = jacobian_2(model, q, body = :calf_1, mode = :com)
	v_calf_1 = J_calf_1 * q̇

	L += 0.5 * model.m_calf1 * transpose(v_calf_1) * v_calf_1
	L += 0.5 * model.J_calf1 * q̇[5]^2.0
	L -= model.m_calf1 * model.g * p_calf_1[2]

	# thigh 2
	p_thigh_2 = kinematics_1(model, q, body = :thigh_2, mode = :com)
	J_thigh_2 = jacobian_1(model, q, body = :thigh_2, mode = :com)
	v_thigh_2 = J_thigh_2 * q̇

	L += 0.5 * model.m_thigh2 * transpose(v_thigh_2) * v_thigh_2
	L += 0.5 * model.J_thigh2 * q̇[6]^2.0
	L -= model.m_thigh2 * model.g * p_thigh_2[2]

	# leg 2
	p_calf_2 = kinematics_2(model, q, body = :calf_2, mode = :com)
	J_calf_2 = jacobian_2(model, q, body = :calf_2, mode = :com)
	v_calf_2 = J_calf_2 * q̇

	L += 0.5 * model.m_calf2 * transpose(v_calf_2) * v_calf_2
	L += 0.5 * model.J_calf2 * q̇[7]^2.0
	L -= model.m_calf2 * model.g * p_calf_2[2]

	# thigh 3
	p_thigh_3 = kinematics_2(model, q, body = :thigh_3, mode = :com)
	J_thigh_3 = jacobian_2(model, q, body = :thigh_3, mode = :com)
	v_thigh_3 = J_thigh_3 * q̇

	L += 0.5 * model.m_thigh3 * transpose(v_thigh_3) * v_thigh_3
	L += 0.5 * model.J_thigh3 * q̇[8]^2.0
	L -= model.m_thigh3 * model.g * p_thigh_3[2]

	# leg 3
	p_calf_3 = kinematics_3(model, q, body = :calf_3, mode = :com)
	J_calf_3 = jacobian_3(model, q, body = :calf_3, mode = :com)
	v_calf_3 = J_calf_3 * q̇

	L += 0.5 * model.m_calf3 * transpose(v_calf_3) * v_calf_3
	L += 0.5 * model.J_calf3 * q̇[9]^2.0
	L -= model.m_calf3 * model.g * p_calf_3[2]

	# thigh 4
	p_thigh_4 = kinematics_2(model, q, body = :thigh_4, mode = :com)
	J_thigh_4 = jacobian_2(model, q, body = :thigh_4, mode = :com)
	v_thigh_4 = J_thigh_4 * q̇

	L += 0.5 * model.m_thigh4 * transpose(v_thigh_4) * v_thigh_4
	L += 0.5 * model.J_thigh4 * q̇[10]^2.0
	L -= model.m_thigh4 * model.g * p_thigh_4[2]

	# leg 4
	p_calf_4 = kinematics_3(model, q, body = :calf_4, mode = :com)
	J_calf_4 = jacobian_3(model, q, body = :calf_4, mode = :com)
	v_calf_4 = J_calf_4 * q̇

	L += 0.5 * model.m_calf4 * transpose(v_calf_4) * v_calf_4
	L += 0.5 * model.J_calf4 * q̇[11]^2.0
	L -= model.m_calf4 * model.g * p_calf_4[2]

	return L
end

function _dLdq(model::Quadruped, q, q̇)
	Lq(x) = lagrangian(model, x, q̇)
	ForwardDiff.gradient(Lq, q)
end

function _dLdq̇(model::Quadruped, q, q̇)
	Lq̇(x) = lagrangian(model, q, x)
	ForwardDiff.gradient(Lq̇, q̇)
end

# Methods
function M_func(model::Quadruped, q)
	M = Diagonal([0.0, 0.0, model.J_torso, model.J_thigh1, model.J_calf1, model.J_thigh2, model.J_calf2, model.J_thigh3, model.J_calf3, model.J_thigh4, model.J_calf4])

	# torso
	J_torso = jacobian_1(model, q, body = :torso, mode = :com)
	M += model.m_torso * transpose(J_torso) * J_torso

	# thigh 1
	J_thigh_1 = jacobian_1(model, q, body = :thigh_1, mode = :com)
	M += model.m_thigh1 * transpose(J_thigh_1) * J_thigh_1

	# leg 1
	J_calf_1 = jacobian_2(model, q, body = :calf_1, mode = :com)
	M += model.m_calf1 * transpose(J_calf_1) * J_calf_1

	# thigh 2
	J_thigh_2 = jacobian_1(model, q, body = :thigh_2, mode = :com)
	M += model.m_thigh2 * transpose(J_thigh_2) * J_thigh_2

	# leg 2
	J_calf_2 = jacobian_2(model, q, body = :calf_2, mode = :com)
	M += model.m_calf2 * transpose(J_calf_2) * J_calf_2

	# thigh 3
	J_thigh_3 = jacobian_2(model, q, body = :thigh_3, mode = :com)
	M += model.m_thigh3 * transpose(J_thigh_3) * J_thigh_3

	# leg 3
	J_calf_3 = jacobian_3(model, q, body = :calf_3, mode = :com)
	M += model.m_calf3 * transpose(J_calf_3) * J_calf_3

	# thigh 4
	J_thigh_4 = jacobian_2(model, q, body = :thigh_4, mode = :com)
	M += model.m_thigh4 * transpose(J_thigh_4) * J_thigh_4

	# leg 4
	J_calf_4 = jacobian_3(model, q, body = :calf_4, mode = :com)
	M += model.m_calf4 * transpose(J_calf_4) * J_calf_4

	return M
end

function ϕ_func(model::Quadruped, q)
	p_calf_1 = kinematics_2(model, q, body = :calf_1, mode = :ee)
	p_calf_2 = kinematics_2(model, q, body = :calf_2, mode = :ee)
	p_calf_3 = kinematics_3(model, q, body = :calf_3, mode = :ee)
	p_calf_4 = kinematics_3(model, q, body = :calf_4, mode = :ee)
	alt = model.alt

	@SVector [p_calf_1[2] - alt[1] - model.env.surf(p_calf_1[1]),
			  p_calf_2[2] - alt[2] - model.env.surf(p_calf_2[1]),
			  p_calf_3[2] - alt[3] - model.env.surf(p_calf_3[1]),
			  p_calf_4[2] - alt[4] - model.env.surf(p_calf_4[1])]
end

function B_func(model::Quadruped, q)
	@SMatrix [0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0;
			  0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0;
			  0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0;
			  0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0;
			  0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0;
			  0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0;
			  0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0;
			  0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0]
end

function A_func(model::Quadruped, q)
	@SMatrix [1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0;
			  0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
end

function J_func(model::Quadruped, q)
	J_calf_1 = jacobian_2(model, q, body = :calf_1, mode = :ee)
	J_calf_2 = jacobian_2(model, q, body = :calf_2, mode = :ee)
	J_calf_3 = jacobian_3(model, q, body = :calf_3, mode = :ee)
	J_calf_4 = jacobian_3(model, q, body = :calf_4, mode = :ee)
	# map = [1.0; -1.0]

	return [J_calf_1;
			J_calf_2;
			J_calf_3;
			J_calf_4]
end

function C_func(model::Quadruped, q, q̇)
	tmp_q(z) = _dLdq̇(model, z, q̇)
	tmp_q̇(z) = _dLdq̇(model, q, z)

	ForwardDiff.jacobian(tmp_q, q) * q̇ - _dLdq(model, q, q̇)
end

################################################################################
# Instantiation
################################################################################
# Dimensions
nq = 2 + 5 + 4            # configuration dimension
nu = 4 + 4                # control dimension
nc = 4                    # number of contact points
nf = 2                    # number of parameters for friction cone
nb = nc * nf
nw = 2

# World parameters
g = 9.81      # gravity
μ_world = 1.0 # coefficient of friction
μ_joint = 0.1 # coefficient of torque friction at the joints

# ~Unitree A1
# Model parameters
m_torso = 4.713
m_thigh = 1.013
m_leg = 0.166

J_torso = 0.01683
J_thigh = 0.00552
J_leg = 0.00299

l_torso = 0.267
l_thigh = 0.2
l_leg = 0.2

d_torso = 0.0127
d_thigh = 0.00323
d_leg = 0.006435

quadruped = Quadruped(Dimensions(nq, nu, nw, nc, nb),
				g, μ_world, μ_joint,
				l_torso, d_torso, m_torso, J_torso,
				l_thigh, d_thigh, m_thigh, J_thigh,
				l_leg, d_leg, m_leg, J_leg,
				l_thigh, d_thigh, m_thigh, J_thigh,
				l_leg, d_leg, m_leg, J_leg,
				l_thigh, d_thigh, m_thigh, J_thigh,
				l_leg, d_leg, m_leg, J_leg,
				l_thigh, d_thigh, m_thigh, J_thigh,
				l_leg, d_leg, m_leg, J_leg,
				zeros(nc),
				BaseMethods(), DynamicsMethods(), ResidualMethods(), ApproximateMethods(),
				SparseStructure(spzeros(0, 0), spzeros(0, 0)),
				SVector{nq}([zeros(3); μ_joint * ones(nq - 3)]),
				environment_2D_flat())

function initial_configuration(model::Quadruped, θ)
    q1 = zeros(model.dim.q)
    q1[3] = pi / 2.0
    q1[4] = -θ
    q1[5] = θ
    q1[6] = -θ
    q1[7] = θ
    q1[8] = -θ
    q1[9] = θ
    q1[10] = -θ
    q1[11] = θ
    q1[2] = model.l_thigh1 * cos(q1[4]) + model.l_calf1 * cos(q1[5])
    return q1
end
