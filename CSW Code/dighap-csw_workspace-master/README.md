# cws_workspace
A collection of scripts, examples, and notebooks for making Crop Science Warehouse queries

### Examples
```bash
python csw_query.py projectName "select columnA from aTable where columnB='this'" | gzip -c > result.tsv.gz

python csw_query.py projectName "select columnA from aTable where columnB='this'" result.tsv.gz

cd csw_workspace
jupytern notebook
```
R_csw.R also provides a simple example of making a CSW query in R
