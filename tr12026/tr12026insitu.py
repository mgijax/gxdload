#!/usr/local/bin/python

#
# Program: tr12026insitu.py
#
# Original Author: Lori Corbani
#
# Purpose:
#
#	To translate 12026/LoaderFiles/InSitu files into input files for the insituload.py program.
#
# Requirements Satisfied by This Program:
#
# Usage:
#
#	tr12026insitu.py
#
# Envvars:
#
# Inputs:
#
#	GenotypeTranslation.txt, a tab-delimited file in the format:
#		field 1: IMPC ID
#		field 2: MGI ID
#
#	StructureTranslation.txt, a tab-delimited file in the format:
#		field 1: IMPC ID
#		field 2: EMAPA ID
#		field 3: Stage
#
#	ImageLoader.txt, a tab-delimited file in the format:
#
#	ProbePrep.txt, empty file
#
#       InSituAssay.txt, a tab-delimited file in the format:
#
#               field 1: MGI Marker Accession ID
#               field 2: Reference (J:#####)
#               field 3: Assay Type
#               field 4: Reporter Gene
#               field 5: Assay Note
#               field 6: Created By
#
#       InSituSpecimens.txt, a tab-delimited file in the format:
#               field 1: MGI Marker Accession ID
#               field 2: Specimen Label
#               field 3: Genotype ID
#               field 4: Age
#               field 5: Age Note
#               field 6: Sex
#               field 7: Fixation
#               field 8: Embedding Method
#               field 9: Hybridization
#               field 10: Specimen Note
#
#       InSituResults.txt, a tab-delimited file in the format:
#               field 1: Specimen Label
#               field 2: Strength
#               field 3: Pattern
#		field 4: EMAPA id
#               field 5: Result Note
#               field 6: Image
#
# Outputs:
#
#       3 tab-delimited files:
#
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

#globals

TAB = '\t'		# tab
CRT = '\n'		# carriage return/newline
NULL = ''

inPrepFile = '' 	# file descriptor
inAssayFile = ''	# file descriptor
inSpecimenFile = ''	# file descriptor
inResultFile = ''	# file descriptor

prepFile = ''           # file descriptor
assayFile = ''          # file descriptor
specimenFile = ''       # file descriptor
resultsFile = ''        # file descriptor

trdir = os.environ['TR_DIR']
datadir = os.environ['ASSAYLOADDATADIR']

inGenotypeFileName = os.environ['PROJECTDIR'] + '/LoaderFiles/GenotypeTranslation.txt'
inStructureFileName = os.environ['PROJECTDIR'] + '/LoaderFiles/StructureTranslation.txt'
inPrepFileName = os.environ['PROJECTDIR'] + '/LoaderFiles/InSituProbePrep.txt'
inAssayFileName = os.environ['PROJECTDIR'] + '/LoaderFiles/InSituAssay.txt'
inSpecimenFileName = os.environ['PROJECTDIR'] + '/LoaderFiles/InSituSpecimens.txt'
inResultFileName = os.environ['PROJECTDIR'] + '/LoaderFiles/InSituResults.txt'

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
    global inGenotypeFile, inStructureFile, inPrepFile, inAssayFile, inSpecimenFile, inResultFile
    global prepFile, assayFile, specimenFile, resultsFile
 
    try:
        inGenotypeFile = open(inGenotypeFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inGenotypeFileName)

    try:
        inStructureFile = open(inStructureFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inStructureFileName)

    try:
        inPrepFile = open(inPrepFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inPrepFileName)

    try:
        inAssayFile = open(inAssayFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inAssayFileName)

    try:
        inSpecimenFile = open(inSpecimenFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inSpecimenFileName)

    try:
        inResultFile = open(inResultFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inResultFileName)

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

    prepFile.close()

    return

# Purpose:  processes data
# Returns:  nothing
# Assumes:  nothing
# Effects:  writes data to output files
# Throws:   nothing

