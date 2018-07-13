#!/usr/local/bin/python

#
# Program: insitu.py
#
# Original Author: Lori Corbani
#
# Purpose:
#
#	To translate tr12900 LoadFile.txt file
#
# Requirements Satisfied by This Program:
#
# Usage:
#
#	insitu.py
#
# Envvars:
#
# Inputs:
#
#	a tab-delimited file in the format:
#		field 1: Probe ID                            : MGI:xxx
#		field 2: ProbePrepType                       : RNA
#		field 3: Hybridization                       : Antisense
#		field 4: LabelledWith                        : digoxigenin
#		field 5: VisualizedWith                      : Alkaline phosphatase
#		field 6: MGI Marker ID                       : MGI:xxx
#		field 7: Reference                           : J:215487
#		field 8: AssayType                           : RNA in situ
#		field 9: ReporterGene                        : null
#		field 10: AssayNote                          : 
#		field 11: CreatedBy                          : cms
#		field 12,21,30,39,48,57,66: SpecimenLabel    :
#		field 13,22,31,40,49,58,67: Genotype         : MGI:2166311
#		field 14,23,32,41,50,59,68: Age              :
#		field 15,24,33,42,51,60,69: AgeNote          : null
#		field 16,25,34,43,52,61,70: Sex              : Not Specified for youngest 2 ages; Male for rest
#		field 17,26,35,44,53,62,71: Fixation         : Fresh Frozen
#		field 18,27,36,45,54,63,72: Embedding Method : Cryosection
#		field 19,28,37,46,55,64,73: Hybridization    : section
#		field 20,29,38,47,56,65,74: SpecimenNote     : null
#		field 75,81,93,102,99,105,111: Strength      : Present (n=10,781), Absent (n=2,645)
#		field 76,82,94,103,100,106,112: Pattern      : Not Specified (n=10,781), Not Applicable (n=2,645)
#		field 77,83,95,104,101,107,113: Structure    : EMAPA:16894
#		field 78,84,96,105,102,108,114: TS           : 
#		field 79,85,97,106,103,109,115: Note         : null
#		field 80,86,98,107,104,110,116: Image        : null
#
# Outputs:
#
#       4 tab-delimited files:
#
#	In_Situ_probeprep.txt
#	In_Situ_assay.txt
#	In_Situ_specimen.txt
#	In_Situ_results.txt
#	
#       Error file
#
# Exit Codes:
#
# Assumes:
#
# Bugs:
#
# Implementation:
#

import sys
import os
import string
import db

TAB = '\t'		# tab
CRT = '\n'		# carriage return/newline
NULL = ''

inSpecimenFile = ''	# file descriptor

prepFile = ''           # file descriptor
assayFile = ''          # file descriptor
specimenFile = ''       # file descriptor
resultsFile = ''        # file descriptor

datadir = os.environ['PROJECTDIR']

inSpecimenFileName = os.environ['INPUT_FILE']

prepFileName = datadir + '/In_Situ_probeprep.txt'
assayFileName = datadir + '/In_Situ_assay.txt'
specimenFileName = datadir + '/In_Situ_specimen.txt'
resultsFileName = datadir + '/In_Situ_results.txt'

# Purpose: prints error message and exits
# Returns: nothing
# Assumes: nothing
# Effects: exits with exit status
# Throws: nothing

def exit(
    status,          # numeric exit status (integer)
    message = None   # exit message (string)
    ):

    if message is not None:
        sys.stderr.write('\n' + str(message) + '\n')
 
    sys.exit(status)
 
# Purpose: initialize
# Returns: nothing
# Assumes: nothing
# Effects: initializes global variables
#          exits if files cannot be opened
# Throws: nothing

def init():
    global inSpecimenFile
    global prepFile, assayFile, specimenFile, resultsFile
 
    try:
        inSpecimenFile = open(inSpecimenFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inSpecimenFileName)

    try:
        prepFile = open(prepFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % prepFileName)

    try:
        assayFile = open(assayFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % assayFileName)

    try:
        specimenFile = open(specimenFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % specimenFileName)

    try:
        resultsFile = open(resultsFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % resultsFileName)

    return

