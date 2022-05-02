# read configs

$config = Get-Content -Path ./config.json | ConvertFrom-Json

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $config.open_communication_connection_string
$connection.Open()
$command = $connection.CreateCommand()

###############################################################################
# RULES
###############################################################################

$from_organization_id = $config.from_organization_id

# ProcessingRules
$command.CommandText = @"
  SELECT
    [Id],
    [OwnedBy],
    [Name],
    [Description],
    [Active],
    [CreatedDate],
    [OrganizationId],
    [Condition],
    [ModifiedDate],
    [CreatedBy],
    [ModifiedBy],
    [Order]
  FROM [DataStore.Db.OpenCommunication].[dbo].[ProcessingRules]
  WHERE [OrganizationId] = '${from_organization_id}'
"@
$result = $command.ExecuteReader()
$table = New-Object System.Data.DataTable
$table.Load($result)
$table | Select-Object $table.Columns.ColumnName | ConvertTo-Json | Out-File "./data/processing-rules.json"

# ProcessingRuleRules
$command.CommandText = @"
  SELECT 
    [ProcessingRuleId],
    [RuleId]
  FROM
    [DataStore.Db.OpenCommunication].[dbo].[ProcessingRuleRules]
    INNER JOIN [DataStore.Db.OpenCommunication].[dbo].[ProcessingRules]
      ON [DataStore.Db.OpenCommunication].[dbo].[ProcessingRuleRules].[ProcessingRuleId] = [DataStore.Db.OpenCommunication].[dbo].[ProcessingRules].[Id]
  WHERE [OrganizationId] = '${from_organization_id}'
"@
$result = $command.ExecuteReader()
$table = New-Object System.Data.DataTable
$table.Load($result)
$table | Select-Object $table.Columns.ColumnName | ConvertTo-Json | Out-File "./data/processing-rule-rules.json"

# Rules
$command.CommandText = @"
  SELECT
    [Id],
    [Name],
    [Description],
    [Active],
    [CreatedDate],
    [OrganizationId],
    [OwnedBy],
    [Model],
    [ModifiedDate],
    [CreatedBy],
    [ModifiedBy],
    [Order],
    [Type]
  FROM [DataStore.Db.OpenCommunication].[dbo].[Rules]
  WHERE [OrganizationId] = '${from_organization_id}'
"@
$result = $command.ExecuteReader()
$table = New-Object System.Data.DataTable
$table.Load($result)
$table | Select-Object $table.Columns.ColumnName | ConvertTo-Json | Out-File "./data/rules.json"


###############################################################################
# ENTITIES
###############################################################################

# EntityType
$command.CommandText = @"
  SELECT
    [Id],
    [Type],
    [Icon],
    [Route],
    [DisplayName],
    [Active],
    [LayoutConfiguration]
  FROM [DataStore.Db.OpenCommunication].[dbo].[EntityType]
"@
$result = $command.ExecuteReader()
$table = New-Object System.Data.DataTable
$table.Load($result)
$table | Select-Object $table.Columns.ColumnName | ConvertTo-Json | Out-File "./data/entity-type.json"

###############################################################################
# DYNAMIC VOCABULARIES
###############################################################################

# Vocabulary
$command.CommandText = @"
  SELECT
    [OrganizationId],
    [Key]
  FROM [DataStore.Db.OpenCommunication].[dbo].[Vocabulary]
  WHERE [OrganizationId] = '${from_organization_id}'
"@
$result = $command.ExecuteReader()
$table = New-Object System.Data.DataTable
$table.Load($result)
$table | Select-Object $table.Columns.ColumnName | ConvertTo-Json | Out-File "./data/vocabulary.json"

# VocabularyDefinition
$command.CommandText = @"
  SELECT
    [VocabularyId],
    [VocabularyName],
    [Grouping],
    [KeyPrefix],
    [KeySeparator],
    [VocabularySource],
    [ProviderId],
    [IsActive],
    [OrganizationId],
    [Description],
    [CreatedBy],
    [CreatedAt]
  FROM [DataStore.Db.OpenCommunication].[dbo].[VocabularyDefinition]
  WHERE [OrganizationId] = '${from_organization_id}'
"@
$result = $command.ExecuteReader()
$table = New-Object System.Data.DataTable
$table.Load($result)
$table | Select-Object $table.Columns.ColumnName | ConvertTo-Json | Out-File "./data/vocabulary-definition.json"

