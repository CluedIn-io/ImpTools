# this script is an example of how sampling number of big datasets for the demo and pilot purposes
# we load parquet and json files into mongo and then select a subset of the data

# Run this in your console to install dependencies:
  # pip install pyarrow
  # pip install pymongo

import pyarrow.parquet as pq
from pymongo import MongoClient, ASCENDING
import json

mongo_client = MongoClient()
db = mongo_client['demo_sample']

# mongodb collections:
salesforce_account_collection = db['salesforce_account']
salesforce_contact_collection = db['salesforce_contact']
d365_contact_collection = db['d365_contact']

# this collection will store emails which will let us know in which sources the same email appears
emails_collection = db['emails']

# the function reads a parquet file and transforms it into a mongo collection
def parquet_to_mongo(parquet_file, mongo_collection):
  table = pq.read_table(parquet_file)
  json_data = json.loads(table.to_pandas().to_json())
  
  # parquet stores data in columns, so the json will look like this:
  # { 'id': { '0': 1, '1': 2 }, 'name': { '0': 'John', '1': 'Jane' }, 'age': { '0': 30, '1': 25 } }
  # we need to transform it to this:
  # [{'id': '1', 'name': 'John', 'age': '30'}, {'id': '2', 'name': 'Jane', 'age': '25'}]

  keys = list(json_data.keys())

  index = 0
  limit = len(json_data[keys[0]])

  while index < limit:
    doc = {}
    for key in keys:
      doc[key] = json_data[key][str(index)]
    mongo_collection.insert_one(doc)
    index += 1
    if index % 10000 == 0:
      print(str(index).rjust(10, ' ') + ' / ' + str(limit))

# the function reads a json file and transforms it into a mongo collection
def json_to_mongo(json_file, mongo_collection):
  with open(json_file, 'rb') as json_data:
    data = json.load(json_data)
    mongo_collection.insert_many(data)
    print('Inserted ' + str(len(data)) + ' documents')

# the function loads all data to mongo
def to_mongo():
  parquet_to_mongo('./Account.parquet', salesforce_account_collection)
  parquet_to_mongo('./Contact.parquet', salesforce_contact_collection)

  json_to_mongo('./Contacts.json', d365_contact_collection)

# the function recreates the emails collection and counts the stats for emails from different sources
def count_emails():
  emails_collection.drop()
  emails_collection.create_index([('count', ASCENDING)])
  emails_collection.create_index([('sources', ASCENDING)])

  # we save it like that:
  # { '_id': 'john@doe.com',
  #   {
  #     'sources': [ 'd365', 'salesforce' ],
  #     'count': 3
  #   }
  # }

  # where the count shows us the number of times the email appears in different sources
  # and the sources array shows us which sources the email appears in:

  for doc in d365_contact_collection.find():
    if 'EmailAddress' in doc:
      emails_collection.update_one({ '_id': doc['EmailAddress'] }, { '$inc': { 'count': 1 }, '$addToSet': { 'sources': 'd365' } }, upsert=True)

  for doc in salesforce_contact_collection.find():
    if 'Email' in doc:
      emails_collection.update_one({ '_id': doc['Email'] }, { '$inc': { 'count': 1 }, '$addToSet': { 'sources': 'salesforce' } }, upsert=True)
  
# db.emails.countDocuments()
# 1.278.120

# db.emails.find({ sources: { $size: 2 }  }).count()
# 505.907

# db.emails.find({ sources: { $size: 3 }  }).count()
# 80.031

# db.emails.find({ sources: { $size: 3 }, count: { $gte: 4 }  }).count()
# 9.504 (9.504 * 4 = 39.008)

# db.emails.find({ sources: { $size: 3 }, count: { $gte: 5 }  }).count()
# 906

# db.emails.aggregate(
#   [
#     { $unwind: '$sources' },
#     { $group: { _id: '$_id', size: { $sum: 1 } } },
#     { $group: { _id: '$size', count: { $sum: 1 } } },
#     { $sort: { count: -1 }  }
#   ],
#   { allowDiskUse: true  })

# { _id: 1, count: 692182 }
# { _id: 2, count: 505907 }
# { _id: 3, count: 80031 }

# the function selects a subset of emails and marks them as selected
def select_emails():
  emails_collection.create_index([('selected', ASCENDING)])
  for doc in emails_collection.find({ 'sources': { '$size': 3 }, 'count': { '$gte': 5 }  }):
    emails_collection.update_one({ '_id': doc['_id'] }, { '$set': { 'selected': True } })

# the function goes through the emails collection and for each selected email, updates the corresponding datasources
def select_docs_by_email():
  user_collection.create_index([('selected', ASCENDING)])
  team_user_collection.create_index([('selected', ASCENDING)])
  team_collection.create_index([('selected', ASCENDING)])
  
  d365_contact_collection.create_index([('selected', ASCENDING)])
  
  salesforce_contact_collection.create_index([('selected', ASCENDING)])


  for doc in emails_collection.find({ 'selected': True }):
    user_collection.update_many({ 'email': doc['_id'] }, { '$set': { 'selected': True } })
    d365_contact_collection.update_many({ 'EmailAddress': doc['_id'] }, { '$set': { 'selected': True } })
    salesforce_contact_collection.update_many({ 'Email': doc['_id'] }, { '$set': { 'selected': True } })

  for doc in user_collection.find({ 'selected': True }):
    team_user_collection.update_many({ 'user_id': doc['id'] }, { '$set': { 'selected': True } })

  for doc in team_user_collection.find({ 'selected': True }):
    team_collection.update_many({ 'id': doc['team_id'] }, { '$set': { 'selected': True } })

def select_salesforce_accounts():
  # db.salesforce_contact.countDocuments()
  # 760.355

  # db.salesforce_contact.countDocuments({ selected: true })
  # 2.107
  for salesforce_contact in salesforce_contact_collection.find({ 'selected': True }):
    salesforce_account_collection.update_one({ 'Id': salesforce_contact['AccountId'] }, { '$set': { 'selected': True } })

  # db.salesforce_account.countDocuments()
  # 367.771

  # db.salesforce_account.countDocuments({ selected: true })
  # 1.586

# the function dumps selected documents from a given mongo collection to JSON
def dump_selected(collection, filename):
  docs = []
  for doc in collection.find({ 'selected': True }):
    doc.pop('_id')
    doc.pop('selected')
    docs.append(doc)
  with open(filename, 'w') as file:
    json.dump(docs, file, indent=2)

def export_all():
  dump_selected(salesforce_account_collection, './Account.json')
  dump_selected(salesforce_contact_collection, './Contact.json')
  
export_all()
