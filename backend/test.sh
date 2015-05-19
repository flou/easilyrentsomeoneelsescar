#!/bin/bash

lvl=$1
ruby "level$lvl/main.rb" > my_output.json
diff "level$lvl/output.json" my_output.json
if [ $? == 0 ]; then
  echo "Script output is OK"
else
  echo "Script output does not match"
fi
rm my_output.json
