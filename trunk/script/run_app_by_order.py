#!/usr/bin/env python
# usage: python gen_markov_trace.py <number-of-nodes>

import sys
import datetime
import os
import operator
import array
import random

if len(sys.argv) != 2:
    print "usage: python " + sys.argv[0] + " <number-of-nodes> "
    sys.exit(1)

nodeNum=int(sys.argv[1])

userName="user"

application="luckyme"
para_s=" -s "
para_i=" -r "
para_f=" -f ~/.Haggle/"

debug=1

for x in range(nodeNum):
	cmd=" \"screen -dmS "+application+" "+application

	node_name="node-"+str(x)
	cmd_send=cmd+para_f+node_name+"\""
	cmd_run_app="ssh "+userName+"@"+node_name+cmd_send
	
	if debug ==1:
		print cmd_run_app		
	os.system(cmd_run_app)