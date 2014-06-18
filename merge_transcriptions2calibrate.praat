# merge_transcriptions2calibrate.praat

# procedure open_transcription_files()

	# Some variables to help extract the experimental_ID$ which, for now, we just specify here.  
	.task$ = "NonWordRep"
	lengthPID = 9
	# The above makes for a potentially brittle specification for .experimental_ID$ below.

	# Prompt the user to open the first of 2 transcription TextGrid files. 
	.transcriptionFilePathname$ = chooseReadFile$: "Open a file from the Transcription/TranscriptionTextGrids directory"
	if .transcriptionFilePathname$ <> ""
		object_num = Read from file: .transcriptionFilePathname$
	endif

	# Determine the basename of the TextGrid Object that was read in.
	.transcriptionObjectName1$ = selected$()
	.transcriptionBasename1$ = extractWord$ (.transcriptionObjectName1$, " ")

	# Determine the experimental ID from the name of the TextGrid Object that was read in.
	# Following line is brittle, and might should be changed when we generalize.
	.experimental_ID$ = left$(.transcriptionBasename1$, length(.task$)+length("_")+lengthPID)

	# Determine the initials of the transcriber. 
	.tr1$ =  mid$(.transcriptionBasename1$, length(.transcriptionBasename1$)-length("trans")-1, 2)

	# Prompt the user to open the second of 2 transcription TextGrid files. 
	.transcriptionFilePathname$ = chooseReadFile$: "Open another file from the Transcription/TranscriptionTextGrids directory"
	if .transcriptionFilePathname$ <> ""
		object_num = Read from file: .transcriptionFilePathname$
	endif

	# Determine the basename of the TextGrid Object that was read in.
	.transcriptionObjectName2$ = selected$()
	.transcriptionBasename2$ = extractWord$ (.transcriptionObjectName2$, " ")

	# Determine the experimental ID from the name of the TextGrid Object that was read in.
	# Following line is brittle, and might should be changed when we generalize.
	.experimental_ID2$ = left$(.transcriptionBasename2$, length(.task$)+length("_")+lengthPID)

	# Check it against the .experimental_ID$ from the first file. 
	if (.experimental_ID2$ <> .experimental_ID$)
		exitScript: "The two transcriptions must be for the same recordings."
	endif

	# Determine the initials of the transcriber of the second file. 
	.tr2$ =  mid$(.transcriptionBasename2$, length(.transcriptionBasename2$)-length("trans")-1, 2)

	# Check them against the initials of the transcriber for the first file. 
	if (.tr1$ == .tr2$)
		exitScript: "You need to choose two different transcriptions."
	endif

# endproc

# appendInfoLine(".transcriptionBasename1$: ", .transcriptionBasename1$)
# appendInfoLine(".tr1$: ", .tr1$)
# appendInfoLine(".transcriptionBasename2$: ", .transcriptionBasename2$)
# appendInfoLine(".tr2$: ", .tr2$)

# Merge the two TextGrid objects. 
selectObject: "TextGrid "+.transcriptionBasename1$
plusObject: "TextGrid "+.transcriptionBasename2$
Merge

# Add the transcriber's initials to the four transcription tiers.
Set tier name: 1, "Target1Seg" + .tr1$
Set tier name: 2,"Target2Seg "+ .tr1$
Set tier name: 3,"Prosody" + .tr1$
Set tier name: 4,"TransNotes" + .tr1$
Set tier name: 5,"Target1Seg" + .tr2$
Set tier name: 6,"Target2Seg" + .tr2$
Set tier name: 7,"Prosody" + .tr2$
Set tier name: 8,"TransNotes" + .tr2$

# Duplicate the first transcriber's tiers. 
Duplicate tier: 4, 1, "TransNotes"
Duplicate tier: 4, 1, "Prosody"
Duplicate tier: 4, 1, "Target2Seg"
Duplicate tier: 4, 1, "Target1Seg"

# Insert a tokens2check tier. 
Insert point tier: 1, "tokens2check"
# Initialize the n_inserts variable.
n_inserts = 0

# Count the intervals, check compatibility, and then loop through the transcribed intervals. 
n_words = Get number of intervals: 2
n_words2 = Get number of intervals: 10
if n_words <> n_words2
	exitScript: "Correct incompatible interval counts."
endif
for word_i from 1 to n_words
	# Initialize the inserted_mark flag, etc.
	inserted_mark = 0
	check_tag$ = "disagreed on: "
	# Check to see if this is an interval where transcriber 1 transcribed Target1Seg.  
	lab2$ = Get label of interval: 2, word_i
	if lab2$ <> ""
		# If it is, insert a point in the middle of the interval.  
		xmin = Get start point: 2, word_i
		xmax = Get end point: 2, word_i
		xmid = ('xmin' + 'xmax') / 2
		Insert point: 1, xmid, check_tag$
		n_inserts = n_inserts + 1
		inserted_mark = 1
		# Also, compare it to transcriber 2's transcription. 
		lab10$ = Get label of interval: 10, word_i
		if lab2$ <> lab10$
			Set interval text: 2, word_i, ""
			check_tag$ = check_tag$ + " Target1Seg, "
			Set point text: 1, n_inserts, check_tag$
		endif
	endif
	# Check also to see if this is an interval where transcriber 1 transcribed Target2Seg.  
	lab3$ = Get label of interval: 3, word_i
	if lab3$ <> ""
		# If it is, check to see if the inserted_mark flag is set, and if it's not 
		# insert a point in the middle of the interval. 
		if inserted_mark == 0
			xmin = Get start point: 2, word_i
			xmax = Get end point: 2, word_i
			xmid = ('xmin' + 'xmax') / 2
			Insert point: 1, xmid, "check"
			n_inserts = n_inserts + 1
			inserted_mark = 1
		endif
		lab11$ = Get label of interval: 11, word_i
		if (lab3$ <> lab11$)
			Set interval text: 3, word_i, ""
			check_tag$ = check_tag$ + " Target2Seg, "
			Set point text: 1, n_inserts, check_tag$
		endif
	endif
	# Check also to see if this is an interval where transcriber 1 transcribed Prosody.  
	lab4$ = Get label of interval: 4, word_i
	if lab4$ <> ""
		# If it is, check to see if the inserted_mark flag is set, and if it's not 
		# insert a point in the middle of the interval. 
		if inserted_mark <> 1
			xmin = Get start point: 2, word_i
			xmax = Get end point: 2, word_i
			xmid = ('xmin' + 'xmax') / 2
			Insert point: 1, xmid, "check"
			n_inserts = n_inserts + 1
			inserted_mark = 1
		endif
		lab12$ = Get label of interval: 12, word_i
		if (lab4$ <> lab12$)
			Set interval text: 4, word_i, ""
			check_tag$ = check_tag$ + " Prosody, "
			Set point text: 1, n_inserts, check_tag$
		endif
	endif
	if (check_tag$ == "disagreed on: ") & (inserted_mark == 1) 
		Set point text: 1, n_inserts, "agreed"
	endif
endfor

# Insert the resolution tier. 
Duplicate tier: 1, 1, "resolution"
Replace point text: 1, 0, 0, ".*", "", "Regular Expressions"

# Save the merged file. 
dir$ = "/Volumes/tier2/DataAnalysis/NonWordRep/TimePoint1/Transcription/CalibrationTextGrids/"

calibration_pathname$ = dir$ + .experimental_ID$ + "_" + .tr1$ + "_" + .tr2$ + "_interTrans.TextGrid"
Save as text file: calibration_pathname$