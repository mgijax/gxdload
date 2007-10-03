#!/usr/local/bin/python

import sys
import os
import string
import re

from xml.dom import minidom

#
#  CONSTANTS
#
MAX_IMAGES = 24

#
#  GLOBALS
#
strainLookup = {'BL6/SV129':'MGI:2170276','C57BL/6':'MGI:2166522','NMRI':'MGI:2166653'}

xmlDir = os.environ['XML_DIR'] 
geneFile = os.environ['GENE_FILE']
structFile = os.environ['STRUCTURE_FILE']
strPattFile = os.environ['STR_PATT_FILE']
strPattTransFile = os.environ['STR_PATT_TRANS_FILE']
imageListFile = os.environ['IMAGE_LIST_FILE']
bestImageFile = os.environ['BEST_IMAGE_FILE']


#
# Purpose: Create a dictionary for looking up the MGI ID for a gene symbol.
#          The information for the dictionary is read from a file that
#          contains all gene symbols from the XML files and the associated
#          MGI IDs.
# Returns: Nothing
# Assumes: The name of the input file is set in the environment.
# Effects: Sets global variable
# Throws: Nothing
#
def buildGeneLookup ():
    global geneLookup

    #
    # Open the input file that has gene symbol/MGI ID mappings.
    #
    try:
        fpGene = open(geneFile, 'r')
    except:
        sys.stderr.write('Cannot open input file: ' + geneFile + '\n')
        sys.exit(1)

    #
    # Build a dictionary of MGI IDs from the input file, keyed by gene symbol.
    #
    geneLookup = {}
    line = fpGene.readline()
    while line:
        tokens = re.split('\t', line[:-1])
        geneLookup[tokens[0]] = tokens[1]
        line = fpGene.readline()

    fpGene.close()

    return


#
# Purpose: Create a dictionary for looking up a structure name for a given
#          structure ID.  The information for the dictionary is read from a
#          file that contains the structure IDs/names from the XML files.
#          Also create a sorted list of the dictionary keys.
# Returns: Nothing
# Assumes: The name of the input file is set in the environment.
# Effects: Sets global variables
# Throws: Nothing
#
def buildStructureLookup ():
    global structureLookup, structureIDs

    #
    # Open the input file that has structure ID/name mappings.
    #
    try:
        fpStruct = open(structFile, 'r')
    except:
        sys.stderr.write('Cannot open input file: ' + structFile + '\n')
        sys.exit(1)

    #
    # Build a dictionary of structure names from the input file, keyed by
    # structure ID.
    #
    structureLookup = {}
    line = fpStruct.readline()
    while line:
        tokens = re.split('\t', line[:-1])
        structureLookup[int(tokens[0])] = tokens[1]
        line = fpStruct.readline()

    #
    # Generate a sorted list of the structure IDs.
    #
    structureIDs = structureLookup.keys()
    structureIDs.sort()

    fpStruct.close()

    return