def process():

    assayKey = 1
    markerLookup = {}
    assayLookup = {}

    # impc ID -> MGI genotype ID
    genotypeLookup = {}
    for line in inGenotypeFile.readlines():
        tokens = string.split(line[:-1], TAB)
	key = tokens[0]
	value = tokens[1]
	genotypeLookup[key] = []
	genotypeLookup[key].append(value)
    inGenotypeFile.close()

    # impc ID -> emapa ID/stage
    emapLookup = {}
    for line in inStructureFile.readlines():
        tokens = string.split(line[:-1], TAB)
	key = tokens[0]
	value = tokens
	emapLookup[key] = []
	emapLookup[key].append(value)
    inStructureFile.close()

    # create lookup of images (_image_key, figureLabel)

    imageLookup = {}
    results = db.sql('''
	select ii._ImagePane_key, i.figureLabel 
	from IMG_Image i, IMG_ImagePane ii
	where i._Refs_key = 229658
	and i._Image_key = ii._Image_key
	''', 'auto')
    for r in results:
	key = r['figureLabel']
	imageLookup[key] = []
	imageLookup[key].append(r['_ImagePane_key'])

    # For each line in the input file

    for line in inAssayFile.readlines():

        # Split the line into tokens
        tokens = string.split(line[:-1], TAB)

	markerID = tokens[0]
	reference = tokens[1]
	assayType = tokens[2]
	reporter = tokens[3]
	assayNote = tokens[4]
	createdBy = tokens[5]

	# create one assay per record

	# write the assay information

        assayFile.write(str(assayKey) + TAB + \
            markerID + TAB + \
            reference + TAB + \
            assayType + TAB + \
	    reporter + TAB + \
            assayNote + TAB + \
            createdBy + CRT)

	if not assayLookup.has_key(markerID):
	    assayLookup[markerID] = []
        assayLookup[markerID] = assayKey

	assayKey = assayKey + 1

    inAssayFile.close()

    # end of "for line in inAssayFile.readlines():"

    # write one specimen per assay

    specimenKey = 1
    prevMarkerID = ''
    specimenLookup = {}
    specimenProbeLookup = {}

    for sline in inSpecimenFile.readlines():

        # Split the line into tokens
        tokens = string.split(sline[:-1], TAB)

	markerID = tokens[0]
	specimenID = tokens[1]
	genotype = tokens[2]
	age = tokens[3]
	ageNote = tokens[4]
	sex = tokens[5]
	fixation = tokens[6]
	embedding = tokens[7]
	specimenHybridization = tokens[8]
	specimenNote = ''

	if markerID != prevMarkerID:
            specimenKey = 1
	    assayKey = assayLookup[markerID]
	    prevMarkerID = markerID

	mgigenotype = genotypeLookup[genotype][0]

	specimenFile.write(str(assayKey) + TAB + \
	    str(specimenKey) + TAB + \
	    specimenID + TAB + \
	    mgigenotype + TAB + \
	    age + TAB + \
	    ageNote + TAB + \
	    sex + TAB + \
	    fixation + TAB + \
	    embedding + TAB + \
	    specimenHybridization + TAB + \
	    specimenNote + CRT)

	if not specimenLookup.has_key(specimenID):
	    specimenLookup[specimenID] = []
        specimenLookup[specimenID] = specimenKey
	specimenProbeLookup[specimenID] = markerID

        specimenKey = specimenKey + 1

    inSpecimenFile.close()

    # write one results per specimen

    resultKey = 1
    prevSpecimenID = ''

    for rline in inResultFile.readlines():

        # Split the line into tokens
        tokens = string.split(rline[:-1], TAB)

	specimenID = tokens[0]
	strength = tokens[1]
	pattern = tokens[2]
	impcID = tokens[3]
	resultNote = tokens[4]
	imageName = tokens[5]

	emapaID = emapLookup[impcID][0][1]
	structureTS = emapLookup[impcID][0][2]

	if imageLookup.has_key(imageName):
	    imageName = imageLookup[specimenID][0]
        else:
	    imageName = ''

	if specimenID != prevSpecimenID:
            resultKey = 1
	    specimenKey = specimenLookup[specimenID]
	    assayKey = assayLookup[specimenProbeLookup[specimenID]]
	    prevSpecimenID = specimenID

	resultsFile.write(str(assayKey) + TAB + \
	    str(specimenKey) + TAB + \
	    str(resultKey) + TAB + \
	    strength + TAB + \
	    pattern + TAB + \
	    emapaID + TAB + \
	    str(structureTS) + TAB + \
	    resultNote + TAB + \
	    str(imageName) + CRT)

        resultKey = resultKey + 1

    inResultFile.close()

    # end of "for line in inResultFile.readlines():"

#
# Main
#

init()
process()
exit(0)