# VocabularyKeyDefinition
# TODO: filter by organization
$command.CommandText = @"
  SELECT
    [VocabularyKeyId],
    [VocabularyId],
    [GroupName],
    [MapsToOtherKeyId],
    [Name],
    [DataType],
    [DisplayName],
    [Description],
    [Visibility],
    [DataAnnotationsIsPrimaryKey],
    [DataAnnotationsIsEditable],
    [DataAnnotationsIsNullable],
    [DataAnnotationsIsRequired],
    [DataAnnotationsMinimumLength],
    [DataAnnotationsMaximumLength],
    [IsObsolete],
    [SortOrdinal],
    [Hints],
    [DataClassificationCode],
    [IsValueChangeInsignificant],
    [IsActive],
    [CompositeVocabularyId],
    [KeyType],
    [CreatedBy],
    [CreatedAt]
  FROM [DataStore.Db.OpenCommunication].[dbo].[VocabularyKeyDefinition]
"@
$result = $command.ExecuteReader()
$table = New-Object System.Data.DataTable
$table.Load($result)
$table | Select-Object $table.Columns.ColumnName | ConvertTo-Json | Out-File "./data/vocabulary-key-definition.json"

# VocabularyKeyGroupDefinition
# TODO: filter by organization
$command.CommandText = @"
  SELECT
    [VocabularyKeyGroupId],
    [VocabularyId],
    [Name],
    [SortOrdinal]
  FROM [DataStore.Db.OpenCommunication].[dbo].[VocabularyKeyGroupDefinition]
"@
$result = $command.ExecuteReader()
$table = New-Object System.Data.DataTable
$table.Load($result)
$table | Select-Object $table.Columns.ColumnName | ConvertTo-Json | Out-File "./data/vocabulary-key-group-definition.json"

# VocabularyOwner
# TODO: filter by organization
$command.CommandText = @"
  SELECT
    [VocabularyOwnerId],
    [OwnerId],
    [VocabularyId]
  FROM [DataStore.Db.OpenCommunication].[dbo].[VocabularyOwner]
"@
$result = $command.ExecuteReader()
$table = New-Object System.Data.DataTable
$table.Load($result)
$table | Select-Object $table.Columns.ColumnName | ConvertTo-Json | Out-File "./data/vocabulary-owner.json"

# VocabularyValue
$command.CommandText = @"
  SELECT
    [Id],
    [Value],
    [KeyId],
    [Allowed],
    [ValueRule]
  FROM [DataStore.Db.OpenCommunication].[dbo].[VocabularyValue]
"@
$result = $command.ExecuteReader()
$table = New-Object System.Data.DataTable
$table.Load($result)
$table | Select-Object $table.Columns.ColumnName | ConvertTo-Json | Out-File "./data/vocabulary-value.json"

###############################################################################
# TODO: STREAMS, EXPORT TARGETS
###############################################################################

# TODO: OrganizationProvider 
# TODO: JOIN with Provider WHERE Type = Connector
# SELECT TOP (1000) [Id]
#       ,[OrganizationId]
#       ,[UserId]
#       ,[ProviderId]
#       ,[PlanLevel]
#       ,[Active]
#       ,[Schedule]
#       ,[Configuration]
#       ,[AccountId]
#       ,[Approved]
#       ,[AccountDisplay]
#       ,[FailingAuthentication]
#       ,[LastAuthenticationError]
#       ,[WebHooks]
#       ,[CreatedDate]
#       ,[AutoSync]
#       ,[Source]
#       ,[SourceQuality]
#       ,[AuthType]
#       ,[AgentId]
#       ,[AgentGroupId]
#       ,[JobProcessingRestriction]
#       ,[LastJobQueueDate]
#       ,[LastCrawlFinishTime]
#       ,[LastJobRunId]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[OrganizationProvider]

# TODO: Streams
# SELECT TOP (1000) [Id]
#       ,[Name]
#       ,[Description]
#       ,[Active]
#       ,[CreatedDate]
#       ,[OrganizationId]
#       ,[Condition]
#       ,[ModifiedDate]
#       ,[CreatedBy]
#       ,[ModifiedBy]
#       ,[ConnectorProviderDefinitionId]
#       ,[ContainerName]
#       ,[InitialIngestionLastRun]
#       ,[InitialIngestionComplete]
#       ,[OwnedBy]
#       ,[ExportIncomingEdges]
#       ,[ExportOutgoingEdges]
#       ,[Mode]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[Streams]

# TODO: StreamMappings
# SELECT TOP (1000) [Id]
#       ,[StreamId]
#       ,[SourceDataType]
#       ,[SourceObjectType]
#       ,[DestDataType]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[StreamMappings]

# TODO: StreamRules
# SELECT TOP (1000) [StreamId]
#       ,[RuleId]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[StreamRules]

$connection.Close()