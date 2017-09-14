#!/usr/local/bin/python

#
#  tr12649prepFullSize.py
###########################################################################
#
#  Purpose:
#
#      This script will create the input files for the GXD image load to
#      load the fullsize images.
#
#  Usage:
#
#      tr12649prepFullSize.py
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
#           1) PIX ID (####)
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
imageType = os.environ['IMAGETYPE']

copyright = '''Questions regarding the expression data or their use in publications should be directed to Tom Freeman (tom.freeman@roslin
.ed.ac.uk).'''

caption = '''Image(s) contributed directly to GXD by the GUDMAP database.  Zoom capability for the image(s) can be accessed via the GUD
MAP link at the bottom of this page.  GUDMAP provided the following information: image1.jpeg - High magnification showing the nephric duct (middle left) and ureteric bud (middle) which show no specific expression.  The metanephric mesenchyme shows some medium-strong expression, especially along its dorsal side, close to the ureteric bud; image2.jpeg - 10x  Caudal end of embryo on Right, hindlimb bud visible.  Medium-strong expression is visible dorsal to the metanephric mesenchyme.'''

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
	pixID = tokens[1]
	figureLabel = jpg.replace('.jpg', '')

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
