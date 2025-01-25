struct LikertScale
	pairs::Vector{Pair{Any, Int}}
	function LikertScale(vop::Vector{Pair{Any, Int}})
		new(sort(vop, by = x -> x.second))
	end
end

LikertScale(levels::Union{Dict, UnitRange{Int}}) = LikertScale(collect(levels))

function LikertScale(levels::Vector; values::Union{Nothing, Vector{Int64}} = nothing)

	if all(isa.(levels, Pair))     ## all pairs?
		values = last.(levels)
		levels = first.(levels)

	elseif values isa Vector
		length(values) == length(levels) || throw(
			ArgumentError("Levels and values must have the same length"))
	else
		values = 1:length(levels) # set values
	end

	rtn = Pair{Any, Int64}[]
	for (lvl, val) in zip(levels, values)
		push!(rtn, lvl => Int64(val))
	end
	return LikertScale(rtn)
end

Base.propertynames(::LikertScale) = (:pairs, :levels, :values, :extrema)
function Base.getproperty(d::LikertScale, s::Symbol)
	if s === :levels
		return first.(d.pairs)
	elseif s === :values
		return last.(d.pairs)
	elseif s === :extrema
		extrema(d.values)
	else
		return getfield(d, s)
	end
end
