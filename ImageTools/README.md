## Add Rounded Border to PNG

This script can turn your image into an image with rounded edges. This has only been tested with *png* images. So try at your own risk.

This is used for the images in the Tools page. 

### Before
![Image without Rounded Edges](icon_no_rounded.png)

### After
![Image with Rounded Edges](icon_with_rounded.png)

## Convert One File

If you just have one image to do just run this command: 
`convert path/to/source.png \( +clone -alpha extract \( -size 15x15 xc:black -draw 'fill white circle 15,15 15,0' -write mpr:arc +delete \) \( mpr:arc \) -gravity northwest -composite \( mpr:arc -flip \) -gravity southwest -composite \( mpr:arc -flop \) -gravity northeast -composite \( mpr:arc -rotate 180 \) -gravity southeast -composite \) -alpha off -compose CopyOpacity -composite -compose over \( +clone -background black -shadow 80x3+5+5 \) +swap -background none -layers merge /path/to/destination.png`

Thanks to fmw42 from the [imagemagick forums](https://www.imagemagick.org/discourse-server/viewtopic.php?t=32651)


## Convert Multiple Files

Or if you want to translate a bunch of files at once. We got a great sh file for you.
Drop the sh file (convert_all_rounded.sh) into the folder with just the png files. Then run `sh convert_all_rounded.sh` this will create new pngs with rounded edges. 

### Note
 * Make sure the images are all png files
 * Make sure the filenames do **NOT** contain spaces

## Dependencies
You'll need to have `imagemagick` and whatever it's dependencies are.

On Mac: `brew install imagemagick` assuming that you have Homebrew. 
