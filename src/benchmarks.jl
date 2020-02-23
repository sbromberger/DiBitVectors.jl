# n = 100_000_000
# b = DiBitVectors.DiBitVector(n);
# b2 = DiBitVectors.DiBitVector2(n, 0)
# b3 = DiBitVectors.DiBitVector3(n,0)
# data = DiBitVectors.make_random_data(n)
#
using BenchmarkTools
using Random
using Statistics

struct BenchResult
    label::String
    n::Int
    fn::String  # "get" or "set"
    result:: Float64  # median time
end

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

function make_random_data(n, seqlength=1)
    @assert seqlength > 0
    if seqlength==1
        inds = Random.shuffle(1:n)
    else
        inds = Iterators.partition(1:n,seqlength) |> collect |>
            Random.shuffle |> Iterators.flatten |> collect
    end
    vals = rand(0:3, n)
    return (ii=inds, vv=vals, sumvv=sum(vals))
end

function make_seq_data(n)
    inds = 1:n
    vals = rand(0:3, n)
    return(ii=inds, vv=vals, sumvv=sum(vals))
end

function benchmark_size_N(vecs, data, fn::String)
    res = Vector{BenchResult}()
    n = length(data.ii)
    for v in vecs
        label = typeof(v)
        println("running get size $n on vec $label")
        if fn == "get"
            vbench = @benchmark bench_get($v, $data)
        else
            vbench = @benchmark bench_set!($v, $data)
        end

        med = median(vbench.times)
        br = BenchResult("$label", n, fn, med)
        push!(res, br)
    end
    return res
end

function run_benchmarks(sizes, datatype = :random, seqlength=1)

    benchget = Dict{Int, Vector{BenchResult}}() # size -> median timings for b1..b4
    benchset = Dict{Int, Vector{BenchResult}}() # size -> median timings for b1..b4

    for n in sizes
        if datatype == :sequential
            data = make_seq_data(n)
        else
            data = make_random_data(n,seqlength)
        end
        v0 = zeros(UInt8, n)
        b1 = DiBitVectors.DiBitVector(n)
        b2 = DiBitVectors.DiBitVector2(n, 0)
        b3 = DiBitVectors.DiBitVector3(n, 0)
        b4 = DiBitVectors.DiBitVector4(n, 0)
        benchget[n] = benchmark_size_N([v0, b1, b2, b3, b4], data, "get")
        benchset[n] = benchmark_size_N([v0, b1, b2, b3, b4], data, "set")
    end
    return (get=benchget, set=benchset)
end

function save_benchmarks(getset, labels::Vector{String}, prefix::String)
    fn = "$(prefix)-get.csv"
    hdr = "n," * join(labels, ",")
    open(fn,"w") do f
        println(f,hdr)
        for k in sort(collect(keys(getset.get)))
            l = "$k," * join(getset.get[k], ",")
            println(f, l)
        end
    end

    fn = "$(prefix)-set.csv"
    open(fn,"w") do f
        println(f,hdr)
        for k in sort(collect(keys(getset.set)))
            l = "$k," * join(getset.set[k], ",")
            println(f, l)
        end
    end
end
