#!/bin/bash

mkdir -p ../data/assemblies
aws s3 sync s3://chunj-ifs/depot/assemblies/H.sapiens/b37 ../data/assemblies