#
# Purpose: Open the output files and write a heading to each one.
# Returns: Nothing
# Assumes: The names of the output files are set in the environment.
# Effects: Sets global variables
# Throws: Nothing
#
def openFiles ():
    global fpStrPatt, fpStrPattTrans, fpImageList, fpBestImage

    #
    # Open the structure/pattern output file and write a heading to it.
    #
    try:
        fpStrPatt = open(strPattFile, 'w')
    except:
        sys.stderr.write('Cannot open output file: ' + strPattFile + '\n')
        sys.exit(1)

    fpStrPatt.write('\t'*12)
    for id in structureIDs:
        fpStrPatt.write('\t' + str(id) + '\t' + structureLookup[id])
    fpStrPatt.write('\t\n')

    fpStrPatt.write('MGI ID' + '\t' + 'Gene Symbol' + '\t' +
                    'Analysis ID' + '\t' + 'Probe ID' + '\t' +
                    'Probe Name' + '\t' + 'Specimen ID' + '\t' +
                    'Primer Name' + '\t' + 'Forward Primer' + '\t' +
                    'Reverse Primer' + '\t' + 'Strain ID' + '\t' +
                    'Strain MGI ID' + '\t' + 'Method ID' + '\t' +
                    'Accession Number')
    for i in range(len(structureIDs)):
        fpStrPatt.write('\t' + 'Expression' + '\t' + 'Pattern')
    fpStrPatt.write('\t' + 'Probe Sequence' + '\n')

    #
    # Open the structure/pattern "translated" output file and write a heading
    # to it.
    #
    try:
        fpStrPattTrans = open(strPattTransFile, 'w')
    except:
        sys.stderr.write('Cannot open output file: ' + strPattTransFile + '\n')
        sys.exit(1)

    fpStrPattTrans.write('\t'*12)
    for id in structureIDs:
        fpStrPattTrans.write('\t' + str(id) + '\t' + structureLookup[id])
    fpStrPattTrans.write('\t\n')

    fpStrPattTrans.write('MGI ID' + '\t' + 'Gene Symbol' + '\t' +
                         'Analysis ID' + '\t' + 'Probe ID' + '\t' +
                         'Probe Name' + '\t' + 'Specimen ID' + '\t' +
                         'Primer Name' + '\t' + 'Forward Primer' + '\t' +
                         'Reverse Primer' + '\t' + 'Strain ID' + '\t' +
                         'Strain MGI ID' + '\t' + 'Method ID' + '\t' +
                         'Accession Number')
    for i in range(len(structureIDs)):
        fpStrPattTrans.write('\t' + 'Expression' + '\t' + 'Pattern')
    fpStrPattTrans.write('\t' + 'Probe Sequence' + '\n')

    #
    # Open the image list output file and write a heading to it.
    #
    try:
        fpImageList = open(imageListFile, 'w')
    except:
        sys.stderr.write('Cannot open output file: ' + imageListFile + '\n')
        sys.exit(1)

    fpImageList.write('MGI ID' + '\t' + 'Gene Symbol' + '\t' +
                      'Analysis ID' + '\t' + 'Probe ID' + '\t' +
                      'Probe Name' + '\t' + 'Specimen ID' + '\t' +
                      'Accession Number')
    for i in range(MAX_IMAGES):
        fpImageList.write('\t' + 'Set' + '\t' + 'Slide_Section' +
                          '\t' + 'Name' + '\t' + 'Figure Label')
    fpImageList.write('\n')

    #
    # Open the best image output file and write a heading to it.
    #
    try:
        fpBestImage = open(bestImageFile, 'w')
    except:
        sys.stderr.write('Cannot open output file: ' + bestImageFile + '\n')
        sys.exit(1)

    fpBestImage.write('MGI ID' + '\t' + 'Gene Symbol' + '\t' +
                      'Analysis ID' + '\t' + 'Probe ID' + '\t' +
                      'Probe Name' + '\t' + 'Specimen ID' + '\t' +
                      'Accession Number')
    for id in structureIDs:
        fpBestImage.write('\t' + str(id))
    fpBestImage.write('\n')

    return


#
# Purpose: Close the output files.
# Returns: Nothing
# Assumes: Nothing
# Effects: Nothing
# Throws: Nothing
#
def closeFiles ():
    fpStrPatt.close()
    fpStrPattTrans.close()
    fpImageList.close()
    fpBestImage.close()

    return


