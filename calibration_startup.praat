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
		# then set the value of the .location$ variable
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
	# For now, just specify here.  
	.task$ = "NonWordRep"
	.testwave$ = "TimePoint1"

	.data_dir$ = "/DataAnalysis/" + .task$ + "/" + .testwave$ + "/"
	.audio_dir$ = startup_location.audio_drive$ + .data_dir$ + "Recordings/"
	.segmentation_dir$ = startup_location.drive$ + .data_dir$ + "Segmentation/TranscriptionReady/"
	.wordList_dir$ = startup_location.drive$ + .data_dir$ + "WordLists/"
	.calibSnippetDirectory$ = startup_location.drive$ + .data_dir$ + "Transcription/ExtractedSnippets/"
	.transTextGridsDirectory$ = startup_location.drive$ + .data_dir$ + "Transcription/TranscriptionTextGrids/"
	.calibTextGridsDirectory$ = startup_location.drive$ + .data_dir$ + "Transcription/CalibrationTextGrids/"


appendInfoLine(".audio_dir$: ", .audio_dir$)
appendInfoLine(".segmentation_dir$: ", .segmentation_dir$)
appendInfoLine(".wordList_dir$: ", .wordList_dir$)
appendInfoLine(".calibSnippetDirectory$: ", .calibSnippetDirectory$)
appendInfoLine("------ calibration_filepaths()")
appendInfoLine(".transTextGridsDirectory$: ", .transTextGridsDirectory$)
appendInfoLine(".calibTextGridsDirectory$: ", .calibTextGridsDirectory$)
endproc

# [NODE] Calibration textgrid specific start-up procedures.
procedure startup_calibration_textgrid_file()
appendInfoLine("")
appendInfoLine("------ startup_calibration_textgrid_file()")

	# For now, just specify the following variables here.  
	.task$ = "NonWordRep"
	lengthPID = 9
	# This makes for a potentially brittle specification for .experimental_ID$ below.

	# Check to see if the procedure is to create a calibration textgrid or to loop through an existing 
	# calibration textgrid to calibrate the transcriptions.
	if procedure$ == "create_textgrid"
		# Prompt the transcribers to open a transcription TextGrid file. 
		.transcriptionFilePathname$ = chooseReadFile$: "Open a transcription TextGrid file from the Transcription/TranscriptionTextGrids directory"
		if .transcriptionFilePathname$ <> ""
			object_num = Read from file: .transcriptionFilePathname$
		endif
		# Check to make sure that it was a TextGrid file. 
		.transcriptionObjectName$ = selected$()
		.transcriptionFileType$ = extractWord$ (.transcriptionObjectName$, "")
		if .transcriptionFileType$ <> "TextGrid"
			exitScript: "File '.transcriptionFilePathname$' was not a TextGrid file."
		endif
		# Determine the basename of the TextGrid Object that was read in.
		.calibrationObjectName$ = selected$()
		.calibrationBasename$ = extractWord$ (.calibrationObjectName$, " ")
		# Replace the "trans" with "calib" to differentiate.
		.calibrationBasename$ = .calibrationBasename$ - "trans" + "calib"

		# Rename the calibration object.
		selectObject(.calibrationObjectName$)
		Rename: .calibrationBasename$
		.calibrationObjectName$ = selected$()

		# Set the file pathname to which the object should be saved. 
		.calibrationFilePathname$ = calibration_filepaths.calibTextGridsDirectory$ + .calibrationBasename$ + ".TextGrid"

	endif
# appendInfoLine(".transcriptionFilePathname$: ", .transcriptionFilePathname$)
# appendInfoLine(".calibrationObjectName$: ", .calibrationObjectName$)
# appendInfoLine(".calibrationBasename$: ", .calibrationBasename$)
# appendInfoLine(".calibrationFilePathname$: ", .calibrationFilePathname$)

endproc

procedure startup_calibration_file()
# appendInfoLine("")
# appendInfoLine("------ startup_calibration_file()")

	# For now, just specify the following variables here.  
	tr1_seg1_tier = 3
	frameWB_tier = 7
	calibNotes_tier = 8
	# These are also in calibrateTranscription.praat, because Mary isn't sure where they should go.  

	# For now, just specify here.  
	.task$ = "NonWordRep"
	lengthPID = 9
	# The above makes for a potentially brittle specification for .experimental_ID$ below.

	# Prompt the transcribers to open a calibration TextGrid file. 
	.calibrationFilePathname$ = chooseReadFile$: "Open a calibration TextGrid file from the Transcription/CalibrationTextGrids directory"
	if .calibrationFilePathname$ <> ""
		object_num = Read from file: .calibrationFilePathname$
	endif
	# Check to make sure that it was a TextGrid file. 
	.calibrationObjectName$ = selected$()
	.calibrationFileType$ = extractWord$ (.calibrationObjectName$, "")
	if .calibrationFileType$ <> "TextGrid"
		exitScript: "File '.calibrationFilePathname$' was not a TextGrid file."
	endif
	# Determine the basename of the TextGrid Object that was read in.
	.calibrationObjectName$ = selected$()
	.calibrationBasename$ = extractWord$ (.calibrationObjectName$, " ")

	# Determine the experimental ID from the name of the TextGrid Object that was read in.
	# Following line is brittle, and might should be changed when we generalize.
	.experimental_ID$ = left$(.calibrationBasename$, length(.task$)+length("_")+lengthPID)

	# Check to see whether the frameWB ("frame WorldBet") tier and calibNotes tier have been created yet.
	selectObject(.calibrationObjectName$)
	num_tiers = Get number of tiers
	if (num_tiers < calibNotes_tier)
		make_tiers_flag = 1
	else
		frameWB_tier_name$ = Get tier name: frameWB_tier
		calibNotes_tier_name$ = Get tier name: calibNotes_tier
		if (frameWB_tier_name$ == "frameWB") and (calibNotes_tier_name$ == "calibNotes")
			make_tiers_flag = 0
		else
			make_tiers_flag = 1
		endif
	endif

	# If they haven't been created, create them.
	if (make_tiers_flag)
		selectObject(.calibrationObjectName$)
		Duplicate tier: tr1_seg1_tier, frameWB_tier, "frameWB"
		Insert point tier: calibNotes_tier, "calibNotes"
		Replace interval text: frameWB_tier, 0, 0, ".*", "", "Regular Expressions"
	endif

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

	# Open the associated wordlist Table file.
	Create Strings as file list: "fileList", calibration_filepaths.wordList_dir$ + .experimental_ID$ + "*"

	.wordListFilename$ = Get string: 1
	selectObject("Strings fileList")
	Remove
	wordList_pathname$ = calibration_filepaths.wordList_dir$ + .wordListFilename$
	if (fileReadable(wordList_pathname$))
		Read from file: wordList_pathname$
	else
		exitScript: "Error in reading file 'wordList_pathname$' "
	endif
	.wordListObjectName$ = selected$()
	.wordListBasename$ = .wordListFilename$ - ".txt"
appendInfoLine(".wordListObjectName$: ", .wordListObjectName$)
appendInfoLine(".wordListBasename$: ", .wordListBasename$)

endproc
