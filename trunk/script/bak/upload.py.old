#!/usr/bin/env python
# usage: python gen_markov_trace.py <number-of-nodes> <run-time [s]> <output-file>

import sys
import datetime
import os
import operator
import array
import random

if len(sys.argv) != 4:
    print "usage: python " + sys.argv[0] + " <localName> <remoteName (not path)> <number of nodes>"
    print "   copy file localName to .Haggle directory on nodes."
    sys.exit(1)

localName = str(sys.argv[1])
remoteName = str(sys.argv[2])
number_of_nodes = int(sys.argv[3])

userName="user"
community=10
members=number_of_nodes/community

debug=1

for i in range(community):
    for j in range(1,members+1):
      node_number=j+i*members
      node_name="node-"+str(node_number)
      
      cmd_mkdir="ssh "+userName+"@"+node_name+" mkdir .Haggle"
      fileName=localName+str(i+1)+".xml"
      cmd_mkscp="scp "+fileName+" "+userName+"@"+node_name+":.Haggle/"+remoteName
      
      if debug ==1:
	print node_name
	print cmd_mkdir
	print cmd_mkscp
      
      os.system(cmd_mkdir)
      os.system(cmd_mkscp)
      
    print "--"
      
      
     
