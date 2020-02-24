using Statistics

function benchmark_run(::Type{T},sizes,seqlengths) where T
    f = (func,n,seqlength) -> begin
        @info "Running $func with n = 2^$(log2(n)), seq=$seqlength"
        if T <: Vector
            b=zeros(eltype(T),n)
        else
            b = T(n,0)
        end
        data = make_random_data(n,seqlength)
        vbench = @benchmark bench_set!($b,$data)
        (func="$func",n=n,log2=log2(n),seq=seqlength,
            mem=_memsizemb(b),optime=median(vbench.times)/n)
    end
    [f(func,n,seqlength) for n in sizes for seqlength in seqlengths
        for func in (bench_set!,bench_get)]
end

function _memsizemb(x::T) where T
    if hasfield(T,:data)
        sizeof(x.data)/2^20
    else
        sizeof(x)/2^20
    end
end
