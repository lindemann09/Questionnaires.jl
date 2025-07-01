TScalePairs = Vector{Pair{Union{Missing, AbstractString}, Int64}}

struct LikertScale
	pairs::TScalePairs
	function LikertScale(vop::TScalePairs)
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

	rtn = TScalePairs()
	for (lvl, val) in zip(levels, values)
		push!(rtn, string(lvl) => Int64(val))
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
