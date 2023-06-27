library(bigrquery)

# login - follow the link, login to Google using your Bayer email 
#         and paste in the token provided in the console
bq_auth(use_oob = TRUE)
# or run the line below to login using an app-role credential
#bq_auth(path = rawToChar(base64enc::base64decode("token_hash_thing_from_vault_goes_here")))

# set project and query
project = "bcs-breeding-datasets"
sql = "select haps.Position, haps.AncestralCall 
from `bcs-breeding-datasets.breeding_genomics.ancestralHaplotypes_maize` as haps 
where haps.Line='JENU381'
and haps.Chromosome=1
and haps.Position>=100
and haps.Position<=120
order by haps.Position"

# make a query 
bqResult=bigrquery::bq_project_query(project, sql)
queryData = bq_table_download(bqResult, bigint="character") # bigint="integer64" also works
head(as.data.frame(queryData))
