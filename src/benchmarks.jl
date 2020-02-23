# n = 100_000_000
# b = DiBitVectors.DiBitVector(n);
# b2 = DiBitVectors.DiBitVector2(n, 0)
# b3 = DiBitVectors.DiBitVector3(n,0)
# data = DiBitVectors.make_data(n)
#
using BenchmarkTools
using Random
using Statistics

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
 
function benchmark_get_size_N(vecs, data)
    medians = Vector{Float64}()
    for v in vecs
        println("running get size $(length(data.ii)) on vec $(typeof(v))")
        vbench = @benchmark bench_get($v, $data)
        med = median(vbench.times)
        push!(medians, med)
    end
    return medians
end

function benchmark_set_size_N(vecs, data)
    medians = Vector{Float64}()
    for v in vecs
        println("running set size $(length(data.ii)) on vec $(typeof(v))")
        vbench = @benchmark bench_set!($v, $data)
        med = median(vbench.times)
        push!(medians, med)
    end
    return medians
end

function run_benchmarks(sizes)

    benchget = Dict{Int, Vector{Float64}}() # size -> median timings for b1..b4
    benchset = Dict{Int, Vector{Float64}}() # size -> median timings for b1..b4
    for n in sizes
        data = make_data(n)
        v0 = zeros(UInt8, n)
        b1 = DiBitVectors.DiBitVector(n)
        b2 = DiBitVectors.DiBitVector2(n, 0)
        b3 = DiBitVectors.DiBitVector3(n, 0)
        b4 = DiBitVectors.DiBitVector4(n, 0)
        benchget[n] = benchmark_get_size_N([v0, b1, b2, b3, b4], data)
        benchset[n] = benchmark_set_size_N([v0, b1, b2, b3, b4], data)
    end
    return (get=benchget, set=benchset)
end
