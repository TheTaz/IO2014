#!/bin/bash

directory=acceptance_test/

for file in $( ls $directory/*.coffee )
do
	ibrik cover $file
done
