# read the config file

$config = Get-Content -Path ./config.json | ConvertFrom-Json

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $config.open_communication_connection_string
$connection.Open()

$command = $connection.CreateCommand()

$to_organization_id = $config.to_organization_id
$to_user_id = $config.to_user_id

###############################################################################
# RULES
###############################################################################

# ProcessingRules

Get-Content "./data/processing-rules.json" | ConvertFrom-Json | foreach {
  $id = $_.Id
  $owned_by = $_.OwnedBy
  $name = $_.Name
  $description = $_.Description
  $active = $_.Active
  $created_date = $_.CreatedDate
  $condition = $_.Condition
  $modified_date = $_.ModifiedDate
  $order = $_.Order

  Write-Host 'ProcessingRules', $id

  $command.CommandText = @"
    IF (NOT EXISTS (SELECT NULL FROM [dbo].[ProcessingRules] WHERE [Id] = '${id}'))
    BEGIN
      INSERT INTO [dbo].[ProcessingRules]
      ( [Id],
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
        [Order])
      VALUES
      ( '${id}',
        '${to_user_id}',
        '${name}',
        '${description}',
        '${active}',
        '${created_date}',
        '${to_organization_id}',
        '${condition}',
        '${modified_date}',
        '${to_user_id}',
        '${to_user_id}',
        '${order}')
    END
    ELSE
    BEGIN
      UPDATE [dbo].[ProcessingRules]
      SET
        [OwnedBy] = '${to_user_id}',
        [Name] = '${name}',
        [Description] = '${description}',
        [Active] = '${active}',
        [CreatedDate] = '${created_date}',
        [OrganizationId] = '${to_organization_id}',
        [Condition] = '${condition}',
        [ModifiedDate] = '${modified_date}',
        [CreatedBy] = '${to_user_id}',
        [ModifiedBy] = '${to_user_id}',
        [Order] = '${order}'
      WHERE [Id] = '${id}'
    END
"@

  $command.ExecuteScalar()
}

# Rules

Get-Content "./data/rules.json" | ConvertFrom-Json | foreach {
  $id = $_.Id
  $name = $_.Name
  $description = $_.Description
  $active = $_.Active
  $created_date = $_.CreatedDate
  $model = $_.Model
  $modified_date = $_.ModifiedDate
  $order = $_.Order
  $type = $_.Type

  Write-Host 'Rules', $id

  $command.CommandText = @"
    IF (NOT EXISTS (SELECT NULL FROM [dbo].[Rules] WHERE [Id] = '${id}'))
    BEGIN
      INSERT INTO [dbo].[Rules]
      ( [Id],
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
        [Type])
      VALUES
      ( '${id}',
        '${name}',
        '${description}',
        '${active}',
        '${created_date}',
        '${to_organization_id}',
        '${to_user_id}',
        '${model}',
        '${modified_date}',
        '${to_user_id}',
        '${to_user_id}',
        '${order}',
        '${type}')
    END
"@

  $command.ExecuteScalar()
}

# ProcessingRuleRules

Get-Content "./data/processing-rule-rules.json" | ConvertFrom-Json | foreach {
  $processing_rule_id = $_.ProcessingRuleId
  $rule_id = $_.RuleId

  Write-Host 'ProcessingRuleRules', $_.ProcessingRuleId, $_.RuleId

  $command.CommandText = @"
    IF (NOT EXISTS (SELECT NULL FROM [dbo].[ProcessingRuleRules] WHERE [ProcessingRuleId] = '${processing_rule_id}' AND [RuleId] = '${rule_id}'))
    BEGIN
      INSERT INTO [dbo].[ProcessingRuleRules]
      ( [ProcessingRuleId],
        [RuleId])
      VALUES
      ( '${processing_rule_id}',
        '${rule_id}')
    END
"@

  $command.ExecuteScalar()
}

###############################################################################
# ENTITIES
###############################################################################

# TODO: EntityType
# SELECT TOP (1000) [Id]
#       ,[Type]
#       ,[Icon]
#       ,[Route]
#       ,[DisplayName]
#       ,[Active]
#       ,[LayoutConfiguration]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[EntityType]

###############################################################################
# DYNAMIC VOCABULARIES
###############################################################################

# TODO: Vocabulary
# SELECT TOP (1000) [Id]
#       ,[OrganizationId]
#       ,[Key]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[Vocabulary]

# TODO: VocabularyDefinition
# SELECT TOP (1000) [VocabularyId]
#       ,[VocabularyName]
#       ,[Grouping]
#       ,[KeyPrefix]
#       ,[KeySeparator]
#       ,[VocabularySource]
#       ,[ProviderId]
#       ,[IsActive]
#       ,[OrganizationId]
#       ,[Description]
#       ,[CreatedBy]
#       ,[CreatedAt]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[VocabularyDefinition]

# TODO: VocabularyKeyDefinition
# SELECT TOP (1000) [VocabularyKeyId]
#       ,[VocabularyId]
#       ,[GroupName]
#       ,[MapsToOtherKeyId]
#       ,[Name]
#       ,[DataType]
#       ,[DisplayName]
#       ,[Description]
#       ,[Visibility]
#       ,[DataAnnotationsIsPrimaryKey]
#       ,[DataAnnotationsIsEditable]
#       ,[DataAnnotationsIsNullable]
#       ,[DataAnnotationsIsRequired]
#       ,[DataAnnotationsMinimumLength]
#       ,[DataAnnotationsMaximumLength]
#       ,[IsObsolete]
#       ,[SortOrdinal]
#       ,[Hints]
#       ,[DataClassificationCode]
#       ,[IsValueChangeInsignificant]
#       ,[IsActive]
#       ,[CompositeVocabularyId]
#       ,[KeyType]
#       ,[CreatedBy]
#       ,[CreatedAt]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[VocabularyKeyDefinition]

# TODO: VocabularyKeyGroupDefinition
# SELECT TOP (1000) [VocabularyKeyGroupId]
#       ,[VocabularyId]
#       ,[Name]
#       ,[SortOrdinal]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[VocabularyKeyGroupDefinition]

# TODO: VocabularyOwner
# SELECT TOP (1000) [VocabularyOwnerId]
#       ,[OwnerId]
#       ,[VocabularyId]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[VocabularyOwner]

# TODO: VocabularyValue
# SELECT TOP (1000) [Id]
#       ,[Value]
#       ,[KeyId]
#       ,[Allowed]
#       ,[ValueRule]
#   FROM [DataStore.Db.OpenCommunication].[dbo].[VocabularyValue]

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