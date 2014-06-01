#!/bin/bash

directory=spec/

for file in $( ls $directory/*.coffee )
do
	ibrik cover $file
done
