#!/bin/bash

CHARTS_DIR=$HOME/workspace/projects/jeedom/helm/charts
WORKING_DIR=$HOME/workspace/repositories/helmrepo

TMP_DIR=$WORKING_DIR/.tmp
DEPLOY_DIR=$WORKING_DIR/.deploy
INDEX_DIR=$WORKING_DIR/.toindex

# Updatye local repositorie
cd $WORKING_DIR
 
mkdir -p $TMP_DIR
mkdir -p $INDEX_DIR

for currentDirectory in `find $CHARTS_DIR -maxdepth 1 -mindepth 1 -type d`
do
   echo "Current directory : $currentDirectory"
   helm package $currentDirectory --destination $TMP_DIR
   
   cd $TMP_DIR
   for currentFile in `find -type f`
   do
   	   echo "Current file : $currentFile"
       if [ -f $DEPLOY_DIR/$currentFile ] ; then
           echo "\033[33;1m [WARNING] $currentFile already exist\033[0;1m"
           rm $currentFile
       else
           echo "Moving file"
           mv $currentFile $WORKING_DIR/.toindex
           echo "\033[35;1m [INFO] $currentFile updated\033[0;1m"
           echo "Mise a jour : $currentFile" >> $WORKING_DIR/README.md
       fi
   done
done

if [ "$(ls -A $INDEX_DIR)" ] ; then
    echo "CR Upload"
	cr upload -p $WORKING_DIR/.toindex
	echo "======> Updating index.yaml"
	cr index -i $WORKING_DIR/index.yaml -p $INDEX_DIR
	mv $INDEX_DIR/*.tgz $DEPLOY_DIR
	sed -i -e "s/Derniere mise a jour//g"
	echo "Derniere mise a jour : $(date)"
else
	echo "Nothing to update"
fi

git add .
git commit -a -m "Updating repository"
git push -u origin gh-pages
git pull
helm repo update
