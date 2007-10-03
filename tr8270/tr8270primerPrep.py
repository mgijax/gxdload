#!/usr/local/bin/python

#
#  tr8270primerPrep.py
###########################################################################
#
#  Purpose:
#
#      This script will create an input file for the primer load using
#      certain fields from the strength/pattern input file.
#
#  Usage:
#
#      tr8270primerPrep.py
#
#  Env Vars:
#
#      REFERENCE
#      CREATEDBY
#      STR_PATT_FILE
#      PRIMERDATAFILE
#
#  Inputs:
#
#      StrengthPatternTrans.txt - Tab-delimited fields:
#
#          1) Marker MGI ID
#          2) Marker Symbol
#          3) Analysis ID
#          4) Probe ID
#          5) Probe Name
#          6) Specimen ID
#          7) Primer Name
#          8) Forward Primer
#          9) Reverse Primer
#          10) Strain ID
#          11) Strain MGI ID
#          12) Method ID
#          13) Accession Number
#          14) Expression level for structure 1
#          15) Pattern for structure 1
#          .
#          .  Repeat expression/pattern for each of the 100 structures.
#          .
#          .  NOTE: Not all structure numbers are found in the input file.
#          .
#          212) Expression level for structure 126
#          213) Pattern for structure 126
#          214) Probe Sequence
#
#  Outputs:
#
#      primer.txt - Tab-delimited fields:
#
#          1) Marker Symbol
#          2) Marker MGI ID
#          3) Primer Name
#          4) Reference (J:93300)
#          5) Region Covered
#          6) Sequence 1 (Forward Primer)
#          7) Sequence 2 (Reverse Primer)
#          8) Product Size
#          9) Notes
#          10) Sequence ID(s) (|-delimited)
#          11) Created By
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
#
#  Modification History:
#
#  Date        SE   Change Description
#  ----------  ---  -------------------------------------------------------
#
#  08/02/2007  DBM  Initial development
#
###########################################################################

import sys
import os
import string

#
#  CONSTANTS
#
REGION_COVERED = ''
PRODUCT_SIZE = ''
NOTES = ''
SEQ_IDS = ''

#
#  GLOBALS
#
jNumber = os.environ['REFERENCE']
createdBy = os.environ['CREATEDBY']

inputFile = os.environ['STR_PATT_FILE']
outputFile = os.environ['PRIMERDATAFILE']


#
# Open the input file.
#
try:
    fpIn = open(inputFile, 'r')
except:
    sys.stderr.write('Cannot open input file: ' + inputFile + '\n')
    sys.exit(1)

#
# Open the output file.
#
try:
    fpOut = open(outputFile, 'w')
except:
    sys.stderr.write('Cannot open output file: ' + outputFile + '\n')
    sys.exit(1)

#
# Read past the 2 headings in the input file.
#
line = fpIn.readline()
line = fpIn.readline()

#
# Process each line of the input file.
#
lineNum = 2
for line in fpIn.readlines():
    lineNum += 1

    #
    # Tokenize the input line and extract the fields that are needed for
    # the output file.
    #
    tokens = string.split(line[:-1], '\t')
    try:
        mgiID = tokens[0]
        markerSymbol = tokens[1]
        primerName = tokens[6]
        forwardPrimer = tokens[7]
        reversePrimer = tokens[8]
    except:
        sys.stderr.write('Invalid input line: ' + lineNum + '\n')
        sys.exit(1)

    #
    # If there is no primer, skip this input line.
    #
    if primerName == '':
        continue

    #
    # Write to the output file.
    #
    fpOut.write(markerSymbol + '\t' +
                mgiID + '\t' +
                primerName + '\t' +
                jNumber + '\t' +
                REGION_COVERED + '\t' +
                forwardPrimer + '\t' +
                reversePrimer + '\t' +
                PRODUCT_SIZE + '\t' +
                NOTES + '\t' +
                SEQ_IDS + '\t' +
                createdBy + '\n')

#
# Close the files.
#
fpIn.close()
fpOut.close()

sys.exit(0)
