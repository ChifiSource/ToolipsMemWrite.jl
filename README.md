<img src = "https://github.com/ChifiSource/image_dump/blob/main/toolips/toolipsmemwrite.png"></img>

- [Documentation](doc.toolips.app/extensions/toolips_base64)
- [Toolips](https://github.com/ChifiSource/Toolips.jl)
- [Extension Gallery](https://toolips.app/?page=gallery&selected=memwrite)\
Writes Components into memory and can also save serialized Component Vectors automatically. Writing to memory is done with the `memwrite!` function. This function can also be used inside of a conditional.
```julia
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
This approach is alright, but still puts CPU power towards writing the Components. It is way better to instead use `memwrite!` with write set to false first, then use `memwrite!` normally. You can follow this with a `return`, which breaks the function pipeline and ceases the writing of the function.
```julia
using Toolips
using ToolipsMemWrite

function myroute(c::Connection)
    if memwrite!(c, "mydivider", write = false)
        memwrite!(c, "mydivider")
        return
    end
    mycomp = divider("mydivider", align = "center")
    myp = p("myp", text = "hello world!")
    push!(mycomp, myp)
    othercomp = a("othercomp", text = "othercomp")
    memwrite!(c, mycomp)
end

st = ServerTemplate(extensions = [Logger(), ComponentMemory()])
st.start()
```
You can also use the same techniques with `diskwrite!`.
```julia
using Toolips
using ToolipsMemWrite

function myroute(c::Connection)
    if diskwrite!(c, "mydivider", write = false)
        diskwrite!(c, "mydivider")
        return
    end
    mycomp = divider("mydivider", align = "center")
    myp = p("myp", text = "hello world!")
    push!(mycomp, myp)
    othercomp = a("othercomp", text = "othercomp")
    diskwrite!(c, mycomp)
end

st = ServerTemplate(extensions = [Logger(), ComponentMemory()])
st.start()
```
