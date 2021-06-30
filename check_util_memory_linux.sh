#!/bin/bash

#output=`free | awk '/Mem/{printf("%.2f"), $4/$2*100}'` # This reports memory Free
output=`free | awk '/Mem/{printf("%.2f"), $3/$2*100}'` # This reports memory Used

echo "Memory Used: $output% | 'mem_used %'=$output"
