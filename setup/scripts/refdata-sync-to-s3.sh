#!/bin/bash

aws s3 sync --acl public-read ./setup/data/assemblies/ s3://chunj-ifs/depot/assemblies/H.sapiens/b37