# Purpose:  processes data
# Returns:  nothing
# Assumes:  nothing
# Effects:  writes data to output files
# Throws:   nothing

def process():

    assayKey = 1
    specimenLookup = {}
    specimenProbeLookup = {}

#		field 1: Probe ID                            : MGI:xxx
#		field 2: ProbePrepType                       : RNA
#		field 3: Hybridization                       : Antisense
#		field 4: LabelledWith                        : digoxigenin
#		field 5: VisualizedWith                      : Alkaline phosphatase
#		field 6: MGI Marker ID                       : MGI:xxx
#		field 7: Reference                           : J:215487
#		field 8: AssayType                           : RNA in situ
#		field 9: ReporterGene                        : null
#		field 10: AssayNote                          : 
#		field 11: CreatedBy                          : cms

    for line in inSpecimenFile.readlines():

        tokens = string.split(line[:-1], TAB)
	probeID = tokens[0]
	markerID = tokens[5]

	prepFile.write(str(assayKey) + TAB + \
		probeID + TAB + \
		'RNA' + TAB + \
		'Antisense' + TAB + \
		'digoxigenin' + TAB + \
		'Alkaline phosphatase' + CRT)

	# write the assay information

        assayFile.write(str(assayKey) + TAB + \
            markerID + TAB + \
            'J:215487' + TAB + \
            'RNA in situ' + TAB + \
	    TAB + \
            TAB + \
            'cms' + CRT)

#		field 12,21,30,39,48,57,66: SpecimenLabel    :
#		field 13,22,31,40,49,58,67: Genotype         : MGI:2166311
#		field 14,23,32,41,50,59,68: Age              :
#		field 15,24,33,42,51,60,69: AgeNote          : null
#		field 16,25,34,43,52,61,70: Sex              : Not Specified for youngest 2 ages; Male for rest
#		field 17,26,35,44,53,62,71: Fixation         : Fresh Frozen
#		field 18,27,36,45,54,63,72: Embedding Method : Cryosection
#		field 19,28,37,46,55,64,73: Hybridization    : section
#		field 20,29,38,47,56,65,74: SpecimenNote     : null

        specimenKey = 1
	for s in range(11,65,9):

	    specimenLabel = tokens[s]
	    age = tokens[s + 2]

	    if age in ('embryonic day 11.5', 'embryonic day 13.5'):
	        sex = 'Not Specified'
            else:
	        sex = 'Male'

	    specimenFile.write(str(assayKey) + TAB + \
	        str(specimenKey) + TAB + \
	        specimenLabel + TAB + \
	        'MGI:2166311' + TAB + \
	        age + TAB + \
	        TAB + \
	        sex + TAB + \
	        'Fresh Frozen' + TAB + \
	        'Cryosection' + TAB + \
	        'section' + TAB + \
	        CRT)

#		field 75,81,93,102,99,105,111: Strength      : Present (n=10,781), Absent (n=2,645)
#		field 76,82,94,103,100,106,112: Pattern      : Not Specified (n=10,781), Not Applicable (n=2,645)
#		field 77,83,95,104,101,107,113: Structure    : EMAPA:16894
#		field 78,84,96,105,102,108,114: TS           : 
#		field 79,85,97,106,103,109,115: Note         : null

            resultKey = 1
	    for r in range(74,110,6):

		strength = tokens[r]
		pattern = tokens[r + 1]
		ts = tokens[r + 3]

	        resultsFile.write(str(assayKey) + TAB + \
	            str(specimenKey) + TAB + \
	            str(resultKey) + TAB + \
	            strength + TAB + \
	            pattern + TAB + \
	            'EMAPA:16894' + TAB + \
	            ts + TAB + \
	            TAB + \
	            CRT)

	        resultKey = resultKey + 1

            specimenKey = specimenKey + 1

	assayKey = assayKey + 1

    inSpecimenFile.close()

#
# Main
#

init()
process()
exit(0)

