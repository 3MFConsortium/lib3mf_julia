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

ExtractInfo.cpp : 3MF Read Example (mesh extraction only)

--*/

=*
Generated Julia example based on the C++ ExtractInfo sample.
*=#

include(joinpath(@__DIR__, "..", "src", "Lib3MF.jl"))
using .Lib3MF

struct MeshData
    name::String
    vertices::Vector{NTuple{3, Float32}}
    triangles::Vector{NTuple{3, UInt32}}  # 0-based indices as stored in 3MF
end

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

function open_model(path::AbstractString)
    wrapper = Lib3MF.Wrapper(joinpath(@__DIR__, "..", "libraries", "lib3mf"))
    model = Lib3MF.CreateModel(wrapper)
    reader = Lib3MF.QueryReader(model, "3mf")

    data = read(path)
    GC.@preserve model reader data begin
        Lib3MF.ReadFromBuffer(reader, data)
    end

    return wrapper, model, data
end

function mesh_from_object(model, obj)
    mesh = Lib3MF.GetMeshObjectByID(model, Lib3MF.GetResourceID(obj))
    name = Lib3MF.GetName(mesh)

    verts_raw = Lib3MF.GetVertices(mesh)
    tris_raw = Lib3MF.GetTriangleIndices(mesh)

    verts = [ (Float32(v.Coordinates[1]), Float32(v.Coordinates[2]), Float32(v.Coordinates[3])) for v in verts_raw ]
    tris = [ (UInt32(t.Indices[1]), UInt32(t.Indices[2]), UInt32(t.Indices[3])) for t in tris_raw ]

    return MeshData(name, verts, tris)
end

function load_meshes(path::AbstractString)
    println("------------------------------------------------------------------")
    println("3MF Read example (mesh extraction)")

    wrapper, model, data = open_model(path)
    print_version(wrapper)

    println("------------------------------------------------------------------")

    meshes = MeshData[]
    it = Lib3MF.GetObjects(model)

    # Keep the backing data alive while we traverse model contents
    GC.@preserve data begin
        while Lib3MF.MoveNext(it)
            obj = Lib3MF.GetCurrentObject(it)
            obj === nothing && break
            if Lib3MF.IsMeshObject(obj)
                push!(meshes, mesh_from_object(model, obj))
            end
        end
    end

    return meshes
end

function parse_args(argv)
    path = nothing
    for arg in argv
        if startswith(arg, "-")
            println("Unknown option: " * arg)
            return nothing
        else
            path = arg
        end
    end
    return path
end

if abspath(PROGRAM_FILE) == @__FILE__
    path = parse_args(ARGS)
    if path === nothing
        println("Usage: julia readMeshes.jl model.3mf")
        exit(1)
    end

    try
        meshes = load_meshes(path)
        println("Loaded " * string(length(meshes)) * " mesh(es)")
        for (i, m) in enumerate(meshes)
            println("Mesh #" * string(i) * ": \"" * m.name * "\" | vertices=" * string(length(m.vertices)) * " triangles=" * string(length(m.triangles)))
        end
    catch e
        if e isa Lib3MF.ELib3MFException
            println(e)
            exit(e.code)
        else
            rethrow(e)
        end
    end
end
