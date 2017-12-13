#!/bin/bash -e

# replace str with string
sed -i "s/type: \[\"null\", str\]/type: \[\"null\", string\]/g" $1
sed -i "s/type: str$/type: string/g" $1

# remove unnecessasry u (unicode)
sed -i "s/u'/'/g" $1