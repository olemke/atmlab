#!/bin/bash
MIN_VAL=$1
MAX_VAL=$2
FILE_IN=$3;
FILE_OUT=$4;
TITLE=$5;
region='-R-180/180/-90/90'
projection='-JQ0/8.5i'
#gawk '{print $1, $2, $3}' $FILE_IN > dummy.xyz
#nearneighbor   $region  -S100K -I1.5 -N1  -Gdummy.grd -V dummy.xyz

echo "Creating colortable"

makecpt -Crainbow -T$1/$2/1 \
| sed 's/^F.*$/F       255     255     255/' \
| sed 's/^B.*$/B      255     255     255/' \
| sed 's/^N.*$/N       255     255     255/' \
> dummy.cpt

grdimage $FILE_IN $region  $projection -Cdummy.cpt -K   >$FILE_OUT
pscoast $region $projection -B30g30/20g20 -I10m  -Dc -A100 -W0.25p  -O -K>>$FILE_OUT
psscale -Cdummy.cpt -D9.1i/2.00i/4i/0.3i -O -I.01 -B10:$TITLE:  >> $FILE_OUT

\rm -f .gmtcommands
