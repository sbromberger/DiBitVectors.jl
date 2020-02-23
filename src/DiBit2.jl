mutable struct DiBitVector2 <: AbstractVector{UInt64}
    data::Vector{UInt64}
    len::UInt

    function DiBitVector2(n::Integer, v::Integer)
        if !(Int(v) in 0:3)
            throw(ArgumentError("v must be in 0:3"))
        end
        fv = (0x0000000000000000, 0x5555555555555555,
        0xaaaaaaaaaaaaaaaa, 0xffffffffffffffff)[v + 1]
        vec = Vector{UInt64}(undef, cld(n, 32))
        fill!(vec, fv)
        return new(vec, n % UInt)
    end
end

@inline Base.length(x::DiBitVector2) = x.len % Int
@inline Base.size(x::DiBitVector2) = (length(x),)

@inline index(n::Integer) = ((n-1) >>> 5) + 1
@inline offset(n::Integer) = ((n-1) << 1) & 63

@inline function Base.getindex(x::DiBitVector2, i::Int)
    @boundscheck checkbounds(x, i)
    return UInt8((@inbounds x.data[index(i)] >>> offset(i)) & 3)
end

@inline function unsafe_setindex!(x::DiBitVector2, v::UInt64, i::Int)
    bits = @inbounds x.data[index(i)]
    bits &= ~(UInt(3) << offset(i))
    bits |= convert(UInt64, v) << offset(i)
    @inbounds x.data[index(i)] = bits
end
    
@inline function Base.setindex!(x::DiBitVector2, v::Integer, i::Int)
    v & 3 == v || throw(DomainError("Can only contain 0:3 (tried $v)"))
    @boundscheck checkbounds(x, i)
    unsafe_setindex!(x, convert(UInt64, v), i)
end

@inline function Base.push!(x::DiBitVector2, v::Integer)
    len = length(x)
    len == length(x.data) << 5 && push!(x.data, zero(UInt))
    @inbounds x[len+1] = convert(UInt64, v)
    x.len = (len + 1) % UInt64
end
