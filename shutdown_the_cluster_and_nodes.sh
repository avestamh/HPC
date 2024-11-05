#!/bin/bash
#---------------------------
# Written by: Sadra Avestan
# Date: March 2018
#---------------------------

if [ "$1" != "" ]; then

    wall "BioChem and all nodes will be shutdown in $1 minutes"

    for i in {1..5}; do

        ssh node$i shutdown -P +$1 "BioChem and all nodes will be shutdown in $1 minutes"

    done

    shutdown -P +$1 "BioChem and all nodes will be shutdown in $1 minutes"

else

    echo "Please specifythe time (in minutes) after which BioChem and all nodes should be automatically shut down"

fi                                                                                                       
