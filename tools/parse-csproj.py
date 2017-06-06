#! /usr/bin/env python
# Parses the *.csproj file to get the netcoreapp version

from __future__ import print_function
import os
import sys
from xml.dom.minidom import parseString

proj_dir = os.environ['PROJ']
csproj = os.environ['CSPROJ']
full_path = "{}/{}.csproj".format(proj_dir, csproj)

with open(full_path, 'r') as myfile:
    file_text = myfile.read().replace('\n', '')
    dom = parseString(file_text)
    data = dom.getElementsByTagName('TargetFramework')[0].childNodes[0].data
    sys.exit(data)
