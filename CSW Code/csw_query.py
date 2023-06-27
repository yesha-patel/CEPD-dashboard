#!/usr/bin/env python
# coding: utf-8
import sys
from google.cloud import bigquery
import smart_open
import pydata_google_auth

if len(sys.argv) < 3:
    print('''USAGE: python csw_query.py projectName "select columnA from aTable where columnB='this'" | gzip -c > result.tsv.gz
   or
       python csw_query.py projectName "select columnA from aTable where columnB='this'" result.tsv.gz
   NOTE: Do not include back-ticks (`) or dollar-signs ($) in the query without escaping them''') 
    sys.exit(1)

project=sys.argv[1]
if len(sys.argv) > 3:
    write_to_file = True
else:
    write_to_file = False

sql_query = sys.argv[2]
#sql_query = [] 
#line = input("Type query (hit enter twice):\n")
#while line:
#    sql_query.append(line)
#    line = input() 
#sql_query = "\n".join(sql_query)


credentials = pydata_google_auth.get_user_credentials(
    ['https://www.googleapis.com/auth/bigquery'],
)

client = bigquery.Client(credentials=credentials, project=project)
results = client.query(sql_query).result()


if write_to_file:
    writer = smart_open.open(sys.argv[3], 'w')
else:
    writer = sys.stdout
i = 0
for row in results:
    i += 1
    if i==1:
        writer.write("\t".join(row.keys()) + "\n")
    if write_to_file and (100 * i/results.total_rows) % 5 == 0:
        print(str(100 * i/results.total_rows) + "%\r")
    writer.write("\t".join(map(lambda x: str(x) ,row.values())) + "\n")
if write_to_file:
    writer.close()

