#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select i.figureLabel, n._note_key
into temp table toUpdate
from IMG_Image i, MGI_Note n, MGI_NoteChunk c
where i._refs_key = 229658
and i._image_key = n._object_key
and n._notetype_key = 1023
and n._note_key = c._note_key
and c.note = 'Questions regarding this image or its use in publications should be directed to the International Mouse Phenotyping Consortium (IMPC) at <A HREF="http://www.mousephenotype.org/contact-us">http://www.mousephenotype.org/contact-us</A>'
;

select count(*) from toUpdate;

--update MGI_NoteChunk c
--set note = 'This image is from International Mouse Phenotyping Consortium (IMPC) and is displayed under the terms of the  <A HREF="https://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</A>.'
--from toUpdate u
--where c._note_key = u._note_key
--;

EOSQL

date |tee -a $LOG

