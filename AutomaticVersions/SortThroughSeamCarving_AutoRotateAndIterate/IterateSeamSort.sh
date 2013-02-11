#!/bin/bash

# SEAM SORTING - ROTATE AND ITERATE
# Jeff Thompson | 2013 | www.jeffreythompson.org
#
# Automatically load a folder of images and process
# via a Processing sketch exported as a Mac OSX application.
#
# ARGUMENTS (required):
# 1. filename to load (full path)
# 2. output location (folder)
# 2. # of iterations for each image (default 2)
# 3. regular sorting (true, default) or toxi (false, seems to be broken)
# 4. reverse order of seam (default false)
#
# NEED TO BATCH ROTATE THE RESULTS TO THE SAME ORIENTATION?
# Using ImageMagick, this is easy! Specify below to add to the script,
# or use the commands below after the fact:
# 1. navigate to the folder of images
#      $ cd [drag folder into Terminal window for full path]
# 2. rotate (note: this will overwrite ALL files!)
#      $mogrify -verbose -rotate "90<" *
#    verbose option shows what's happening, especially nice when
#    working with lots of image files


# must be a full path
inputName="bowl_of_fruit"
inputLocation="/Volumes/Storage/Documents/Processing/PixelSorting/SourceImageFiles/$inputName/"

numIterations="10"					# how many times to rotate and sort
regularSorting="true"				# use Processing (true) or Toxi (false) color sorting
reverseOrder="false"				# reverse order of seam
outputLocation="$PWD/$inputName"	# save files to current directory in folder with the input name

rotateResults=false					# when done, rotate all the images?

# let us know we're in the right place
echo " "
echo "INPUT:   $inputLocation"
echo "OUTPUT:  $outputLocation"
echo " "

# go!
shopt -s nullglob													# error handling if there are no image files
for imageFile in `ls $inputLocation*.{jpg,jpeg,png,gif,tif,tiff}`	# find and process ALL image files in the folder!
do

	# run Processing sketch as a Mac app (the '&' means run in the background - much nicer but will load ALL at the same time...)
	./SortThroughSeamCarving_AutoRotateAndIterate.app/Contents/MacOS/JavaApplicationStub $imageFile $outputLocation $numIterations $regularSorting $reverseOrder
done

# rotate results, if specified
if $rotateResults; then
	echo "Rotating sorted images (this may take quite a while)..."
	cd $outputLocation
	mogrify -verbose -rotate "90<" *
fi

# done!
echo "ALL DONE!"