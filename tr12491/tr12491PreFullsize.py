#!/usr/local/bin/python

#
#  tr12491PrepFullSize.py
###########################################################################
#
#  Purpose:
#
#      This script will create the input files for the GXD image load to
#      load the fullsize images.
#
#  Usage:
#
#      tr12491PrepFullSize.py
#
#  Env Vars:
#
#      PIXELDBDATA
#      IMAGE_FILE
#      IMAGEPANE_FULLSIZE
#      REFERENCE
#
#  Inputs:
#
#      PIX_MAPPING- Tab-delimited fields:
#
#          1) File name of the fullsize image that has been added to pixel DB
#          2) Accession number from pixel DB (numeric part)
#
#  Outputs:
#
#      IMAGE_FILE - Tab-delimited fields:
#
#          1) Reference (J:226028)
#          2) Fullsize image key (blank)
#          3) Image Class (_Vocab_key = 83)
#          4) Pixel DB accession number (numeric part)
#          5) X dimension of the image
#          6) Y dimension of the image
#          7) Figure label
#          8) Copyright note
#          9) Caption note
#          10) Image info
#
#      IMAGEPANE_FILE - Tab-delimited fields:
#
#           1) PIX ID (PIX:####)
#           2: Pane Label
#           3) X Dimension (width)
#           4) Y Dimension (heigth)
#
#  Exit Codes:
#
#      0:  Successful completion
#      1:  An exception occurred
#
#  Assumes:  Nothing
#
#  Notes:  None
#
###########################################################################

import sys
import os
import string
import jpeginfo

#
#  CONSTANTS
#
FULLSIZE_IMAGE_KEY = ''
URL = ''

#
#  GLOBALS
#
pixelDBDir = os.environ['FULLSIZE_IMAGE_DIR']
pixFile = os.environ['PIX_FULLSIZE']
imageFile = os.environ['IMAGEFILE']
imagePaneFile = os.environ['IMAGEPANEFILE']
jNumber = os.environ['REFERENCE']
copyright = os.environ['COPYRIGHTFILE']
caption = os.environ['CAPTIONFILE']
imageType = os.environ['IMAGETYPE']

#
# Purpose: Open the files.
# Returns: Nothing
# Assumes: The names of the files are set in the environment.
# Effects: Sets global variables
# Throws: Nothing
#
def initialize ():
    global fpPixFile, fpImageFile, fpImagePaneFile

    #
    # Open pixelDB file.
    #
    try:
        fpPixFile = open(pixFile, 'r')
    except:
        sys.stderr.write('Cannot open input file: ' + pixFile + '\n')
        sys.exit(1)

    #
    # Open the output files.
    #
    try:
        fpImageFile = open(imageFile, 'w')
    except:
        sys.stderr.write('Cannot open output file: ' + imageFile + '\n')
        sys.exit(1)

    try:
        fpImagePaneFile = open(imagePaneFile, 'w')
    except:
        sys.stderr.write('Cannot open output file: ' + imagePaneFile + '\n')
        sys.exit(1)

    return


#
# Purpose: Close the files.
# Returns: Nothing
# Assumes: Nothing
# Effects: Nothing
# Throws: Nothing
#
def closeFiles ():
    fpPixFile.close()
    fpImageFile.close()
    fpImagePaneFile.close()

    return


#
# Purpose: Create the image and image pane output files for each pixel DB
#          image that is being added.
# Returns: 0 if successful, 1 for an error
# Assumes: Nothing
# Effects: Nothing
# Throws: Nothing
#
def process ():

    #
    # Process each line of the input file.
    #
    counter = 0
    for line in fpPixFile.readlines():

	counter += 1

        tokens = string.split(line[:-1], '\t')
	jpg = tokens[0]
	pixID = 'PIX:' + tokens[1]
	figureLabel = jpg.rename('.jpg', '')

	(xdim, ydim) = jpeginfo.getDimensions(pixelDBDir + '/' + jpg)

	fpImageFile.write(jNumber + '\t' +
			  FULLSIZE_IMAGE_KEY + '\t' +
			  imageType + '\t' +
			  pixID + '\t' +
			  str(xdim) + '\t' +
			  str(ydim) + '\t' +
			  figureLabel + '\t' +
			  copyright + '\t' +
			  caption + '\t' +
			  URL + '\n')

	fpImagePaneFile.write(pixID + '\t\t' + str(xdim) + '\t' + str(ydim) + '\n')

    print counter
    return 0


#
# Main
#
print 'initializing'
initialize()
print 'processing'
process()
print 'closing files'
closeFiles()

sys.exit(0)
