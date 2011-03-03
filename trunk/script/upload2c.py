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
#community=2
#members=number_of_nodes/community

comm1=[11 ,29 ,3 ,32 ,7 ,28 ,16 ,34 ,36 ,22 ,21 ,25 ,27 ,12 ,8]

comm2=[1 ,4 ,30 ,2 ,14 ,18 ,23 ,17 ,5 ,15 ,19 ,33 ,20 ,10 ,6 ,13 ,9 ,24 ,26 ,35 ,31]


debug=1

fileName1=localName+"1.xml"

fileName2=localName+"2.xml"

#remoteName = str(config.xml)

for i in comm1:
	node_name="node-"+str(i)
	cmd_mkdir="ssh "+userName+"@"+node_name+" mkdir .Haggle"
	cmd_mkscp="scp "+fileName1+" "+userName+"@"+node_name+":.Haggle/"+remoteName
	if debug ==1:
		print node_name
		print cmd_mkdir
		print cmd_mkscp
	os.system(cmd_mkdir)
	os.system(cmd_mkscp)

print "--"

for i in comm2:
	node_name="node-"+str(i)
	cmd_mkdir="ssh "+userName+"@"+node_name+" mkdir .Haggle"
	cmd_mkscp="scp "+fileName2+" "+userName+"@"+node_name+":.Haggle/"+remoteName
	if debug ==1:
		print node_name
		print cmd_mkdir
		print cmd_mkscp
	os.system(cmd_mkdir)
	os.system(cmd_mkscp)
	
#for i in range(community):
    #for j in range(1,members+1):
      #node_number=j+i*members
      #node_name="node-"+str(node_number)
      
      #cmd_mkdir="ssh "+userName+"@"+node_name+" mkdir .Haggle"
      #fileName=localName+str(i+1)+".xml"
      #cmd_mkscp="scp "+fileName+" "+userName+"@"+node_name+":.Haggle/"+remoteName
      
      #if debug ==1:
	#print node_name
	#print cmd_mkdir
	#print cmd_mkscp
      
      #os.system(cmd_mkdir)
      #os.system(cmd_mkscp)
      
    #print "--"
      
      
     
