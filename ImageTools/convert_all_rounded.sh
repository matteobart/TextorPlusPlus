# this works for pngs, haven't tried other file types
for FILE in *; do
	if [[ $FILE != $0 ]]; then  
		NEWFILE=rounded_$FILE
		echo $NEWFILE
		convert $FILE \( +clone -alpha extract \( -size 15x15 xc:black -draw 'fill white circle 15,15 15,0' -write mpr:arc +delete \) \( mpr:arc \) -gravity northwest -composite \( mpr:arc -flip \) -gravity southwest -composite \( mpr:arc -flop \) -gravity northeast -composite \( mpr:arc -rotate 180 \) -gravity southeast -composite \) -alpha off -compose CopyOpacity -composite -compose over \( +clone -background black -shadow 80x3+5+5 \) +swap -background none -layers merge $NEWFILE
	fi
done
