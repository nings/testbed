#!/usr/bin/env python
# usage: python <localName> <remoteName (not path)> 
import sys
import datetime
import os
import operator
import array
import random

def readFile2List(fileName, listName):
  listName = [] 
  with open(fileName,"r") as f: 
    sentences = [elem for elem in f.read().split('\n') if elem] 
  for word in sentences: 
    listName.append(word.split())
  return listName
  
def readFile2Dict(fileName, dictName):
  fileHandle = open(fileName,"r")
  line = fileHandle.readline().rstrip('\n')  
  dictName = {} 
  keycounter = 1 

  while line: 
    key = str(keycounter) 
    dictName[key] = line 
    keycounter = keycounter + 1 
    line = fileHandle.readline().rstrip('\n') 
  return dictName

def sedfunc( rep , ch ):
	if ch=="label":
		sedstr="sed \"s/\$LABEL/"+rep+"/g\""
	if ch=="rank":
		sedstr="sed \"s/\$RANK/"+rep+"/g\""
	return sedstr

if len(sys.argv) != 5:
    print "usage: python " + sys.argv[0] + " <localName> <remoteName (not path)> <rankFile> <commFile>"
    sys.exit(1)

localName = str(sys.argv[1])
remoteName = str(sys.argv[2])
#number_of_nodes = int(sys.argv[3])
rankFile = str(sys.argv[3])
commFile = str(sys.argv[4])

userName="user"
configTemplate=localName+"config.template.xml"

dictRank={}
dictRank=readFile2Dict(rankFile,dictRank)
print dictRank

comm=[]
comm=readFile2List(commFile,comm)
commNum=len(comm)
print comm

debug=1

# sed "s/\$LABEL/label/g" config.template.xml | sed "s/\$RANK/"rank"/g"

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
			#print cmd_mkdir
			#print cmd_mkscp
			print cmd_genxml
		
		os.system(cmd_genxml)
		os.system(cmd_mkdir)
		os.system(cmd_mkscp)
