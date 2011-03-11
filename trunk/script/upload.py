#!/usr/bin/env python
# usage: generate config.xml (label depends on community and rank is the nodeId) and upload to nodes 
import sys
import datetime
import os
import operator
import array
import random

if len(sys.argv) != 5:
    print "usage: python " + sys.argv[0] + " <localName> <remoteName (not path)> <number of nodes> <number of community>"
    print "   copy file localName to .Haggle directory on nodes."
    sys.exit(1)

localName = str(sys.argv[1])
remoteName = str(sys.argv[2])
number_of_nodes = int(sys.argv[3])
community=int(sys.argv[4])

userName="user"
configTemplate=localName+"config.template.xml"

members=number_of_nodes/community

def sedfunc( rep , ch ):
	if ch=="label":
		sedstr="sed \"s/\$LABEL/"+rep+"/g\""
	if ch=="rank":
		sedstr="sed \"s/\$RANK/"+rep+"/g\""
	return sedstr

debug=1

for i in range(community):
	print i
	#defined by the number of community
	nodeLabel="label"+str(i+1)
	for j in range(1,members+1):
		print j
		
		node_number=j+i*members
		
		node_name="node-"+str(node_number)
		#rank is the node id random.randrange(1,100,1)
		#nodeRank=str(node_number)
		nodeRank=str(random.randrange(1,100,1))
		
		fileName=localName+node_name+".xml"
		
		cmd_genxml=sedfunc(nodeLabel,"label")+" "+configTemplate+" | "+sedfunc(nodeRank,"rank")+" > "+fileName
		
		cmd_mkdir="ssh "+userName+"@"+node_name+" mkdir .Haggle"
		
		cmd_mkscp="scp "+fileName+" "+userName+"@"+node_name+":.Haggle/"+remoteName
      
      		if debug ==1:
			print node_name
			print cmd_mkdir
			print cmd_mkscp
      
		os.system(cmd_mkdir)
		os.system(cmd_genxml)
		os.system(cmd_mkscp)
            
      
     
