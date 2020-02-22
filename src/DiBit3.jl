using BitOperations

struct DiBitVector3 <: AbstractVector{Bool}
    data::BitVector
    function DiBitVector3(n::Integer, v::Integer = 0)
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

@inline function setindex!(D::DiBitVector3, v::Integer, n::Integer)
    (0 ≤ v ≤ 3) || throw(DomainError(v, "Values must be between 0 and 3."))
    @boundscheck checkbounds(D, n)
    chunk,pos = _chunk_pos(n)
    D.data.chunks[chunk] = bset(D.data.chunks[chunk],pos:pos+1,v)
end

@inline function getindex(D::DiBitVector3, n::Integer)
    @boundscheck checkbounds(D, n)
    chunk,pos = _chunk_pos(n)
    UInt8( bget(D.data.chunks[chunk],pos:pos+1) )
end

@inline function _chunk_pos(n)
    chunk = bget(n-1,5:63)+1 # 1-based chunk index
    pos = 2bget(n-1,0:4) # 0-based bit position index
    return (chunk,pos)
end

@inline length(D::DiBitVector3) = length(D.data) ÷ 2
@inline size(D::DiBitVector3) = (length(D),)

export DiBitVector3
