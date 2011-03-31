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
testFile="test.txt"

#Mit Kclique 8 commmunity
commNum=8
comm=[[94,2,63,97,82,47],
[26,65,93],
[20,46,84,35,50,73,92],
[12,19,20,23,31,4,72],
[29,14,16,18,6,81,83,85,86,96,39,57,75,95,37,49],
[21,51,7,74,54],
[85,28,71,89],
[15,76,80,91,78,32,37]]

debug=1

def sedfunc( rep , ch ):
	if ch=="label":
		sedstr="sed \"s/\$LABEL/"+rep+"/g\""
	if ch=="rank":
		sedstr="sed \"s/\$RANK/"+rep+"/g\""
	return sedstr

os.system("rm "+localName+"node-*.xml")

configTemplate=localName+"config.template.xml"

for x in range(commNum):
	
	nodeLabel="label"+str(x+1)
			
	if debug==1:
		print comm[x]
	
	for i in comm[x]:
		node_name="node-"+str(i)
		#Rank is random in label
		nodeRank=str(i)
		#nodeRank=str(dictRank[i])
		fileName=localName+node_name+".xml"
		
		cmd_genxml=sedfunc(nodeLabel,"label")+" "+configTemplate+" | "+sedfunc(nodeRank,"rank")+" > "+fileName
		
		cmd_mkdir="ssh "+userName+"@"+node_name+" mkdir .Haggle"
		
		cmd_mkscp="scp "+fileName+" "+userName+"@"+node_name+":.Haggle/"+remoteName
		
		if debug ==1:
			print node_name
			print cmd_mkdir
			print cmd_mkscp
			print cmd_genxml
		
		os.system(cmd_genxml)
		os.system(cmd_mkdir)
		os.system(cmd_mkscp)