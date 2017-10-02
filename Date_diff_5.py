import re
import sys
import datetime
from calendar import monthrange

def file_work(filename):
  f = open(filename, 'rU')
  outf = open(filename + '_date_diff', 'w')
  for line in f:
    columns = line.split("|")
    #reads start and end date
    call_date = (columns[1])
    start_date = (columns[7])
    end_date = (columns[8])
    #assign comment to date string equal to 0 for analysis purposes
    if start_date == "0" or end_date == "0":
      out = (columns[0]) + "|" + (columns[1]) + "|" + (columns[2]) + "|" + (columns[3]) + "|" + (columns[4]) + "|" + (columns[5]) + "|" + (columns[6]) + "|" + (columns[7]) + "|" + (columns[8]) + "|" + "0_date" + "|" + "|" + (columns[9]) 
      outf.write(out)
#assign comment to date string that is not equal to 8 for analysis purposes
    elif len(start_date) != 8 or len(end_date) != 8:
      out = (columns[0]) + "|" + (columns[1]) + "|" + (columns[2]) + "|" + (columns[3]) + "|" + (columns[4]) + "|" + (columns[5]) + "|" + (columns[6]) + "|" + (columns[7]) + "|" + (columns[8]) + "|" + "less_8" + "|" + "|" + (columns[9]) 
      outf.write(out)
#exception/error management1. Due to Rover functionality that change incorrect dates (i.e. 20160132) '32'
    else:
      try:
        start_date = datetime.datetime.strptime(start_date,'%Y%m%d')
#exception/error management2a. take last 2 digits from start_date -5 days, than add to rest of start_date and join it. Than change in date format and assign last day of given month
      except ValueError:
        start_date_days = int(start_date[6:])-5
        start_date_days_str = str(start_date_days)
        start_date_days = str(start_date[0:6]),start_date_days_str
        start_date = ''.join(start_date_days)
        start_date = datetime.datetime.strptime(start_date,'%Y%m%d')
        tt = start_date.timetuple()
#if1a if month has one digit (i.e. february =2), there is need to add 0 to it.		
        last_day = monthrange((tt[0]),(tt[1]))
        if tt[1] < 10:
          last_day_0add = '0'+str(tt[1])
          proper_start_date = str(tt[0]),last_day_0add,str(last_day[1])
          start_date_proper = ''.join(proper_start_date)
          start_date = datetime.datetime.strptime(start_date_proper,'%Y%m%d')
        else:
          proper_start_date = str(tt[0]),str(tt[1]),str(last_day[1])
          start_date_proper = ''.join(proper_start_date)
          start_date = datetime.datetime.strptime(start_date_proper,'%Y%m%d')
      try:
        end_date = datetime.datetime.strptime(end_date,'%Y%m%d')
#exception/error management2b. Functionality is the same as in exception/error management2a, but for other variables
      except ValueError:
        end_date_days = int(end_date[6:])-5
        end_date_days_str = str(end_date_days)
        end_date_days = str(end_date[0:6]),end_date_days_str
        end_date = ''.join(end_date_days)
        end_date = datetime.datetime.strptime(end_date,'%Y%m%d')
        tt = end_date.timetuple()
#if1b. Functionality is the same as in if1.a, but for other variables 		
        last_day = monthrange((tt[0]),(tt[1]))
        if tt[1] < 10:
          last_day_0add = '0'+str(tt[1])
          proper_end_date = str(tt[0]),last_day_0add,str(last_day[1])
          end_date_proper = ''.join(proper_end_date)
          end_date = datetime.datetime.strptime(end_date_proper,'%Y%m%d')
        else:
          proper_end_date = str(tt[0]),str(tt[1]),str(last_day[1])
          end_date_proper = ''.join(proper_end_date)
          end_date = datetime.datetime.strptime(end_date_proper,'%Y%m%d')
#Index assignement
#call_date format change string to date      
      call_date = datetime.datetime.strptime(call_date,'%Y%m%d')
      date_delta = call_date - start_date
      days_date_delta = date_delta.days
      if date_delta.days == 0:
        data_range_index = "EOD_0"
      elif date_delta.days == 1:
        data_range_index = "EOD_1"
      elif date_delta.days > 1 and date_delta.days <= 365:
        data_range_index = "upTo1y"
      elif date_delta.days > 365 and date_delta.days <= 548:
        data_range_index = "upTo18m"
      elif date_delta.days > 548 and date_delta.days <= 730:
        data_range_index = "upTo2y"
      elif date_delta.days > 730 and date_delta.days <= 1095:
        data_range_index = "upTo3y"
      elif date_delta.days > 1095 and date_delta.days <= 1460:
        data_range_index = "upTo4y"
      elif date_delta.days > 1460:
        data_range_index = "over4y"
      else:
        data_range_index = "unclassified"
      out = (columns[0]) + "|" + (columns[1]) + "|" + (columns[2]) + "|" + (columns[3]) + "|" + (columns[4]) + "|" + (columns[5]) + "|" + (columns[6]) + "|" + (columns[7]) + "|" + (columns[8]) + "|" + str(days_date_delta) + "|" + data_range_index + "|" + (columns[9]) 
      outf.write(out)     
  f.close()
  outf.close()

def main():
  file_work(sys.argv[1])

# This is the standard boilerplate that calls the main() function.
if __name__ == '__main__':
  main()