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

#Mit Kclique 8 commmunity
#comm=[[94,2,63,97,82,47],
#[26,65,93],
#[20,46,84,35,50,73,92],
#[12,19,20,23,31,4,72],
#[29,14,16,18,6,81,83,85,86,96,39,57,75,95,37,49],
#[21,51,7,74,54],
#[85,28,71,89],
#[15,76,80,91,78,32,37]]

#Mit Fielder 8 commmunity
commNum=8
comm=[[25 ,87 ],
[1 ,6 ,14 ,18 ,16 ,86 ,96 ,83 ,29 ,57 ,39 ,95 ,75 ,49 ,34 ,59 ,48 ,11 ,41 ,69 ,62 ],
[7 ,54 ,51 ,74 ,60 ,8 ,28 ,21 ,43 ,33 ,81 ,85 ,15 ,80 ,32 ,78 ,37 ,76 ,91 ,13 ,17 ,71 ,89 ],
[88 ,90 ],
[2 ,47 ,63 ,82 ,97 ,94 ,53 ],
[4 ,12 ,19 ,20 ,23 ,31 ,42 ,35 ,84 ,46 ,45 ,36 ,22 ,50 ,55 ,66 ,72 ,79 ,73 ,92 ,77 ,40 ,64 ,56 ],
[5 ,26 ,65 ,93 ,44 ,3 ,24 ,61 ,70 ,27 ,58 ,68 ,10 ,30 ,9 ],
[38 ,52, 67]]


#MIT MCP Rank average
dictRank={1:0,
2:0,
3:4,
4:0,
5:0,
6:0,
7:216,
8:0,
9:0,
10:73,
11:0,
12:0,
13:0,
14:223,
15:0,
16:4,
17:53,
18:9,
19:0,
20:120,
21:0,
22:10,
23:0,
24:5,
25:0,
26:0,
27:0,
28:0,
29:19,
30:6,
31:0,
32:197,
33:25,
34:5,
35:70,
36:1,
37:69,
38:4,
39:154,
40:0,
41:4,
42:11,
43:0,
44:0,
45:0,
46:24,
47:0,
48:0,
49:24,
50:50,
51:1,
52:0,
53:0,
54:0,
55:0,
56:0,
57:54,
58:0,
59:4,
60:17,
61:1,
62:0,
63:0,
64:0,
65:16,
66:0,
67:0,
68:0,
69:1,
70:0,
71:25,
72:33,
73:11,
74:31,
75:19,
76:103,
77:49,
78:117,
79:22,
80:41,
81:167,
82:32,
83:97,
84:55,
85:16,
86:94,
87:0,
88:0,
89:5,
90:0,
91:47,
92:16,
93:9,
94:5,
95:69,
96:118,
97:24}

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