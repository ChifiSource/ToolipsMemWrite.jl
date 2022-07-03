"""
Created in July, 2022 by
[chifi - an open source software dynasty.](https://github.com/orgs/ChifiSource)
by team
[toolips](https://github.com/orgs/ChifiSource/teams/toolips)
This software is MIT-licensed.
### ToolipsMemWrite
The MemWrite extension allows Components to be saved via the memwrite! method
and the ComponentMemory extension.
##### Module Composition
- [**ToolipsMemWrite**](https://github.com/ChifiSource/ToolipsMemWrite.jl)
"""
module ToolipsMemWrite
using Toolips
import Toolips: SpoofConnection, ServerExtension, Servable
import Base: getindex

"""
### ComponentMemory <: Toolips.ServerExtension
- type::**Symbol** - The type of this ServerExtension (:connection).
- lookup::**Dict{String, String}** - A dictionary of Component names and
outputs.
---
The ComponentMemory extension allows for one to save the output
    of ToolipsComponents for future writing. This is done by
    loading this extension into a ServerTemplate, and then using
    the memwrite! method in place of the write! method.
##### example
```
using Toolips
using ToolipsMemWrite

function myroute(c::Connection)
    mycomp = divider("mydivider", align = "center")
    myp = p("myp", text = "hello world!")
    push!(mycomp, myp)
    othercomp = a("othercomp", text = "othercomp")
    # Saved:
    memwrite!(c, mycomp)
    # Not saved:
    write!(c, othercomp)
end

st = ServerTemplate(extensions = [Logger(), ComponentMemory()])
st.start()
```
------------------
##### constructors
- ComponentMemory()
"""
mutable struct ComponentMemory <: ServerExtension
    type::Symbol
    lookup::Dict{String, String}
    function ComponentMemory()
        lookup::Dict{String, String} = Dict()
        new(:connection, lookup)
    end
end

"""
**MemWrite Interface**
### getindex(cmem::ComponentMemory, s::Servable) -> ::Servable
------------------
Retrieves the Servable `s` from the lookup dictionary in the
ComponentMemory.
#### example
```
using Toolips
using ToolipsMemWrite

function myroute(c::Connection)
    mycomp = divider("mydivider", align = "center")
    myp = p("myp", text = "hello world!")
    memwrite!(c, mycomp)
    c[:ComponentMemory][mycomp]
end
```
"""
getindex(cmem::ComponentMemory, s::Servable) = cmem.lookup[s.name]::String

"""
**MemWrite Interface**
### getindex(cmem::ComponentMemory, s::Servable) -> ::Servable
------------------
Retrieves the Servable `s` by name from the lookup dictionary in the
ComponentMemory.
#### example
```
using Toolips
using ToolipsMemWrite

function myroute(c::Connection)
    mycomp = divider("mydivider", align = "center")
    myp = p("myp", text = "hello world!")
    memwrite!(c, mycomp)
    c[:ComponentMemory]["mydivider"]
end
```
"""
getindex(cmem::ComponentMemory, name::String) = cmem.lookup[name]::String

"""
**MemWrite Interface**
### memwrite!(c::AbstractConnection, s::Servable)
------------------
Writes a Component to the Connection c, then saves the Component for
future writing.
#### example
```
function myroute(c::Connection)
    mycomp = divider("mydivider", align = "center")
    myp = p("myp", text = "hello world!")
    push!(mycomp, myp)
    othercomp = a("othercomp", text = "othercomp")
    # Saved:
    memwrite!(c, mycomp)
    # Not saved:
    write!(c, othercomp)
end
```
"""
function memwrite!(c::AbstractConnection, s::Servable)
    if s.name in keys(c[:ComponentMemory])
        write!(c, c[:ComponentMemory][s])
    else
        spoofconn::SpoofConnection = SpoofConnection()
        write!(spoofconn, s)
        push!(c[:ComponentMemory].lookup, s.name => spoofconn.http.text)
        write!(c, s)
    end
end

"""
**MemWrite Interface**
### memwrite!(c::AbstractConnection, s::Vector{Servable})
------------------
Writes the Components in s to the Connection c, then saves the Components for
future writing.
#### example
```
function myroute(c::Connection)
    mycomp = divider("mydivider", align = "center")
    myp = p("myp", text = "hello world!")
    push!(mycomp, myp)
    othercomp = a("othercomp", text = "othercomp")
    # Saved:
    memwrite!(c, mycomp)
    # Not saved:
    write!(c, othercomp)
end
```
"""
function memwrite!(c::AbstractConnection, s::Vector{Servable})
    name::String = join([comp.name for comp in s])
    if name in keys(c[:ComponentMemory])
        write!(c, c[:ComponentMemory][name])
    else
        spoofconn::SpoofConnection = SpoofConnection()
        write!(spoofconn, s)
        push!(c[:ComponentMemory].lookup, name => spoofconn.http.text)
        write!(c, s)
    end
end

end # module
