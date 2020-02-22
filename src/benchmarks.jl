# n = 100_000_000
# b = DiBitVectors.DiBitVector(n);
# b2 = DiBitVectors.DiBitVector2(n, 0)
# data = DiBitVectors.make_data(n)
#
using Random
function bench_set!(x, data)
    @inbounds for i = 1:length(data.ii)
      x[data.ii[i]] = data.vv[i]
    end
end

 function bench_get(x, data)
     n = zero(UInt64)
     @inbounds for i in data.ii
         n += x[i]
     end
     n
 end
 
 function make_data(n)
     inds = Random.shuffle(1:n)
     vals = rand(0:3, n)
     return (ii=inds, vv=vals, sumvv=sum(vals))
 end
