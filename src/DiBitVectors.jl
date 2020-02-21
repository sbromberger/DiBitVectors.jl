module DiBitVectors

import Base: getindex, setindex!, size, length

struct DiBitVector <: AbstractVector{Bool}
    data::BitVector
    function DiBitVector(n::Integer, v::Integer = 0)
        if v == 0
            data = falses(n*2)
        elseif v == 3
            data = trues(n*2)
        else
            data = BitVector(undef, n*2)
            b1 = v >> 1 != 0
            b2 = v & 0x01 != 0
            @inbounds for i = 1:n
                Base.unsafe_bitsetindex!(data.chunks, b1, 2*i-1)
                Base.unsafe_bitsetindex!(data.chunks, b2, 2*i)
            end
        end
        return new(data)
    end
end

@inline checkbounds(D::DiBitVector, n::Integer) =  0 < n * 2 ≤ length(D.data) || throw(BoundsError(D, n))

"""
    _set_dibit!(D, n, v)

Sets index v of DiBitVector D to value n.
"""
@inline function unsafe_set_dibit!(D::DiBitVector, n::Integer, v::Integer)
    b1 = v >> 1 != 0
    b2 = v & 0b01 != 0
    o = n * 2 - 1
    Base.unsafe_bitsetindex!(D.data.chunks, b1, o)
    Base.unsafe_bitsetindex!(D.data.chunks, b2, o+1)
end

@inline function setindex!(D::DiBitVector, v::Integer, n::Integer) 
    (0 ≤ v ≤ 3) || throw(DomainError(v, "Values must be between 0 and 3."))
    @boundscheck checkbounds(D, n)
    unsafe_set_dibit!(D, n, v)
end

@inline function unsafe_get_dibit(D::DiBitVector, i::Integer)
    b1 = Base.unsafe_bitgetindex(D.data.chunks, i*2 - 1)
    b2 = Base.unsafe_bitgetindex(D.data.chunks, i*2)
    return UInt8(b1 << 1 + b2)
end

@inline function getindex(D::DiBitVector, n::Integer)
    @boundscheck checkbounds(D, n) 
    unsafe_get_dibit(D, n)
end

@inline length(D::DiBitVector) = length(D.data) ÷ 2
@inline size(D::DiBitVector) = (length(D),)

# include("Bio.jl")
export DiBitVector

end # module
