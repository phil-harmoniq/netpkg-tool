#! /usr/bin/env python

import sys

args = sys.argv
current_ver = float(args[1])
lowest_ver = float(args[2])

if current_ver >= lowest_ver:
    return_val = "true"
else:
    return_val = ""

sys.exit(return_val)
