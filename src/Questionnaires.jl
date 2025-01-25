module Questionnaires

using DataFrames
using XLSX
using CategoricalArrays

export Questionnaire,
        LikertScale,
        items,
        calc_scores,
        read_qualtrics_xlsx


include("likert_scale.jl")
include("questionnaire.jl")
include("qualtrics.jl")

end
