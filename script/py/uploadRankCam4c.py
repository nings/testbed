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

#invalid
localName = str(sys.argv[1])
remoteName = str(sys.argv[2])
#invalid
number_of_nodes = int(sys.argv[3])

userName="user"
configTemplate=localName+"config.template.xml"

#CAM 4 commmunity
commNum=4
comm=[[11 ,29],
[3 ,32 ,7 ,28 ,16 ,34 ,36 ,22 ,21 ,25 ,27 ,12 ,8],
[1 ,4 ,30 ,2 ,14 ,18 ,23 ,17 ],
[5 ,15 ,19 ,33 ,20 ,10 ,6 ,13 ,9 ,24 ,26 ,35 ,31]]

#newman
#commNum=4
#comm=[[1, 2, 4, 5, 6, 9, 10, 13, 14, 15, 17, 18, 19, 20, 23, 30, 33],
#[3, 11, 22, 25, 27, 29, 34, 36, 7, 8, 12, 16, 21, 28, 32],
#[24, 26, 35],
#[31]]

#Kclique
#commNum=2
#comm=[[1, 12, 18, 20, 4, 5, 10, 6, 15, 17, 19, 2, 23, 33],
#[11, 21, 36, 12, 25, 28, 3, 34, 7, 16, 22, 27, 32]]

#Eiko Paper
#commNum=2
#comm1=[[11 ,29 ,3 ,32 ,7 ,28 ,16 ,34 ,36 ,22 ,21 ,25 ,27 ,12 ,8],
#[1 ,4 ,30 ,2 ,14 ,18 ,23 ,17 ,5 ,15 ,19 ,33 ,20 ,10 ,6 ,13 ,9 ,24 ,26 ,35 ,31]]

#Rank average
dictRank={1:30,
2:55,
3:76,
4:66,
5:28,
6:200,
7:73,
8:0,
9:11,
10:25,
11:22,
12:17,
13:50,
14:159,
15:51,
16:168,
17:11,
18:250,
19:37,
20:27,
21:52,
22:40,
23:29,
24:4,
25:62,
26:22,
27:27,
28:24,
29:15,
30:19,
31:9,
32:18,
33:37,
34:252,
35:5,
36:28}

debug=1

# sed "s/\$LABEL/label/g" config.template.xml | sed "s/\$RANK/"rank"/g"

def sedfunc( rep , ch ):
	if ch=="label":
		sedstr="sed \"s/\$LABEL/"+rep+"/g\""
	if ch=="rank":
		sedstr="sed \"s/\$RANK/"+rep+"/g\""
	return sedstr

os.system("rm "+localName+"node-*.xml")

for x in range(commNum):
	
	nodeLabel="label"+str(x+1)
			
	if debug==1:
		print comm[x]
	
	for i in comm[x]:
		node_name="node-"+str(i)
		
		nodeRank=str(dictRank[i])
		
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