
#
#  impclaczPrepFullSize.py
###########################################################################
#
#  Purpose:
#
#      This script will create the input files for the GXD image load to
#      load the fullsize images.
#
#  Usage:
#
#      impclaczPrepFullSize.py
#
#  Env Vars:
#
#      PIXELDBDATA
#      PIX_MAPPING
#      IMAGEFILE
#      IMAGEPANEFILE
#      REFERENCE
#
#  Inputs:
#
#      PIX_MAPPING Tab-delimited fields:
#
#          1) File name of the fullsize image that has been added to pixel DB
#          2) Accession number from pixel DB (numeric part)
#
#  Outputs:
#
#      IMAGEFILE - Tab-delimited fields:
#
#          1) Reference (J:171409)
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
#      IMAGEPANEFILE - Tab-delimited fields:
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
from PIL import Image

#
#  GLOBALS
#
# /data/pixeldb
pixelDBDir = os.environ['PIXELDBDATA'] 

# this is pixeload mapping file
pixFile = os.environ['PIX_MAPPING'] 

# gxdimageload IMG_Image input file
imageFile = os.environ['IMAGEFILE'] 

# gxdimageload IMG_Pane input file
imagePaneFile = os.environ['IMAGEPANEFILE'] 

# figure label file (this was grepped out of connie's file /mgi/all/wts_projects/13200/13240/imageload/image_loader.txt.lotsofblanklines
figureLabelFile =  os.environ['FIGURELABELFILE']

jNumber = os.environ['REFERENCE']
copyright = 'Questions regarding this image or its use in publications should be directed to the International Mouse Phenotyping Consortium (IMPC) at <A HREF="http://www.mousephenotype.org/contact-us">http://www.mousephenotype.org/contact-us</A>'


# {jpg name:prefix, ...}
figureLabelPrefixDict = {}

#
# Purpose: Open the files.
# Returns: Nothing
# Assumes: The names of the files are set in the environment.
# Effects: Sets global variables
# Throws: Nothing
#
def initialize ():
    global fpPixFile, fpImageFile, fpImagePaneFile, fpFigureLabelFile, figureLabelPrefixDict

    #
    # Open pixelDB mapping file.
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

    try:
        fpFigureLabelFile = open(figureLabelFile, 'r')
    except:
        sys.stderr.write('Cannot open input file: ' + figureLabelFile + '\n')
        sys.exit(1)

    for line in fpFigureLabelFile:
        prefix, name = str.split(line, '_')
        name = str.strip(name)
        figureLabelPrefixDict[name] = prefix
       
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

    for line in fpPixFile.readlines():

        tokens = str.split(line[:-1], '\t')
        jpgName = tokens[0]
        jpgName = jpgName.replace('.jpg', '')
        if jpgName not in figureLabelPrefixDict:
            print(('%s not in figureLabelPrefixDict' % jpgName))
            continue
        prefix = figureLabelPrefixDict[jpgName]
        figureLabel = '%s_%s' % (prefix, jpgName)
        pixID = tokens[1]

        figureLabel = figureLabel.replace('.jpg', '')

        image = '%s/%s.jpg' % (pixelDBDir, pixID)   
        im = Image.open(image)
        (xdim, ydim) = im.size
        print(('image: %s xdim: %s ydim: %s' % (image, xdim, ydim)))
        fpImageFile.write(jNumber + '\t' +
                          '\t' +
                          'Expression\t' +
                          pixID + '\t' +
                          str(xdim) + '\t' +
                          str(ydim) + '\t' +
                          figureLabel + '\t' +
                          copyright + '\t' +
                          '\t' +
                          '\n')

        fpImagePaneFile.write(pixID + '\t\t' + str(xdim) + '\t' + str(ydim) + '\n')

    return 0

#
# Main
#
print('initializing')
initialize()
print('processing')
process()
print('closing files')
closeFiles()

sys.exit(0)
