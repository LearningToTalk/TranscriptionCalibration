# calibrateNonwordTranscription.praat

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

@startup_location()
@calibration_filepaths()
@startup_calibration_file()
# appendInfoLine("You can now proceed")
.procedure$ = "calibration"

# Export values to global namespace
calibrationObject$ = startup_calibration_file.calibrationObjectName$
calibrationBasename$ = startup_calibration_file.calibrationBasename$
soundObject$ = startup_calibration_file.soundObjectName$
audioBasename$ = startup_calibration_file.audioBasename$
segmObject$ = startup_calibration_file.segmObjectName$
segmBasename$ = startup_calibration_file.segmBasename$

# Some other values that maybe don't belong here?
resolution_tier = 1
tr1_seg1_tier = 3
word_tier = 2

# Open the segmObject$ in another Edit window.
selectObject(segmObject$)
Edit

# Open the calibrationObject and the soundObject$ together in an edit window. 
selectObject(calibrationObject$)
plusObject(soundObject$)
Edit

# Count the number of points in the first tier of the calibrationObject$
selectObject(calibrationObject$)
num_points = Get number of points: resolution_tier
current_point = 1

# The nodes for the calibration loop.  Currently only 3, because we haven't modularized yet. 
calib_node_next_point$ = "next_point"
calib_node_quit$ = "quit"
calib_node_extract_snippet$ = "extract_snippet"

calib_node$ = calib_node_next_point$

# [LOOP THROUGH CALIBRATION POINTS]
while (current_point < (num_points + 1)) and (calib_node$ != calib_node_quit$)
	# Get the next transcribed production that needs to examined. 
	selectObject(calibrationObject$)
	calib_tag_time = Get time of point: resolution_tier, current_point
	segm_num = Get interval at time: tr1_seg1_tier, calib_tag_time
	segmentXMin = Get start point: tr1_seg1_tier, segm_num
	segmentXMax = Get end point: tr1_seg1_tier, segm_num

	# Get the associated trial number and word from the segmObject$
	selectObject(segmObject$)
	trial_num = Get interval at time: word_tier, calib_tag_time
	word$ = Get label of interval: word_tier, trial_num

	# Zoom to the current production.
	editor 'calibrationObject$'
		Zoom: segmentXMin - 0.25, segmentXMax + 0.25
	endeditor

##### Following should probably become a procedure  that is called at this point in the script? 
	# Invite the transcribers to examine the production and make a note. 
	beginPause("Examine transcription(s)")

		comment("Enter a note about the transcription(s) of this production below: ")
		text("transcription_notes", "")

		comment("Should an audio and textgrid snippet be extracted for this trial?")
		boolean("Extract snippet", 0)
		
	button = endPause("Quit (without doing anything)", "Save this note and/or snippet!", 2, 1)

	if button == 1
		calib_node$ = calib_node_quit$
	else
		.notes$ = transcription_notes$
		.no_notes = length(.notes$) == 0
		if !.no_notes
			selectObject(calibrationObject$)
			Insert point: resolution_tier, calib_tag_time, .notes$
			Save as text file: startup_calibration_file.calibrationFilePathname$
		endif

		if extract_snippet
			calib_node$ = calib_node_extract_snippet$
		endif
	endif


	# [EXTRACT AND SAVE SNIPPET]
#### Issue: As soon as Mary or Pat has the time, this maybe should be rewritten as a call to a proc  
####    that is stored in a separate file, for use in other scripts such as the segmentation script.
	if calib_node$ == calib_node_extract_snippet$
		# Extract and save a snippet only if the extract_snippet box was checked.
		@selectObject(soundObject$)
		Extract part: segmentXMin, segmentXMax, "rectangular", 1, "yes"
		@selectObject(calibrationObject$)
		Extract part: segmentXMin, segmentXMax, "yes"
		@selectObject(segmObject$)
		Extract part: segmentXMin, segmentXMax, "yes"
		# The extracted snippet collection will be named by the basename for the calibration
		# TextGrid plus the orthographic form for the nonword plus the calibration point number. 
		snippet_pathname$ = calibration_filepaths.calibSnippetDirectory$ + calibrationBasename$ + "_" + word$ +  ".Collection"
		# It will be saved as a binary praat .Collection file. 
		selectObject("Sound " + audioBasename$ + "_part")
		plusObject("TextGrid " + calibrationBasename$ + "_part")
		plusObject("TextGrid " + segmBasename$ + "_part")
		Save as binary file: snippet_pathname$
		# The three extracted bits are removed from the Objects: window afterwards.
		selectObject("Sound " + audioBasename$ + "_part")
		plusObject("TextGrid " + calibrationBasename$ + "_part")
		plusObject("TextGrid " + segmBasename$ + "_part")
		Remove
	endif

	# Increment and go on to next calibration point.
	current_point = current_point + 1
	calib_node$ = calib_node_next_point$

endwhile
