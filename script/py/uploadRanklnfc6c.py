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

#INFC Kclique k=3 6 commmunity
commNum=6
comm=[[ 11, 58, 64, 68, 14, 17, 56, 47, 40, 62, 42, 30, 57, 73, 46, 61, 70, 71, 8, 65, 66, 52, 67, 75, 59],
[  15, 18, 20, 29, 35, 41, 43, 7, 16, 36, 53],
[  33, 6, 38],
[  44, 50, 25, 54, 34],
[  29, 19, 26, 32, 33, 69],
[  36, 2, 47, 5, 55, 6]]

#INFC Kclique k=4 8 commmunity
#commNum=8
#comm=[[  15, 18, 20, 29, 35, 43, 7, 36],
#[  73, 8, 52, 67],
#[  19, 26, 32, 33, 69],
#[  36, 2, 5, 55, 6],
#[  44, 50, 25, 54],
#[  58, 64, 30, 57],
#[  47, 40, 73, 61, 8, 66],
#[  58, 68, 56, 40, 73, 46]]

dictRank={2:19,
3:0,
4:8,
5:22,
6:17,
7:14,
8:19,
9:2,
10:10,
11:14,
12:6,
13:4,
14:4,
15:16,
16:5,
17:5,
18:24,
19:17,
20:18,
21:8,
22:8,
23:24,
24:27,
25:15,
26:18,
27:13,
28:14,
29:29,
30:9,
31:14,
32:47,
33:18,
34:21,
35:6,
36:30,
37:8,
38:22,
39:4,
40:22,
41:136,
42:5,
43:21,
44:32,
45:2,
46:22,
47:22,
48:31,
49:6,
50:17,
51:8,
52:22,
53:30,
54:31,
55:9,
56:21,
57:22,
58:22,
59:9,
60:33,
61:25,
62:24,
63:13,
64:116,
65:33,
66:19,
67:9,
68:13,
69:24,
70:26,
71:16,
72:4,
73:28,
74:2,
75:32,
76:3,
77:9,
78:3}


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
		#nodeRank=str(i)
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
