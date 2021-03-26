"""
    Hopper2D
    	model inspired by "Dynamically Stable Legged Locomotion"
		s = (x, z, t, r)
			x - lateral position
			z - vertical position
			t - body orientation
			r - leg length
"""
struct Hopper2D{T} <: ContactDynamicsModel
    dim::Dimensions

    mb::T # mass of body
    ml::T # mass of leg
    Jb::T # inertia of body
    Jl::T # inertia of leg

    μ_world::T  # coefficient of friction
    μ_joint::T  # gravity
	g::T

	base::BaseMethods
	dyn::DynamicsMethods
	res::ResidualMethods
	linearized::ResidualMethods

	spa::SparseStructure

	joint_friction::SVector

	env::Environment
end

lagrangian(model::Hopper2D, q, q̇) = 0.0

# Kinematics
function kinematics(::Hopper2D, q)
	[q[1] + q[4] * sin(q[3]),
	 q[2] - q[4] * cos(q[3])]
end

# Methods
function M_func(model::Hopper2D, q)
	Diagonal(@SVector [model.mb + model.ml,
					   model.mb + model.ml,
					   model.Jb + model.Jl,
					   model.ml])
 end

function C_func(model::Hopper2D, q, q̇)
	@SVector [0.0,
			  (model.mb + model.ml) * model.g,
			  0.0,
			  0.0]
end

function ϕ_func(::Hopper2D, q)
    @SVector [q[2] - q[4] * cos(q[3])]
end

function J_func(::Hopper2D, q)
    @SMatrix [1.0 0.0 (q[4] * cos(q[3])) sin(q[3]);
		      0.0 1.0 (q[4] * sin(q[3])) (-1.0 * cos(q[3]))]
end

function B_func(::Hopper2D, q)
	@SMatrix [0.0 0.0 1.0 0.0;
             -sin(q[3]) cos(q[3]) 0.0 1.0]
end

function A_func(::Hopper2D, q)
	@SMatrix [1.0 0.0 0.0 0.0;
	          0.0 1.0 0.0 0.0]
end

# # Parameters
# g = 9.81 # gravity
# μ_world = 1.0  # coefficient of friction
# μ_joint = 1.0
#
# # TODO: change to Raibert parameters
# mb = 1.0 # body mass
# ml = 0.1  # leg mass
# Jb = 0.25 # body inertia
# Jl = 0.025 # leg inertia

# Parameters
g = 9.81 # gravity
μ_world = 0.7 # coefficient of friction
μ_joint = 0.0

# TODO: change to Raibert parameters
mb = 0.07 # body mass
ml = 0.01  # leg mass
Jb = 0.25 # body inertia
Jl = 0.25 # leg inertia


# Dimensions
nq = 4
nu = 2
nw = 2
nc = 1
nb = 2


hopper_2D = Hopper2D(Dimensions(nq, nu, nw, nc, nb),
			   mb, ml, Jb, Jl,
			   μ_world, μ_joint, g,
			   BaseMethods(), DynamicsMethods(), ResidualMethods(), ResidualMethods(),
			   SparseStructure(spzeros(0, 0), spzeros(0, 0)),
			   SVector{4}(zeros(4)),
			   environment_2D_flat())
