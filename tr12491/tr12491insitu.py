#!/usr/local/bin/python

#
# Program: tr12491insitu.py
#
# Original Author: Lori Corbani
#
# Purpose:
#
#	To translate 12491/LoaderFiles/InSitu files into input files for the insituload.py program.
#
# Requirements Satisfied by This Program:
#
# Usage:
#
#	tr12491insitu.py
#
# Envvars:
#
# Inputs:
#
#       Probe_Gene.txt
#		field 1: Probe ID
#		field 2: MGI ID
#
#	specimen_results.txt
#		field 1: probe id
#		field 2: gene id
#		field 3: specimen label
#		field 4: age
#		field 5: figure|pane
#		field 6,11,16,21,26,31: strength
#		field 7,12,17,22,27,32: pattern
#		field 8,13,18,23,28,33: strucutre
#		field 9,14,19,24,29,34: TS
#		field 10,15,20,25,30,35: Result note
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

inProbeGeneFile = '' 	# file descriptor
inSpecimenFile = ''	# file descriptor

prepFile = ''           # file descriptor
assayFile = ''          # file descriptor
specimenFile = ''       # file descriptor
resultsFile = ''        # file descriptor

datadir = os.environ['ASSAYLOADDATADIR']

inProbeGeneFileName = os.environ['ASSAYLOADDATADIR'] + '/Probe_Gene.txt'
inSpecimenFileName = os.environ['ASSAYLOADDATADIR'] + '/specimen_results.txt'

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
    global inProbeGeneFile, inSpecimenFile
    global prepFile, assayFile, specimenFile, resultsFile
 
    try:
        inProbeGeneFile = open(inProbeGeneFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inProbeGeneFileName)

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
    markerLookup = {}
    assayLookup = {}

    structureLookup = {}
    results = db.sql('''
	select a.accID, t.term 
	from VOC_Term t, ACC_Accession a
	where t._Vocab_key = 90
	and t._Term_key = a._Object_key
	and a._LogicalDB_key = 169
    	''', 'auto')
    for r in results:
	key = r['term']
	value = r['accID']
	structureLookup[key] = []
	structureLookup[key].append(value)
    #print structureLookup

    for line in inProbeGeneFile.readlines():

        tokens = string.split(line[:-1], TAB)
	probeID = tokens[0]
	markerID = tokens[1]

	prepFile.write(str(assayKey) + TAB + \
		probeID + TAB + \
		'RNA' + TAB + \
		'Antisense' + TAB + \
		'digoxigenin' + TAB + \
		'Alkaline phosphatase' + CRT)

	# write the assay information

        assayFile.write(str(assayKey) + TAB + \
            markerID + TAB + \
            'J:226028' + TAB + \
            'RNA in situ' + TAB + \
	    TAB + \
            TAB + \
            'cms' + CRT)

	if not assayLookup.has_key(markerID):
	    assayLookup[markerID] = []
        assayLookup[markerID] = assayKey

	assayKey = assayKey + 1

    # write one specimen per assay

    specimenKey = 1
    prevMarkerID = ''
    specimenLookup = {}
    specimenProbeLookup = {}

    for sline in inSpecimenFile.readlines():

        # Split the line into tokens
        tokens = string.split(sline[:-1], TAB)

	probeID = tokens[0]
	markerID = tokens[1]
	specimenID = tokens[2]
	age = tokens[3]
	figurelabel = tokens[4]

	if markerID != prevMarkerID:
            specimenKey = 1
	    assayKey = assayLookup[markerID]
	    prevMarkerID = markerID

	specimenFile.write(str(assayKey) + TAB + \
	    str(specimenKey) + TAB + \
	    specimenID + TAB + \
	    'MGI:2167046' + TAB + \
	    age + TAB + \
	    TAB + \
	    'Not Specified' + TAB + \
	    '4% Paraformaldehyde' + TAB + \
	    'Not Applicable' + TAB + \
	    'whole mount' + TAB + \
	    CRT)

	if not specimenLookup.has_key(specimenID):
	    specimenLookup[specimenID] = []
        specimenLookup[specimenID] = specimenKey
	specimenProbeLookup[specimenID] = markerID

        # write one results per specimen

        resultKey = 1
        prevSpecimenID = ''

#		field 6,11,16,21,26,31: strength
#		field 7,12,17,22,27,32: pattern
#		field 8,13,18,23,28,33: strucutre
#		field 9,14,19,24,29,34: TS
#		field 10,15,20,25,30,35: Result note

	s1 = 5
	p1 = 6
	e1 = 7
	s2 = 8
	r1 = 9

	for r in range(1,6):
	
	    strength = tokens[s1]
	    pattern = tokens[p1]
	    emapa = tokens[e1]
	    structureTS = tokens[s2]
	    resultNote = tokens[r1]

	    if len(emapa) > 0 and emapa in structureLookup:

	        emapaID = structureLookup[emapa][0]

	        resultsFile.write(str(assayKey) + TAB + \
	            str(specimenKey) + TAB + \
	            str(resultKey) + TAB + \
	            strength + TAB + \
	            pattern + TAB + \
	            emapaID + TAB + \
	            str(structureTS) + TAB + \
	            resultNote + TAB + \
	            str(figurelabel) + CRT)

                resultKey = resultKey + 1

	    elif len(emapa) > 0:
		print tokens
                print emapa

	    s1 += 5
	    p1 += 5
	    e1 += 5
	    s2 += 5
	    r1 += 5

        specimenKey = specimenKey + 1

    inProbeGeneFile.close()
    inSpecimenFile.close()

#
# Main
#

init()
process()
exit(0)

