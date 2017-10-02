#!/usr/bin/python -tt

#HOW TO RUN python
#rm Date_diff_2.py; rm All_id.txt_date_diff
#python Date_diff_2.py All_id.txt
#head t100c.txt_date_diff

#rm File_Split_by_column.py; rm testf.txt_date_diffYLD
#python File_Split_by_column.py testf_date_diff

import re
import sys
import datetime
from calendar import monthrange

# Reads line by line, does not lock memory.
def file_work(filename):
  f = open(filename, "rU")
  column_input = raw_input("Provide column: ")
  for line in f:
    columns = line.split("|")
    item_name = (columns[int(column_input)])
    if item_name in line:
      outf = open(filename + "_" + item_name + ".txt", 'a')
      outf.write(line)
  f.close()
  outf.close()


def main():
  file_work(sys.argv[1])

# This is the standard boilerplate that calls the main() function.
if __name__ == '__main__':
  main()