#
# Purpose: Open an XML file, read it into a document object, extract the
#          pertinent data and write to the output files.
# Returns: 0 if the file is processed successfully, 1 for an error
# Assumes: Nothing
# Effects: Nothing
# Throws: Nothing
#
def processFile (inputFile):

    #
    # Open the XML input file.
    #
    try:
        fpXML = open(inputFile, 'r')
    except:
        sys.stderr.write('Cannot open XML input file: ' + inputFile + '\n')
        return 1

    #
    # Read in the entire XML file to create the document object for parsing.
    #
    xmldoc = minidom.parseString(fpXML.read(100000))

    #
    # Close the XML input file.
    #
    fpXML.close()

    #
    # If the experiment has no annotations, skip this file.
    #
    annotationNode = xmldoc.getElementsByTagName('annotations')
    if len(annotationNode) == 0:
        return 0

    #
    # Get the analysis ID.
    #
    analysisID = xmldoc.getElementsByTagName('analysis')[0].getAttribute("id")

    #
    # Get the gene symbol and accession number.
    #
    geneSymbol = ''
    accNum = ''
    for sym in xmldoc.getElementsByTagName('symbol'):
        if sym.getAttribute("type") == 'GeneSymbol':
            geneSymbol = sym.firstChild.nodeValue
        if sym.getAttribute("type") == 'AccessionNumber':
            accNum = sym.firstChild.nodeValue

    #
    # Look up the MGI ID for the gene symbol. If there is no MGI ID, skip
    # this file.
    #
    if geneLookup.has_key(geneSymbol):
        geneMGIID = geneLookup[geneSymbol]
    else:
        return 0

    #
    # Get the probe sequence and probe ID.  Generate the probe name.
    #
    probeSeq = xmldoc.getElementsByTagName('sequence')[0].firstChild.nodeValue.strip()
    if probeSeq	!= '':
        probeSeq = 'Probe sequence: ' + probeSeq
    probeID = xmldoc.getElementsByTagName('probe')[0].getAttribute("id")
    probeName = analysisID + ' probe ' + probeID

    #
    # Get the primer sequences (if any) and generate the primer name.
    #
    forwardPrimer = ''
    reversePrimer = ''
    for primer in xmldoc.getElementsByTagName('primer'):
        if primer.getAttribute("type") == 'forward':
            forwardPrimer = primer.getElementsByTagName('sequence')[0].firstChild.nodeValue
        if primer.getAttribute("type") == 'reverse':
            reversePrimer = primer.getElementsByTagName('sequence')[0].firstChild.nodeValue

    if forwardPrimer != '' and reversePrimer != '':
        primerName = analysisID + '-pA, ' + analysisID + '-pB'
    else:
        primerName = ''

    #
    # Get the specimen ID.
    #
    specimenID = xmldoc.getElementsByTagName('specimen')[0].getAttribute("id")

    #
    # Get the strain and look up its MGI ID.
    #
    strain = xmldoc.getElementsByTagName('strain')[0].firstChild.nodeValue
    strainMGIID = strainLookup[strain]

    #
    # Get the method ID.
    #
    methodID = xmldoc.getElementsByTagName('preparation')[0].getElementsByTagName('method')[0].firstChild.nodeValue

    #
    # Get the image data from the document.
    #
    images = []
    for image in xmldoc.getElementsByTagName('images')[0].getElementsByTagName('image'):
        dict = {}
        dict['set'] = image.getElementsByTagName('set')[0].firstChild.nodeValue
        dict['slide'] = image.getElementsByTagName('slide')[0].firstChild.nodeValue
        dict['section'] = image.getElementsByTagName('section')[0].firstChild.nodeValue.upper()
        dict['name'] = image.getElementsByTagName('name')[0].firstChild.nodeValue
        images.append(dict)

    #
    # Get the structure data from the document.
    #
    structures = {}
    for structure in annotationNode[0].getElementsByTagName('structur'):
        dict = {}
        strID = structure.getAttribute("id")
        dict['expression'] = structure.getElementsByTagName('expression')[0].firstChild.nodeValue
        if len(structure.getElementsByTagName('pattern')) != 0:
            dict['pattern'] = structure.getElementsByTagName('pattern')[0].firstChild.nodeValue
        else:
            dict['pattern'] = ''
        if len(structure.getElementsByTagName('bestImage')) != 0:
            dict['bestImage'] = structure.getElementsByTagName('bestImage')[0].firstChild.nodeValue
        else:
            dict['bestImage'] = ''

        #
        # Translate the expression term.
        #
        if dict['expression'] == 'none':
            dict['expressionTrans'] = 'Absent'
        elif dict['expression'] == 'weak':
            dict['expressionTrans'] = 'Weak'
        elif dict['expression'] == 'medium':
            dict['expressionTrans'] = 'Present'
        elif dict['expression'] == 'strong':
            dict['expressionTrans'] = 'Strong'
        else:
            dict['expressionTrans'] = dict['expression']

        #
        # Translate the pattern term.
        #
        if dict['pattern'] == '':
            dict['patternTrans'] = 'Not Applicable'
        elif dict['pattern'] == 'ubiquitous':
            dict['patternTrans'] = 'Homogeneous'
        elif dict['pattern'] == 'regional':
            dict['patternTrans'] = 'Regionally restricted'
        elif dict['pattern'] == 'scattered':
            dict['patternTrans'] = 'Patchy'
        elif dict['pattern'] == 'restricted':
            dict['patternTrans'] = 'Regionally restricted'
        else:
            dict['patternTrans'] = dict['pattern']

        structures[strID] = dict

    #
    # Write to the structure/pattern output file.
    #
    fpStrPatt.write(geneMGIID + '\t' + geneSymbol + '\t' +
                    analysisID + '\t' + probeID + '\t' + probeName + '\t' +
                    specimenID + '\t' + primerName + '\t' +
                    forwardPrimer + '\t' + reversePrimer + '\t' +
                    strain + '\t' + strainMGIID + '\t' +
                    methodID + '\t' + accNum)
    for id in structureIDs:
        if structures.has_key(str(id)):
            dict = structures[str(id)]
            fpStrPatt.write('\t' + dict['expression'] + '\t' + dict['pattern'])
        else:
            fpStrPatt.write('\t\t')
    fpStrPatt.write('\t' + probeSeq + '\n')

    #
    # Write to the structure/pattern "translated" output file.
    #
    fpStrPattTrans.write(geneMGIID + '\t' + geneSymbol + '\t' +
                         analysisID + '\t' + probeID + '\t' + probeName + '\t' +
                         specimenID + '\t' + primerName + '\t' +
                         forwardPrimer + '\t' + reversePrimer + '\t' +
                         strain + '\t' + strainMGIID + '\t' +
                         methodID + '\t' + accNum)
    for id in structureIDs:
        if structures.has_key(str(id)):
            dict = structures[str(id)]
            fpStrPattTrans.write('\t' + dict['expressionTrans'] + '\t' +
                                 dict['patternTrans'])
        else:
            fpStrPattTrans.write('\t\t')
    fpStrPattTrans.write('\t' + probeSeq + '\n')

    #
    # Write to the image list output file.
    #
    fpImageList.write(geneMGIID + '\t' + geneSymbol + '\t' +
                      analysisID + '\t' + probeID + '\t' + probeName + '\t' +
                      specimenID + '\t' + accNum)
    for image in images:
        fpImageList.write('\t' + image['set'] + '\t' +
                          image['slide'] + image['section'].upper() +
                          '\t' + image['name'] + '\t')
    fpImageList.write('\n')

    #
    # Write to the best image output file.
    #
    fpBestImage.write(geneMGIID + '\t' + geneSymbol + '\t' +
                      analysisID + '\t' + probeID + '\t' + probeName + '\t' +
                      specimenID + '\t' + accNum)
    for id in structureIDs:
        if structures.has_key(str(id)):
            dict = structures[str(id)]
            fpBestImage.write('\t' + dict['bestImage'])
        else:
            fpBestImage.write('\t')
    fpBestImage.write('\n')

    return 0


#
# Main
#
buildGeneLookup()
buildStructureLookup()

openFiles()

for filename in sys.argv[1:]:
    print filename
    if processFile(xmlDir + '/' + filename) != 0:
        break

closeFiles()
