#!/usr/local/bin/python

import sys
import os
import string
import re
import db

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
pixFile = os.environ['PIXELDB_FILES']

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
    global fpStrPatt, fpStrPattTrans, fpImageList, fpBestImage, fpPix

    #
    # Open the structure/pattern output file and write a heading to it.
    #
    # strPattFile:StrengthPattern.txt
    #
    # 0. MGI ID
    # 1. Gene Symbol
    # 2. Analysis ID
    # 3. Probe ID
    # 4. Probe Name
    # 5. Specimen ID
    # 6. Primer Name
    # 7. Forward Primer
    # 8. Reverse Primer
    # 9. Strain ID
    # 10. Strain MGI ID
    # 11. Method ID
    # 12. Accession Number
    #
    # 13. Strength
    # 14. Pattern
    # 15. Best Image
    # 16. Image JPG
    # 17. Figure Label
    # 18. Note 
    #
    # 19. Strength
    # 20. Pattern
    # 21. Best Image
    # 22. Image JPG
    # 23. Figure Label
    # 24. Note 
    #
    # etc.
    #

    try:
        fpStrPatt = open(strPattFile, 'w')
    except:
        sys.stderr.write('Cannot open output file: ' + strPattFile + '\n')
        sys.exit(1)

    fpStrPatt.write('\t'*12)
    for id in structureIDs:
        fpStrPatt.write('\t' + str(id) + '\t' + structureLookup[id] + '\t\t\t\t')
    fpStrPatt.write('\t\n')

    fpStrPatt.write('MGI ID' + '\t' + 'Gene Symbol' + '\t' +
                    'Analysis ID' + '\t' + 'Probe ID' + '\t' +
                    'Probe Name' + '\t' + 'Specimen ID' + '\t' +
                    'Primer Name' + '\t' + 'Forward Primer' + '\t' +
                    'Reverse Primer' + '\t' + 'Strain ID' + '\t' +
                    'Strain MGI ID' + '\t' + 'Method ID' + '\t' +
                    'Accession Number')
    for i in range(len(structureIDs)):
        fpStrPatt.write('\t' + 'Strength' + 
			'\t' + 'Pattern' + 
			'\t' + 'Best Image' +
			'\t' + 'Image JPG' +
			'\t' + 'Figure Label' +
			'\t' + 'Note')
    fpStrPatt.write('\t' + 'Probe Sequence' + '\n')

    #
    # Open the structure/pattern "translated" output file and write a heading
    # to it.
    #
    # strPattTransFile:StrengthPatternTrans.txt
    #
    # 0. MGI ID
    # 1. Gene Symbol
    # 2. Analysis ID
    #
    # 3. Strength
    # 4. Pattern
    # 5. Best Image
    # 6. Image JPG
    # 7. Figure Label
    #
    # 8. Strength
    # 9. Pattern
    # 10. Best Image
    # 11. Image JPG
    # 12. Figure Label
    #
    # etc.
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

    fpStrPattTrans.write('MGI ID' + '\t' + 'Gene Symbol' + '\t' + 'Analysis ID')
    for i in range(len(structureIDs)):
        fpStrPattTrans.write('\t' + 'Strength' + 
			'\t' + 'Pattern' + 
			'\t' + 'Best Image' + 
			'\t' + 'Image JPG' + 
			'\t' + 'Figure Label')
    fpStrPattTrans.write('\n')

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

    #
    # Open pix image output file and write a heading to it.
    #
    try:
        fpPix = open(pixFile, 'w')
    except:
        sys.stderr.write('Cannot open output file: ' + pixFile + '\n')
        sys.exit(1)

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
    fpPix.close()

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
        print "cannot find: =", geneSymbol, "="
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
    imageSlide = {}
    imageSet = {}
    for image in xmldoc.getElementsByTagName('images')[0].getElementsByTagName('image'):
        dict = {}
	theSet = image.getElementsByTagName('set')[0].firstChild.nodeValue
	theSlide = image.getElementsByTagName('slide')[0].firstChild.nodeValue
	theSection = image.getElementsByTagName('section')[0].firstChild.nodeValue.upper()
        theName = image.getElementsByTagName('name')[0].firstChild.nodeValue
	id = theSlide + theSection
	dict['id'] = id
        dict['set'] = theSet
        dict['slide'] = theSlide
        dict['section'] = theSection
        dict['name'] = theName
        images.append(dict)
	imageSlide[id] = theName
	imageSet[id] = theSet

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
        if dict['pattern'] == 'none':
            dict['patternTrans'] = 'Not Applicable'
        elif dict['pattern'] == 'ubiquitous':
            dict['patternTrans'] = 'Homogeneous'
        elif dict['pattern'] == 'regional':
            dict['patternTrans'] = 'Regionally restricted'
        else:
            dict['patternTrans'] = dict['pattern']

        structures[strID] = dict

    #
    # Write to the structure/pattern output file.
    #

    #
    # unique set of images that will be loaded into pixeldb
    #
    pixLookup = []

    fpStrPatt.write(geneMGIID + '\t' + geneSymbol + '\t' +
                    analysisID + '\t' + probeID + '\t' + probeName + '\t' +
                    specimenID + '\t' + primerName + '\t' +
                    forwardPrimer + '\t' + reversePrimer + '\t' +
                    strain + '\t' + strainMGIID + '\t' +
                    methodID + '\t' + accNum)

    for id in structureIDs:
        if structures.has_key(str(id)):
            dict = structures[str(id)]

	    if imageSlide.has_key(dict['bestImage']):
	       jpgImage = imageSlide[dict['bestImage']]
               figureLabel = 'Embryo_%s_%s_%s' % (specimenID, imageSet[dict['bestImage']], dict['bestImage'])

	       if jpgImage not in pixLookup:
	           pixLookup.append(jpgImage)

            else:
	       jpgImage = ''
	       figureLabel = ''

            fpStrPatt.write('\t' + dict['expression'] + '\t' + dict['pattern'])
            fpStrPatt.write('\t' + dict['bestImage'] + '\t' + jpgImage)
            fpStrPatt.write('\t' + figureLabel)
            fpStrPatt.write('\t')
        else:
            fpStrPatt.write('\t\t\t\t\t\t')
    fpStrPatt.write('\t' + probeSeq + '\n')

    for i in pixLookup:
	fpPix.write(i + '\n')

    #
    # Write to the structure/pattern "translated" output file.
    #
    fpStrPattTrans.write(geneMGIID + '\t' + geneSymbol + '\t' + analysisID)
    for id in structureIDs:
        if structures.has_key(str(id)):
            dict = structures[str(id)]

	    if imageSlide.has_key(dict['bestImage']):
	       jpgImage = imageSlide[dict['bestImage']]
               figureLabel = 'Embryo_%s_%s_%s' % (specimenID, imageSet[dict['bestImage']], dict['bestImage'])
            else:
	       jpgImage = ''
	       figureLabel = ''

            fpStrPattTrans.write('\t' + dict['expressionTrans'] + '\t' + dict['patternTrans'] + '\t')
            fpStrPattTrans.write('\t' + dict['bestImage'] + '\t' + jpgImage)
            fpStrPattTrans.write('\t' + figureLabel + '\t')
        else:
            fpStrPattTrans.write('\t\t\t\t')
    fpStrPattTrans.write('\n')

    #
    # Write to the image list output file.
    #
    fpImageList.write(geneMGIID + '\t' + geneSymbol + '\t' +
                      analysisID + '\t' + probeID + '\t' + probeName + '\t' +
                      specimenID + '\t' + accNum)
    for image in images:
	if imageSlide.has_key(dict['bestImage']):
	    jpgImage = imageSlide[dict['bestImage']]
        else:
	    jpgImage = ''

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

#processFile(xmlDir + '/' + 'DA00000076.xml')

for filename in sys.argv[1:]:
    print filename
    if processFile(xmlDir + '/' + filename) != 0:
        break

closeFiles()
