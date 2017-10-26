#!/usr/local/bin/python

#
# Program: resultsload.py
#
# Purpose:
#
#	To reload Results of existing Assay/Probe/Specimen into:
#
#	GXD_InSituResults
#       GXD_InSituResultImage
#	GXD_ISResultStructure
#
# Inputs:
#
#	Specimen Results file, a tab-delimited file in the format:
#		field 1: Specimen Label
#		field 2: Strength
#		field 3: Pattern
#		field 4: EMAPS
#		field 5: Result Note
#		field 6: Image id (image pane is blank)
#
#	Structure file, a tab-delimited file in the format:
#		field 1: EMAPS (field 4 above)
#		field 2: EMAPA
#		field 3: Stage key
#
# Outputs:
#
#       BCP files:
#
#	GXD_InSituResult.bcp		InSitu Results
#	GXD_ISResultStructure.bcp	InSitu Result Structures
#	Result_Image.txt		Results/Image text file
#	
#       Diagnostics file of all input parameters and SQL commands
#       Error file
#
# History
#
# 10/26/2017 lec
#       - TR12649/GUDMAP3
#

import sys
import os
import string
import db
import mgi_utils
import loadlib
import gxdloadlib

db.setTrace(True)

#
# from configuration file
#
user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
reference = os.environ['REFERENCE']

TAB = '\t'		# tab
DELIM = '|'
CRT = '\n'		# carriage return/newline

diagFile = ''		# diagnostic file descriptor
errorFile = ''		# error file descriptor

dirPath = os.environ['PROJECTDIR'] + '/resultsload/'

# input files
inResultsFile = ''        # file descriptor
inResultsFileName = os.environ['INPUT_RESULTS_FILE']
inStructureFile = ''
inStructureFileName = os.environ['INPUT_STRUCTURE_FILE']

# output files
outResultStFile = ''	# file descriptor
outResultFile = ''	# file descriptor
outResultImageFile = '' # file descriptor

resultTable = 'GXD_InSituResult'
resultStTable = 'GXD_ISResultStructure'
resultImageTable = 'GXD_InSituResultImage'

outResultFileName = dirPath + resultTable + '.bcp'
outResultStFileName = dirPath + resultStTable + '.bcp'
outResultImageFileName = dirPath + resultImageTable + '.bcp'

diagFileName = ''	# diagnostic file name
errorFileName = ''	# error file name

# primary keys
resultKey = 0		# GXD_GelRow._GelRow_key

imagePaneLookup = {}	# Image Figure Label|Pane Label = pane key

loaddate = loadlib.loaddate

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
 
    try:
        diagFile.write('\n\nEnd Date/Time: %s\n' % (mgi_utils.date()))
        errorFile.write('\n\nEnd Date/Time: %s\n' % (mgi_utils.date()))
        diagFile.close()
        errorFile.close()
    except:
        pass

    db.useOneConnection(0)
    sys.exit(status)
 
# Purpose: process command line options
# Returns: nothing
# Assumes: nothing
# Effects: initializes global variables
#          exits if files cannot be opened
# Throws: nothing

def init():
    global diagFile, errorFile, errorFileName, diagFileName
    global outResultStFile, outResultFile, outResultImageFile
    global inResultsFile, inStructureFile
 
    db.useOneConnection(1)
    db.set_sqlUser(user)
    db.set_sqlPasswordFromFile(passwordFileName)
 
    diagFileName = 'resultsload.diagnostics'
    errorFileName = 'resultsload.error'

    try:
        diagFile = open(diagFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % diagFileName)
		
    try:
        errorFile = open(errorFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % errorFileName)
		
    # Input Files

    try:
        inResultsFile = open(inResultsFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inResultsFileName)

    try:
        inStructureFile = open(inStructureFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inStructureFileName)

    # Output Files

    try:
        outResultStFile = open(outResultStFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % outResultStFileName)

    try:
        outResultFile = open(outResultFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % outResultFileName)

    try:
        outResultImageFile = open(outResultImageFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % outResultImageFileName)

    # Log all SQL
    db.set_sqlLogFunction(db.sqlLogAll)

    diagFile.write('Start Date/Time: %s\n' % (mgi_utils.date()))
    diagFile.write('Server: %s\n' % (db.get_sqlServer()))
    diagFile.write('Database: %s\n' % (db.get_sqlDatabase()))

    errorFile.write('Start Date/Time: %s\n\n' % (mgi_utils.date()))

    return

# Purpose:  sets global primary key variables
# Returns:  nothing
# Assumes:  nothing
# Effects:  sets global primary key variables
# Throws:   nothing

def setPrimaryKeys():

    global resultKey

    results = db.sql('select max(_Result_key) + 1 as maxKey from GXD_InSituResult', 'auto')
    resultKey = results[0]['maxKey']

# Purpose:  BCPs the data into the database
# Returns:  nothing
# Assumes:  nothing
# Effects:  BCPs the data into the database
# Throws:   nothing

