#Script translating Coffee Script to Java Script
#!/bin/bash

cs_filename=$(ls -t *.coffee | head -1)

coffee -c $cs_filename

rm -f $cs_filename

