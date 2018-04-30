#!/bin/bash
	ffprobe -v error -show_streams -select_streams a:0 -show_chapters "$1" > tmp.txt
	DIR=$(dirname "$1")

	while IFS== read -r key val
	do
		if [[ $key = bit_rate ]]; then
			BITRATE=$val
		fi

		if [[ $key = \[CHAPTER\] ]]; then
			while IFS== read -r key val
			do
				if [[ $key = id ]]; then
					ID=$val
				fi
				if [[ $key = start_time ]]; then
					STARTTIME=$val
				fi
				if [[ $key = end_time ]]; then
					ENDTIME=$val
				fi
				if [[ $key = TAG:title ]]; then
					TITLE=$val
				fi
				if [[ $key = \[\/CHAPTER\] ]]; then
					ffmpeg -vsync 2 -i "$1" -ss "${STARTTIME%?}" -to "$ENDTIME" -c:a libmp3lame "$DIR/$TITLE.mp3" </dev/null
					break
				fi
			done
		fi
	done < tmp.txt
	rm tmp.txt
