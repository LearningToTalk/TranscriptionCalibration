# create_calibration_textgrid.praat

## Controls whether the @log_[...] procedures write to the InfoLines.
# debug_mode = 1

include check_version.praat

#### Start of list of other files that we may eventually want to include or cannibalize. 
# Include these other files that have already modularized code.
# include procs.praat
# include segment_features.praat
# include startup_procs.praat
#### End of what we may eventually want to include. 

include calibration_startup.praat

procedure$ = "create_textgrid"

@startup_location()
@calibration_filepaths()
@startup_calibration_textgrid_file()
appendInfoLine("You can now proceed")

# Export values to global namespace
calibrationObject$ = startup_calibration_textgrid_file.calibrationObjectName$
calibrationFilePathname$ = startup_calibration_textgrid_file.calibrationFilePathname$

appendInfoLine("")
appendInfoLine("------ create_calibration_textgrid ")
appendInfoLine("calibrationObject$ ", calibrationObject$)
appendInfoLine("calibrationFilePathname$ ", calibrationFilePathname$)

# Calibration textgrid tier numbers. 
resolution_tier = 1
tokens2check = 1
tr1_seg1_tier = 1
tr1_seg2_tier = 2
tr1_prosody_tier = 3
tr1_notes_tier = 4
# Segmentation textgrid tier numbers. 
word_tier = 2

# Set a flag for whether the notes tier was empty.
selectObject(calibrationObject$)
num_prior_notes = Get number of points: tr1_notes_tier

# Copy the notes tier to make the initial tokens2check tier.
selectObject(calibrationObject$)
Duplicate tier: tr1_notes_tier, 1, "tokens2check"
tr1_seg1_tier = tr1_seg1_tier + 1
tr1_seg2_tier = tr1_seg2_tier + 1
tr1_prosody_tier = tr1_prosody_tier + 1
tr1_notes_tier = tr1_notes_tier + 1


# Create a Table of transcribed intervals for Target1Seg and Target2Seg. 
selectObject(calibrationObject$)
Extract one tier: tr1_seg1_tier
selectObject(calibrationObject$)
Extract one tier: tr1_seg2_tier
selectObject("TextGrid Target1Seg")
plusObject("TextGrid Target2Seg")
Merge
Down to Table: "no", 6, "no", "no"

# selectObject("TextGrid Target1Seg")
# plusObject("TextGrid Target2Seg")
# plusObject("TextGrid merged")
# Remove

# Loop through the rows of this merged Table searching for tokens that were 
# transcribed as "Other", "Omitted", or "Unclassifiable" and adding to existing 
# tags on the tokens2check tier or adding new points with relevant tags in case 
# there is not already a tag for that transcribed interval on the tokens2check tier. 
selectObject("Table merged")
number_rows = Get number of rows
for this.row from 1 to number_rows
	selectObject("Table merged")
	this_XMin = Get value: this.row, "tmin"
	this_XMax = Get value: this.row, "tmax"
	this_XMid = 0.5 * (this_XMin + this_XMax)
	this_label$ = Get value: this.row, "text"
	if (this_label$ == "Omitted;Omitted,Omitted,Omitted;0")
		this_label$ = "deleted segment, check prosody"
	elsif (this_label$ == "Unclassifiable;Unclassifiable,Unclassifiable,Unclassifiable;0")
		this_label$ = "unclassifiable segment, listen together"
	elsif (this_label$ == "Other;TBA,TBA,TBA;0")
		this_label$ = "new proposed other, confer"
	else
		this_label$ = ""
	endif

	if this_label$ <> ""
		if (num_prior_notes == 0)
			selectObject(calibrationObject$)
			Insert point:  tokens2check, this_XMid, this_label$
			num_prior_notes = 1
		else
			selectObject(calibrationObject$)
			index_nearest_XMin = Get nearest index from time: tokens2check, this_XMin
			time_index_nearest_XMin = Get time of point: tokens2check, index_nearest_XMin
			if (time_index_nearest_XMin > this_XMin) and (time_index_nearest_XMin < this_XMax)
				add2label$ = Get label of point: tokens2check, index_nearest_XMin
				Set point text: tokens2check, index_nearest_XMin, "'this_label$'; 'add2label$'"
			else
				Insert point:  tokens2check, this_XMid, this_label$
			endif
		endif
	endif

endfor

# Duplicate the tokens2check tier to the resolution tier. 
selectObject(calibrationObject$)
Duplicate tier: 1, 1, "resolution"
# Delete all of the text on that tier. 
Replace point text: 1, 0, 0, ".*", "", "Regular Expressions"

# Save the file.
selectObject(calibrationObject$)
Save as text file: calibrationFilePathname$
