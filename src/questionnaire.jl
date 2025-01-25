"""functions to handle questionnaire data
"""

struct Questionnaire
	items::Vector{String}
	scale::LikertScale
	inverted::Vector{String}
	ignore::Vector{String}
end

function Questionnaire(
    items::Union{Vector{String}, Vector{Symbol}},
	scale::Union{LikertScale, Vector};
	inverted::Union{Nothing, Vector{String}, Vector{Symbol}} = nothing,
	ignore::Union{Nothing, Vector{String}, Vector{Symbol}} = nothing,
)
	inverted = isnothing(inverted) ? String[] : String.(inverted)
	ignore = isnothing(ignore) ? String[] : String.(ignore)
	if scale isa Vector
		scale = LikertScale(scale)
	end
	Questionnaire(String.(items), scale, inverted, ignore)
end


"""extract items and invert scale, if required,

To be ignored items will be omitted.
To get the ignored items use `ignored_only=true`
"""
function items(
    quest::Questionnaire, quest_data::DataFrame;
	recode::Bool = true,
	invert::Bool = false,
	ignored_only::Bool = false,
	add_columns::Union{Nothing, Vector} = nothing
)
	if isnothing(add_columns)
		df = DataFrame()
	else
		df = select(quest_data, add_columns)
	end

	for c in quest.items
		if (c in quest.ignore) == ignored_only
			# recode
			if recode
				values = CategoricalArrays.recode(quest_data[!, c], quest.scale.pairs...)
			else
				values = quest_data[!, c]
			end
			#invert scale
			if c in quest.inverted && invert
				# invert_scale
                scale_min, scale_max = quest.scale.extrema
				try
					df[!, String(c)*"_inv"] = (-1 * values) .+ scale_min .+ scale_max
				catch err
					info = recode ? "" : "Try `recode=true`."
					@error "Can't invert scale (" * c * "). " * info
					if isa(err, MethodError)
						rethrow()
					end
				end
			else
                df[!, c] = values
			end
		end
	end
	df
end


"""calculate scores"""
function calc_scores(scale::Questionnaire, quest_data::DataFrame)
	it = items(scale, quest_data;
		recode = true, invert = true, add_columns = nothing)
	sum(eachcol(it))
end