def bcpFiles():

    outResultFile.close()
    outResultStFile.close()
    outResultImageFile.close()

    db.commit()
    db.useOneConnection(0)

    bcpScript = os.environ['PG_DBUTILS'] + '/bin/bcpin.csh'
    bcpI = '%s %s %s' % (bcpScript, db.get_sqlServer(), db.get_sqlDatabase())
    bcpII = '"|" "\\n" mgd' 

    bcp1 = '%s %s "/" %s %s' % (bcpI, resultTable, outResultFileName, bcpII)
    bcp2 = '%s %s "/" %s %s' % (bcpI, resultStTable, outResultStFileName, bcpII)
    bcp3 = '%s %s "/" %s %s' % (bcpI, resultImageTable, outResultImageFileName, bcpII)

    for bcpCmd in [bcp1, bcp2, bcp3]:
	diagFile.write('%s\n' % bcpCmd)
	os.system(bcpCmd)

    return

# Purpose:  processes results data
# Returns:  nothing
# Assumes:  nothing
# Effects:  verifies and processes each line in the input file
# Throws:   nothing

def processResultsFile():

    global resultKey
    global imagePaneLookup

    prevSpecimen = 0
    lineNum = 0

    #
    # build specimenLookup
    #
    specimenLookup = {}
    results = db.sql('''
    	select distinct s._Specimen_key, s.specimenLabel
	from GXD_Specimen s, BIB_Citation_Cache c, GXD_Assay a
	where c.jnumID = '%s'
	and c._Refs_key = a._Refs_key
	and a._Assay_key = s._Assay_key
	''' % (reference), 'auto')
    for r in results:
	key = r['specimenLabel']
    	value =  r['_Specimen_key']
	specimenLookup[key] = []
	specimenLookup[key].append(value)
    #print specimenLookup

    #
    # build emapLookup
    # key = emapS term
    # value = emapA key/stage key
    #
    emapLookup = {}
    for line in inStructureFile.readlines():
        tokens = string.split(line[:-1], TAB)
	emapS = tokens[0]
	emapA = tokens[1]
	emapAstage = tokens[2]
	results = db.sql('''
		select emapa._term_key
		from acc_accession a, voc_term_emapa emapa
		where a.accid = '%s'
		and a._Object_Key = emapa._term_key
		''' % (emapA), 'auto')
	for r in results:
	    key = emapS
    	    value = (r['_term_key'], emapAstage)
	    emapLookup[key] = []
	    emapLookup[key].append(value)
    #diagFile.write(str(emapLookup['EMAPS:2821226']))
    #print emapLookup['EMAPS:2821226'][0][0]
    #print emapLookup['EMAPS:2821226'][0][1]

    #
    # build imagePaneLookup lookup of figure label|pane label keys
    # key = figureLabel
    # value = pane key
    #
    results = db.sql('''
	select i.figureLabel, p._ImagePane_key 
	from IMG_Image i, IMG_ImagePane p, BIB_Citation_Cache c
	where i._Image_key = p._Image_key
	and c.jnumID = '%s'
	and c._Refs_key = i._Refs_key
    	''' % (reference), 'auto')
    for r in results:
	key = r['figureLabel']
    	value =  r['_ImagePane_key']
	imagePaneLookup[key] = []
	imagePaneLookup[key].append(value)
    #diagFile.write(str(imagePaneLookup['GUDMAP:15687']) + '\n')

    # For each line in the input file

    for line in inResultsFile.readlines():

        error = 0
        lineNum = lineNum + 1

        # Split the line into tokens
        tokens = string.split(line[:-1], TAB)

        try:
	    specimenID = tokens[0]
	    strength = tokens[1]
	    pattern = tokens[2]
	    emapsID = tokens[3]
	    #resultNote = tokens[4]
	    imagePane = tokens[5]
        except:
            exit(1, 'Invalid Line (%d): %s\n' % (lineNum, line))

	if specimenID not in specimenLookup:
	    diagFile.write('no specimen: ' + specimenID + '\n')
	    continue
	specimenKey = specimenLookup[specimenID][0]

	strengthKey = gxdloadlib.verifyStrength(strength, lineNum, errorFile)
	patternKey = gxdloadlib.verifyPattern(pattern, lineNum, errorFile)

	if emapsID in emapLookup:
            structureKey = emapLookup[emapsID][0][0]
            stageKey = emapLookup[emapsID][0][1]
	else:
	    structureKey = 0
	    stageKey = 0
            error = 1

        if strengthKey == 0 or patternKey == 0 or structureKey == 0:
            # set error flag to true
            error = 1

        # if errors, continue to next record
        if error:
            continue

	if prevSpecimen != specimenKey:
	    prevSpecimen = 0
	    sequenceNum = 1

        outResultFile.write(
	        str(resultKey) + DELIM + \
	        str(specimenKey) + DELIM + \
	        str(strengthKey) + DELIM + \
	        str(patternKey) + DELIM + \
	        str(sequenceNum) + DELIM + \
	        DELIM + \
	        loaddate + DELIM + loaddate + CRT)

	outResultStFile.write(
	    str(resultKey) + DELIM + \
	    str(structureKey) + DELIM + \
	    str(stageKey) + DELIM + \
	    loaddate + DELIM + loaddate + CRT)

	if imagePane in imagePaneLookup:
	    imageKey = imagePaneLookup[imagePane][0]
            outResultImageFile.write(str(resultKey) + DELIM + \
				str(imageKey) + DELIM + \
	        		loaddate + DELIM + loaddate + CRT)

        resultKey = resultKey + 1
	sequenceNum = sequenceNum + 1
	prevSpecimen = specimenKey

    #	end of "for line in inResultsFile.readlines():"

    return

#
# Main
#

init()
setPrimaryKeys()
processResultsFile()
bcpFiles()
exit(0)

