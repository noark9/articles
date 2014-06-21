#!/bin/sh

cd ..

rm -rf gitbook
mkdir gitbook
cp -R publish/* gitbook/
cp README.md gitbook/

cd gitbook

find .|tr '[A-Z]' '[a-z]'|sed -e '/issue/!d;/readme/d;/ds_store/d;/\.\/issue[^\/]*$/d'|sort -t- -k2,3 -n|gawk 'BEGIN {FS="\/";currentTitle="issue-0";currentCount=0} {if (currentTitle!=$2) {currentCount++;print "* issue-" currentCount;currentTitle="issue"currentCount}} {print "  * [" gensub(/(issue-[^-]*-[^-]*)-.*md/,"\\1","g",$3) "](" $2 "/" $3 ")"}'>SUMMARY0.md

curl http://objccn.io|grep "<a.*issue.*>"|sed -e '/<a.*<a/d;s/.*<a.*="//g;s/<\/.*$//g;s/\/">/,/g;/<p>/d;s/.*\///g;s/,[^ ]* /,/'>articlelist

awk 'BEGIN{FS=","} NR==FNR {title[$1]=$2} NR>FNR&&/^\*.*$/ {h1Title=$0;sub(/\* /,"",h1Title);myTitle=title[h1Title];sub(/^.*#[^ ]*/,"",myTitle);print $0 " " myTitle} NR>FNR&&!/^\*.*$/{h2Title=$0;sub(/^.*\[/,"",h2Title);sub(/\].*/,"",h2Title);h2TitleText=title[h2Title];content=$0;sub(/\[.*\]/,"[" h2Title " " h2TitleText "]",content);print content}' articlelist SUMMARY0.md>SUMMARY.md

rm SUMMARY0.md
rm articlelist

oldIFS=$IFS
IFS='
'
for item in `awk '!/^\*.*$/ {print $0}' SUMMARY.md`
do
    title='# '`echo $item|sed -e 's/^.*\[//;s/\].*//'`
    filename=`pwd`'/'`echo $item|sed -e 's/^.*(//;s/).*//'`
    cmd="ssed -i '1i\\"$title"' "$filename
    result=`sh -c "$cmd"`
done
IFS=$oldIFS

