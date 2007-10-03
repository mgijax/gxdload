#!/usr/local/bin/python

#
#  tr8270probePrep.py
###########################################################################
#
#  Purpose:
#
#      This script will create an input file for the probe load using
#      certain fields from the strength/pattern input file.
#
#  Usage:
#
#      tr8270probePrep.py
#
#  Env Vars:
#
#      REFERENCE
#      CREATEDBY
#      STR_PATT_FILE
#      PROBEDATAFILE
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
#          1) Probe Name
#          2) Reference (J:93300)
#          3) Source Name
#          4) Organism
#          5) Strain
#          6) Tissue
#          7) Gender
#          8) Cell Line
#          9) Age
#          10) Vector Type
#          11) Segment Type
#          12) Region Covered
#          13) Insert Site
#          14) Insert Size
#          15) Marker MGI ID
#          16) Relationship
#          17) Sequence ID(s) (LogicalDB:AccID|...)
#          18) Notes
#          19) Created By
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
#  08/07/2007  DBM  Initial development
#
###########################################################################

import sys
import os
import string
import db

#
#  CONSTANTS
#
SOURCE_NAME = ''
ORGANISM = 'mouse, laboratory'
STRAIN = 'Not Specified'
TISSUE = 'Not Specified'
GENDER = 'Not Specified'
CELL_LINE = 'Not Applicable'
AGE = 'Not Specified'
VECTOR_TYPE = 'Not Specified'
SEGMENT_TYPE = 'cDNA'
REGION_COVERED = ''
INSERT_SITE = ''
INSERT_SIZE = ''
RELATIONSHIP = 'E'
SEQ_IDS = ''
NOTE = 'Probe insert was amplified by RT-PCR (see %s for primer sequences).  '

#
#  GLOBALS
#
jNumber = os.environ['REFERENCE']
createdBy = os.environ['CREATEDBY']

inputFile = os.environ['STR_PATT_FILE']
outputFile = os.environ['PROBEDATAFILE']


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
# Get a list of MGI IDs and primer names for the primers that were loaded.
#
results = db.sql('select a.accID, p.name ' + \
                 'from ACC_Accession a, PRB_Probe p, PRB_Reference_View rv ' + \
                 'where a._MGIType_key = 3 and ' + \
                       'a._Object_key = p._Probe_key and ' + \
                       'p._SegmentType_key = 63473 and ' + \
                       'p._Probe_key = rv._Probe_key and ' + \
                       'rv.jnumID = "%s"' %(jNumber), 'auto')

#
# Build a lookup to find the MGI ID for a primer name.
#
primer = {}
for r in results:
    primer[r['name']] = r['accID']

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
        probeName = tokens[4]
        primerName = tokens[6]
        probeSeq = tokens[213]
    except:
        sys.stderr.write('Invalid input line: ' + lineNum + '\n')
        sys.exit(1)

    #
    # If there is a primer, use the name to look up the MGI ID and use it in
    # the first part of the notes.
    #
    notes = ''
    if primerName != '':
        if primer.has_key(primerName):
            notes = NOTE % (primer[primerName])
        else:
            sys.stderr.write('Cannot find primer MGI ID: ' + primerName + '\n')
            sys.exit(1)

    #
    # Add the probe sequence to the notes.
    #
    notes = notes + probeSeq

    #
    # Write to the output file.
    #
    fpOut.write(probeName + '\t' +
                jNumber + '\t' +
                SOURCE_NAME + '\t' +
                ORGANISM + '\t' +
                STRAIN + '\t' +
                TISSUE + '\t' +
                GENDER + '\t' +
                CELL_LINE + '\t' +
                AGE + '\t' +
                VECTOR_TYPE + '\t' +
                SEGMENT_TYPE + '\t' +
                REGION_COVERED + '\t' +
                INSERT_SITE + '\t' +
                INSERT_SIZE + '\t' +
                mgiID + '\t' +
                RELATIONSHIP + '\t' +
                SEQ_IDS + '\t' +
                notes + '\t' +
                createdBy + '\n')

#
# Close the files.
#
fpIn.close()
fpOut.close()

sys.exit(0)
