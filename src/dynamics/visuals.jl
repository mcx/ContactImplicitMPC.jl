function cable_transform(y, z)
    v1 = [0.0, 0.0, 1.0]
    # if norm(z) > norm(y)
    #     v2 = y[1:3,1] - z[1:3,1]
    # else
    #     v2 = z[1:3,1] - y[1:3,1]
    # end
    v2 = y[1:3,1] - z[1:3,1]
    normalize!(v2)
    ax = cross(v1, v2)
    ang = acos(v1'*v2)
    R = AngleAxis(ang, ax...)

    if any(isnan.(R))
        R = I
    else
        nothing
    end

    compose(Translation(z), LinearMap(R))
end

function default_background!(vis)
    setvisible!(vis["/Background"], true)
    setprop!(vis["/Background"], "top_color", RGBA(1.0, 1.0, 1.0, 1.0))
    setprop!(vis["/Background"], "bottom_color", RGBA(1.0, 1.0, 1.0, 1.0))
    setvisible!(vis["/Axes"], false)
end

function plot_surface!(vis, env::Environment{R3})
    f(x) = x[3] - env.surf(x[1:2])
    mesh = GeometryBasics.Mesh(f,
    	Rect(Vec(-2.0, -2.0, -2.0), Vec(4.0, 4.0, 4.0)),
        MarchingCubes(), samples=(50, 50, 50))
    setobject!(vis["surface"], mesh,
    		   MeshPhongMaterial(color=RGBA{Float32}(1.0, 0.0, 0.0, 0.1)))
end
