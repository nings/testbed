#!/usr/bin/env python
# usage: python gen_markov_trace.py <number-of-nodes> <run-time [s]> <output-file>

import sys
import datetime
import os
import operator
import array
import random

if len(sys.argv) != 4:
    print "usage: python " + sys.argv[0] + " <number-of-nodes> <run-time [s]> <output-file>"
    sys.exit(1)

number_of_nodes = int(sys.argv[1])
run_time = int(sys.argv[2])
out = file(sys.argv[3], "w")

first_node_index = 1

prob_inter_c=0.1
prob_intra_c=0.5

interval=10

community=4

members=number_of_nodes/community

linkState = []

for i in range(number_of_nodes):
    linkState.append([])
    for j in range(number_of_nodes):
        linkState[i].append(0)

for t in range(1,run_time,interval):
    for i in range(number_of_nodes):
            for j in range(i):
                x=i+1
                y=j+1
                
                if random.uniform(0,1)<0.5:
                    if x<=members and y<=members:
                        out.write(str(x) + "\t" + str(y) + "\t" +str(t) + "\t" + str(t+interval) + "\n")
                        out.write(str(y) + "\t" + str(x) + "\t" +str(t) + "\t" + str(t+interval) + "\n")

                    elif x>members and x<=(2*members) and y>members and y<=(2*members):
                        out.write(str(x) + "\t" + str(y) + "\t" +str(t) + "\t" + str(t+interval) + "\n")
                        out.write(str(y) + "\t" + str(x) + "\t" +str(t) + "\t" + str(t+interval) + "\n")

                    elif x>(2*members) and x<=(3*members) and y>(2*members) and y<=(3*members):
                        out.write(str(x) + "\t" + str(y) + "\t" +str(t) + "\t" + str(t+interval) + "\n")
                        out.write(str(y) + "\t" + str(x) + "\t" +str(t) + "\t" + str(t+interval) + "\n")

                    elif x>(3*members) and x<=(4*members) and y>(3*members) and y<=(4*members):
                        out.write(str(x) + "\t" + str(y) + "\t" +str(t) + "\t" + str(t+interval) + "\n")
                        out.write(str(y) + "\t" + str(x) + "\t" +str(t) + "\t" + str(t+interval) + "\n")
                    
                if random.uniform(0,1)<0.1:
                    out.write(str(x) + "\t" + str(y) + "\t" +str(t) + "\t" + str(t+interval) + "\n")
                    out.write(str(y) + "\t" + str(x) + "\t" +str(t) + "\t" + str(t+interval) + "\n")

out.close()
