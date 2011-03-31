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

#CAM 4 commmunity
commNum=4
#comm=[[11 ,29],
#[3 ,32 ,7 ,28 ,16 ,34 ,36 ,22 ,21 ,25 ,27 ,12 ,8],
#[1 ,4 ,30 ,2 ,14 ,18 ,23 ,17 ],
#[5 ,15 ,19 ,33 ,20 ,10 ,6 ,13 ,9 ,24 ,26 ,35 ,31]]

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

debug=1

for x in range(commNum):
	fileName=localName+str(x+1)+".xml"
	if debug==1:
		print comm[x]
		print fileName
	for i in comm[x]:
		#print i
		node_name="node-"+str(i)
		cmd_mkdir="ssh "+userName+"@"+node_name+" mkdir .Haggle"
		cmd_mkscp="scp "+fileName+" "+userName+"@"+node_name+":.Haggle/"+remoteName
		#cmd_mktest="scp "+localName+testFile+" "+userName+"@"+node_name+":.Haggle/"+testFile
		if debug ==1:
			print node_name
			print cmd_mkdir
			print cmd_mkscp
			#print cmd_mktest
		os.system(cmd_mkdir)
		os.system(cmd_mkscp)
		#os.system(cmd_mktest)

#print "--"

#for i in comm2:
	#node_name="node-"+str(i)
	#cmd_mkdir="ssh "+userName+"@"+node_name+" mkdir .Haggle"
	#cmd_mkscp="scp "+fileName2+" "+userName+"@"+node_name+":.Haggle/"+remoteName
	#if debug ==1:
		#print node_name
		#print cmd_mkdir
		#print cmd_mkscp
	#os.system(cmd_mkdir)
	#os.system(cmd_mkscp)
	
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
