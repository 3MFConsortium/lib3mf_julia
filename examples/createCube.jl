#=++

Copyright (C) 2019 3MF Consortium

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL MICROSOFT AND/OR NETFABB BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Abstract:

Cube.cpp : 3MF Cube creation example

--*/

=*
Generated Julia example based on the C++ cube sample.
*=#

include(joinpath(@__DIR__, "..", "src", "Lib3MF.jl"))
using .Lib3MF

function print_version(wrapper)
    major, minor, micro = Lib3MF.GetLibraryVersion(wrapper)
    version = string(major) * "." * string(minor) * "." * string(micro)
    has_pre, pre = Lib3MF.GetPrereleaseInformation(wrapper)
    has_build, build = Lib3MF.GetBuildInformation(wrapper)
    print("lib3mf version = " * version)
    if has_pre
        print("-" * pre)
    end
    if has_build
        print("+" * build)
    end
    println()
end

function create_vertex(x::Float32, y::Float32, z::Float32)
    return Lib3MF.sPosition((Cfloat(x), Cfloat(y), Cfloat(z)))
end

function create_triangle(v0::Int, v1::Int, v2::Int)
    return Lib3MF.sTriangle((UInt32(v0), UInt32(v1), UInt32(v2)))
end

function cube_example()
    wrapper = Lib3MF.Wrapper(joinpath(@__DIR__, "..", "libraries", "lib3mf"))

    println("------------------------------------------------------------------")
    println("3MF Cube example")
    print_version(wrapper)
    println("------------------------------------------------------------------")

    model = Lib3MF.CreateModel(wrapper)
    mesh_object = Lib3MF.AddMeshObject(model)
    Lib3MF.SetName(mesh_object, "Box")

    vertices = Array{Lib3MF.sPosition, 1}(undef, 8)
    triangles = Array{Lib3MF.sTriangle, 1}(undef, 12)

    fSizeX = 100.0f0
    fSizeY = 200.0f0
    fSizeZ = 300.0f0

    vertices[1] = create_vertex(0.0f0, 0.0f0, 0.0f0)
    vertices[2] = create_vertex(fSizeX, 0.0f0, 0.0f0)
    vertices[3] = create_vertex(fSizeX, fSizeY, 0.0f0)
    vertices[4] = create_vertex(0.0f0, fSizeY, 0.0f0)
    vertices[5] = create_vertex(0.0f0, 0.0f0, fSizeZ)
    vertices[6] = create_vertex(fSizeX, 0.0f0, fSizeZ)
    vertices[7] = create_vertex(fSizeX, fSizeY, fSizeZ)
    vertices[8] = create_vertex(0.0f0, fSizeY, fSizeZ)

    triangles[1] = create_triangle(2, 1, 0)
    triangles[2] = create_triangle(0, 3, 2)
    triangles[3] = create_triangle(4, 5, 6)
    triangles[4] = create_triangle(6, 7, 4)
    triangles[5] = create_triangle(0, 1, 5)
    triangles[6] = create_triangle(5, 4, 0)
    triangles[7] = create_triangle(2, 3, 7)
    triangles[8] = create_triangle(7, 6, 2)
    triangles[9] = create_triangle(1, 2, 6)
    triangles[10] = create_triangle(6, 5, 1)
    triangles[11] = create_triangle(3, 0, 4)
    triangles[12] = create_triangle(4, 7, 3)

    Lib3MF.SetGeometry(mesh_object, vertices, triangles)
    mesh_object_base = Lib3MF.Object(mesh_object.handle, mesh_object.wrapper)
    Lib3MF.AddBuildItem(model, mesh_object_base, Lib3MF.GetIdentityTransform(wrapper))

    writer = Lib3MF.QueryWriter(model, "3mf")
    Lib3MF.WriteToFile(writer, "cube.3mf")
    println("done")
end

try
    cube_example()
catch e
    if e isa Lib3MF.ELib3MFException
        println(e)
        exit(e.code)
    else
        rethrow(e)
    end
end
