#!/usr/bin/env python
 
import simplejson
import sys
import yaml


print yaml.dump(simplejson.loads(str(open(sys.argv[1], 'rb').read())), default_flow_style=True)
