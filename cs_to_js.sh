#Script translating Coffee Script to Java Script
#!/bin/bash

cs_filename=$(ls -t *.coffee)

coffee -c $cs_filename

