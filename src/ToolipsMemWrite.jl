module ToolipsMemWrite
using Toolips
import Toolips: SpoofConnection, ServerExtension, Servable
import Base: getindex

mutable struct ComponentMemory <: ServerExtension
    type::Symbol
    lookup::Dict{String, String}
    function ComponentMemory()
        lookup::Dict{String, String} = Dict()
        new(:connection, lookup)
    end
end

getindex(cmem::ComponentMemory, s::Servable) = cmem.lookup[s.name]

getindex(cmem::ComponentMemory, name::String) = cmem.lookup[name]

function memwrite!(c::Connection, s::Servable)
    if s.name in keys(c[:ComponentMemory])
        write!(c, c[:ComponentMemory][s])
    else
        spoofconn = SpoofConnection()
        write!(spoofconn, s)
        push!(c[:ComponentMemory].lookup, s.name => spoofconn.http.text)
        write!(c, s)
    end
end

function memwrite!(c::Connection, s::Vector{Servable})
    name = join([comp.name for comp in s])
    if name in keys(c[:ComponentMemory])
        write!(c, c[:ComponentMemory][name])
    else
        spoofconn = SpoofConnection()
        write!(spoofconn, s)
        push!(c[:ComponentMemory].lookup, name => spoofconn.http.text)
        write!(c, s)
    end
end

end # module
