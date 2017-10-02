#! /usr/bin/python

import os
import StringIO
import time, datetime

def parse_argument():
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("-i")
    parser.add_option("-o")
    parser.add_option("-t")
    (options,args) = parser.parse_args()
    return options
	
def proces(strDateDist, endDateDist, inputfile):
	for line in inputfile:
		elems = line.strip().split("|")
		security = elems[0]
		startDate = elems[2]
		endDate = elems[3]
		if (security in strDateDist):
			if(startDate < strDateDist[security]):
				strDateDist[security] = startDate
		else:
			strDateDist[security] = startDate
			
		if (security in endDateDist):
			if(endDate > endDateDist[security]):
				endDateDist[security] = endDate
		else:
			endDateDist[security] = endDate
			
def output(strDateDist, endDateDist, item, outputfile):
	for security in strDateDist:
		startDate = datetime.datetime.strptime(strDateDist[security], "%Y%m%d")
		endDate = datetime.datetime.strptime(endDateDist[security], "%Y%m%d")
		delta = endDate - startDate
		print delta
		while (delta.days > 730):
			endDate_tmp = startDate + datetime.timedelta(days=730)
			outputfile.write(security+"|"+item+"|"+startDate.strftime('%Y%m%d')+"|"+endDate_tmp.strftime('%Y%m%d'))
			outputfile.write("\n")
			startDate = endDate_tmp + datetime.timedelta(days=1)
			delta = endDate - startDate
		outputfile.write(security+"|"+item+"|"+startDate.strftime('%Y%m%d')+"|"+endDate.strftime('%Y%m%d'))
		outputfile.write("\n")

strDateDist = {}
endDateDist = {}

option = parse_argument()
inputfile = open(option.i, "r")
outputfile = open(option.o, "w")
item = option.t.strip()
proces(strDateDist, endDateDist, inputfile)
output(strDateDist, endDateDist, item, outputfile)

inputfile.close()
outputfile.close()
	
