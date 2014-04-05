#Script translating Coffee Script to Java Script

#Deleting bin folder
rm -rf bin/

#Copying js and html files to bin folder
cp -R ./src ./bin

#Compiling CS files to JS
coffee --compile --output ./bin/ ./src/


