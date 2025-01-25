
"""Qualtrics data"""
function read_qualtrics_xlsx(xlsx_file::String; sheet::Int = 1,
	system_columns::Bool = false)
	dat = XLSX.readtable(xlsx_file, sheet)
	#pop second row from data
	second_row = [popfirst!(x) for x in dat.data]
	desc = Dict()
	for (l, d) in zip(dat.column_labels, second_row)
		push!(desc, String(l) => d)
	end
	rtn = rename(DataFrame(dat), "Duration (in seconds)" => :Duration)
	if !system_columns
		rtn = select(
			rtn,
			Not([:StartDate, :EndDate, :Status, :IPAddress, :Finished,
				:RecordedDate, :ResponseId, :RecipientLastName, :RecipientFirstName,
				:RecipientEmail, :ExternalReference, :LocationLatitude, :LocationLongitude,
				:DistributionChannel, :UserLanguage]),
		)
	end
	return rtn, desc
end
;
