# UInt32s
mutable struct DiBitVector4 <: AbstractVector{UInt32}
    data::Vector{UInt32}
    len::UInt

    function DiBitVector4(n::Integer, v::Integer)
        if !(Int(v) in 0:3)
            throw(ArgumentError("v must be in 0:3"))
        end
        fv = (0x00000000, 0x55555555,
        0xaaaaaaaa, 0xffffffff)[v + 1]
        vec = Vector{UInt32}(undef, cld(n, 16))
        fill!(vec, fv)
        return new(vec, n % UInt)
    end
end

@inline Base.length(x::DiBitVector4) = x.len % Int
@inline Base.size(x::DiBitVector4) = (length(x),)

@inline d4index(n::Integer) = ((n-1) >>> 4) + 1
@inline d4offset(n::Integer) = ((n-1) << 1) & 31

@inline function Base.getindex(x::DiBitVector4, i::Int)
    @boundscheck checkbounds(x, i)
    return UInt8((@inbounds x.data[d4index(i)] >>> d4offset(i)) & 3)
end

@inline function unsafe_setindex!(x::DiBitVector4, v::UInt32, i::Int)
    bits = @inbounds x.data[d4index(i)]
    bits &= ~(UInt(3) << d4offset(i))
    bits |= convert(UInt32, v) << d4offset(i)
    @inbounds x.data[d4index(i)] = bits
end
    
@inline function Base.setindex!(x::DiBitVector4, v::Integer, i::Int)
    v & 3 == v || throw(DomainError("Can only contain 0:3 (tried $v)"))
    @boundscheck checkbounds(x, i)
    unsafe_setindex!(x, convert(UInt32, v), i)
end

@inline function Base.push!(x::DiBitVector4, v::Integer)
    len = length(x)
    len == length(x.data) << 4 && push!(x.data, zero(UInt))
    @inbounds x[len+1] = convert(UInt32, v)
    x.len = (len + 1) % UInt
end

export DiBitVector4
