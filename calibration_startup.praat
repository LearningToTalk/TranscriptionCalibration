# [STARTUP WIZARD EVENT LOOP]

####  Here's what we will do for now, to get this going quick and dirty. 

# Values for .result_node$
node_quit$ = "quit"
node_next$ = "next"
node_back$ = "back"

# Map a .result_node$ value onto the name of node in the wizard.
procedure next_back_quit(.status$, .next_step$, .last_step$, .quit$) 
	if .status$ == node_next$
		.result$ = .next_step$
	elsif .status$ == node_back$
		.result$ = .last_step$
	else
		.result$ = .quit$
	endif
endproc

# [NODE] Get the location where the transcribers are working from
procedure startup_location()
	beginPause ("'procedure$' - Initializing session, step 1.")
		# Prompt the user to specify where the script is being run.
		comment ("Please specify where the machine is on which you are working.")
			optionMenu ("Location", 1)
			option ("WaismanLab")
			option ("ShevlinHallLab")
			option ("Mac via RDC")
			option ("Mac via VPN")
			option ("Other (Beckman)")
			option ("Other (not Beckman)")
	button = endPause ("Quit", "Continue", 2)

	# Use the 'button' variable to determine which node to transition to next.
	if button == 1
		.result_node$ = node_quit$
	else
		# If the segmenter has entered a location and wishes to continue
		#  to the next step of the start-up procedure (button = 2),
		# then set the value of the .initials$ variable
		.location$ = location$
		# Use the value of the '.location$' variable to set up the 'drive$' variables.
		if (.location$ == "WaismanLab")
			.drive$ = "L:/"
			.audio_drive$ = "L:/"
		elsif (.location$ == "ShevlinHallLab")
			.drive$ = "//l2t.cla.umn.edu/tier2/"
			.audio_drive$ = "//l2t.cla.umn.edu/tier2/"
		elsif (.location$ == "Mac via RDC")
			.drive$ = "I:/"
			.audio_drive$ = "I:/"
		elsif (.location$ == "Mac via VPN")
			.drive$ = "/Volumes/tier2/"
			.audio_drive$ = "/Volumes/tier2onUSB/"
		elsif (.location$ == "Other (Beckman)")
			.drive$ = "/Volumes/tier2/"		
			.audio_drive$ = "/LearningToTalk/Tier2/"
		elsif (.location$ == "Other (not Beckman)")
			exit Contact Mary Beckman and your segmentation guru to request another location
		endif
		.result_node$ = node_next$
	endif
endproc

procedure calibration_filepaths()
	.audio_dir$ = startup_location.audio_drive$ + "/DataAnalysis/NonWordRep/TimePoint1/Recordings/"
	.segmentation_dir$ = startup_location.drive$ + "DataAnalysis/NonWordRep/TimePoint1/Segmentation/TranscriptionReady/"
	.calibSnippetDirectory$ = startup_location.drive$ + "DataAnalysis/NonWordRep/TimePoint1/Transcription/ExtractedSnippets/"

# appendInfoLine(".audio_dir$: ", .audio_dir$)
# appendInfoLine(".segmentation_dir$: ", .segmentation_dir$)
# appendInfoLine(".calibSnippetDirectory$: ", .calibSnippetDirectory$)
endproc

# [NODE] Calibration specific start-up procedures.
procedure startup_calibration_file()
	# For now, just specify here.  This makes for a potentially brittle specification for .experimental_ID$ below.
	.task$ = "NonWordRep"
	lengthPID = 9
	# Prompt the transcribers to open a TextGrid file. 
	.calibrationFilePathname$ = chooseReadFile$: "Open a calibration TextGrid file from the Transcription/CalibrationTextGrids directory"
	if .calibrationFilePathname$ <> ""
		object_num = Read from file: .calibrationFilePathname$
	endif
	# Check to make sure that it was a TextGrid file. 
	.calibrationObjectName$ = selected$()
	.calibrationFileType$ = extractWord$ (.calibrationObjectName$, "")
	if .calibrationFileType$ <> "TextGrid"
		exitScript: "File '.calibrationFileType$' was not a TextGrid file."
	endif
	# Determine the experimental ID from the name of the TextGrid Object that was read in.
	.calibrationObjectName$ = selected$()
	.calibrationBasename$ = extractWord$ (.calibrationObjectName$, " ")
	# Following line is brittle, and might should be changed when we generalize.
	.experimental_ID$ = left$(.calibrationBasename$, length(.task$)+length("_")+lengthPID)
# appendInfoLine(".calibrationObjectName$: ", .calibrationObjectName$)
# appendInfoLine(".calibrationBasename$: ", .calibrationBasename$)

	# Open the associated audio file.
	audio_pathname$ = calibration_filepaths.audio_dir$ + .experimental_ID$ + ".WAV"
	if (fileReadable(audio_pathname$))
		Read from file: audio_pathname$
	else
		audio_pathname$ = calibration_filepaths.audio_dir$ + .experimental_ID$ + ".wav"
		if (fileReadable(audio_pathname$))
			Read from file: audio_pathname$
		else
			exitScript: "Error in reading file 'audio_pathname$' "
		endif
	endif
	.soundObjectName$ = selected$()
	.audioBasename$ = extractWord$ (.soundObjectName$, " ")
# appendInfoLine(".soundObjectName$: ", .soundObjectName$)
# appendInfoLine(".audioBasename$: ", .audioBasename$)

	# Open the associated segmentation TextGrid file.
	Create Strings as file list: "fileList", calibration_filepaths.segmentation_dir$ + .experimental_ID$ + "*"

	.segmFilename$ = Get string: 1
	selectObject("Strings fileList")
	Remove
	segm_pathname$ = calibration_filepaths.segmentation_dir$ + .segmFilename$
	if (fileReadable(segm_pathname$))
		Read from file: segm_pathname$
	else
		exitScript: "Error in reading file 'segm_pathname$' "
	endif
	.segmObjectName$ = selected$()
	.segmBasename$ = .segmFilename$ - ".TextGrid"
# appendInfoLine(".segmObjectName$: ", .segmObjectName$)
# appendInfoLine(".segmBasename$: ", .segmBasename$)

endproc
