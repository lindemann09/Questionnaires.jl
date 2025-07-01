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
			values = quest_data[!, c]
			# recode
			if recode
				#check if all values are a known factor level
				for x in Set(skipmissing(values))
					x ∈ quest.scale.levels ||
							throw(ArgumentError("'"*string(x)* "' is a unknown level."))
				end
				values = CategoricalArrays.recode(values, quest.scale.pairs...)
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
function calc_scores(scale::Questionnaire, quest_data::DataFrame;
		average::Bool=false,
		skip_missing::Bool=false)
	it = items(scale, quest_data;
		recode = true, invert = true, add_columns = nothing)
	n_answers = length(scale.items) .- count_missing(it)

	if skip_missing
		sum_scores = Union{Missing, Int64}[]
		for (n, r) in zip(n_answers, eachrow(it))
			if n == 0
				push!(sum_scores, missing) # no valid response
			else
				push!(sum_scores, sum(skipmissing(r))) # error is skipmissing(r) is empty
			end
		end
	else
		sum_scores = sum(eachcol(it))
	end

	if average
		return sum_scores ./ n_answers
	else
		return sum_scores
	end
end

function count_missing(scale::Questionnaire, quest_data::DataFrame)
    it = items(scale, quest_data;
		recode = true, invert = true, add_columns = nothing)
    return count_missing(it)
end

count_missing(df::DataFrame) = [count(ismissing, row) for row in eachrow(df)];

