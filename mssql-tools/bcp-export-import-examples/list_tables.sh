#!/bin/bash

# this is for a database in azure - accessing from our ubuntu VM in azure
sqlcmd -Stcp:example.database.windows.net,1433 -U sqladmin -P redacted -d DATA-DB -q 'select table_name from [DATA-DB].information_schema.tables'
