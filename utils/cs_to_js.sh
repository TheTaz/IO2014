#Script translating Coffee Script to Java Script
#!/bin/bash

#Deleting bin folder
rm -rf bin/

#Getting CS filenames
cs_filename=$(ls -t "src/*.coffee")

#Compiling CS files to JS
if [ -z "$cs_filename" ]; then
	printf "\n:: WARN :: No CS files to compile !\n"
else 
	coffee -c $cs_filename
fi

#Creating new bin folder
mkdir bin

#Copying js and html files to bin folder
js_files=$(find src/ -name "*.js")
html_files=$(find src/ -name "*.html")

if [ -z "$js_files" ]; then
	printf "\n:: WARN :: No JS files to copy !\n"
else
	cp -t bin/ $js_files
fi
if [ -z "$html_files" ]; then
	echo "\n:: WARN :: No HTML files to copy !\n"
else
	cp -t bin/ $html_files
fi

