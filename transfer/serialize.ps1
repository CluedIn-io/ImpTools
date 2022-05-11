function serialize($config)
{
  $connection = New-Object System.Data.SqlClient.SqlConnection
  $connection.ConnectionString = $config.open_communication_connection_string
  $connection.Open()
  $command = $connection.CreateCommand()

  # use ./data by default - create the folder if it doesn't exist
  # otherwise use the outdir folder passed into the config
  $outdir = "./data"
  if ([bool](Get-member -Name "outdir" -InputObject $config -MemberType Properties))
  {
    $outdir = $config.outdir
  }
  if (Test-Path $outdir)
  {
    # exists
  }
  else
  {
    New-Item $outdir -ItemType Directory
  }

  $from_organization_id = $config.from_organization_id

  $command.CommandText = @"
  SELECT
      [Id]
      ,[OrganizationName]
  FROM [DataStore.Db.OpenCommunication].[dbo].[OrganizationProfile]
  WHERE [Id] = '${from_organization_id}'
"@
  $result = $command.ExecuteReader()
  $table = New-Object System.Data.DataTable
  $table.Load($result)
  if ($table.Rows.Count -gt 0)
  {
    $from_organization = $table.Rows[0][1]
    #Write-Host from_organization is $from_organization
  }
  else
  {
    Write-Host error: Id lookup failed for ${from_organization_id}
    exit -1;
  }

  $process_rules = $true
  $process_entities = $true
  $process_dynamic_vocabularies = $true
  $process_annotations = $true
  $process_mappings = $true;
  $process_datasets = $true;

  if (
      ([bool](Get-member -Name "process_filter" -InputObject $config -MemberType Properties)) -and
      ($config.process_filter)
     )
  {
    # if process_filter is on then assume all disabled unless enabled
    $process_rules = $false
    $process_entities = $false
    $process_dynamic_vocabularies = $false
    $process_annotations = $false
    $process_mappings = $false
    $process_datasets = $false

    #Write-Host *** process_filter is on ***    

    $process_rules = (
      ([bool](Get-member -Name "process_rules" -InputObject $config -MemberType Properties)) -and
      ($config.process_rules)
     )
     $process_entities = (
      ([bool](Get-member -Name "process_entities" -InputObject $config -MemberType Properties)) -and
      ($config.process_entities)
     )
     $process_dynamic_vocabularies = (
      ([bool](Get-member -Name "process_dynamic_vocabularies" -InputObject $config -MemberType Properties)) -and
      ($config.process_dynamic_vocabularies)
     )
     $process_annotations = (
      ([bool](Get-member -Name "process_annotations" -InputObject $config -MemberType Properties)) -and
      ($config.process_annotations)
     )
     $process_mappings = (
      ([bool](Get-member -Name "process_mappings" -InputObject $config -MemberType Properties)) -and
      ($config.process_mappings)
     )
     $process_datasets = (
      ([bool](Get-member -Name "process_datasets" -InputObject $config -MemberType Properties)) -and
      ($config.process_datasets)
     )
  }

  ###############################################################################
  # RULES
  ###############################################################################
  if ($process_rules)
  {
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
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/processing-rules.json"
  
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
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/processing-rule-rules.json"
  
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
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/rules.json"
  }

  ###############################################################################
  # ENTITIES
  ###############################################################################
  if ($process_entities)
  {
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
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/entity-type.json"
  }

  ###############################################################################
  # DYNAMIC VOCABULARIES
  ###############################################################################
  if ($process_dynamic_vocabularies)
  {
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
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/vocabulary.json"
  
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
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/vocabulary-definition.json"
  
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
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/vocabulary-key-definition.json"
  
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
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/vocabulary-key-group-definition.json"
  
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
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/vocabulary-owner.json"
  
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
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/vocabulary-value.json"
  }

  ###############################################################################
  # Annotations / Mappings
  ###############################################################################
  if ($process_annotations)
  {
    $command.CommandText = @"
    SELECT
      [id]
      ,[clientId]
      ,[name]
      ,[entityType]
      ,[author]
      ,[editors]
      ,[nameKey]
      ,[descriptionKey]
      ,[originEntityCodeKey]
      ,[versionKey]
      ,[cultureKey]
      ,[origin]
      ,[createdDateMap]
      ,[modifiedDateMap]
      ,[vocabularyId]
      ,[createdAt]
      ,[updatedAt]
      ,[isDynamicVocab]
    FROM [DataStore.Db.MicroServices].[dbo].[annotations]
    WHERE [clientId] = '${from_organization}'
"@
    $result = $command.ExecuteReader()
    $table = New-Object System.Data.DataTable
    $table.Load($result)
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/annotations.json"

    # hmmm, do we filter out such that we only have annotations where we matched the above WHERE cause?
    # TODO: consider filtering on annotationId if required
    $command.CommandText = @"
    SELECT 
      [annotationId]
      ,[key]
      ,[vocabKey]
      ,[coreVocab]
      ,[displayName]
      ,[useAsEntityCode]
      ,[entityCodeOrigin]
      ,[useAsAlias]
      ,[type]
      ,[edges]
      ,[validations]
      ,[transformations]
      ,[vocabularyKeyId]
    FROM [DataStore.Db.MicroServices].[dbo].[annotationProperties]
"@
    $result = $command.ExecuteReader()
    $table = New-Object System.Data.DataTable
    $table.Load($result)
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/annotation-properties.json"
  }

  if ($process_mappings)
  {
    $command.CommandText = @"
    SELECT
      [originalField]
      ,[dataSetId]
      ,[key]
      ,[edges]
    FROM [DataStore.Db.MicroServices].[dbo].[DataSetAnnotationMappings]
"@
    $result = $command.ExecuteReader()
    $table = New-Object System.Data.DataTable
    $table.Load($result)
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/dataset-annotation-mappings.json"
  }

  ###############################################################################
  # Data Sets and Source Definitions
  ###############################################################################
  if ($process_datasets)
  {
    # TODO: filter by type = file?
    $command.CommandText = @"
    SELECT
      [id]
      ,[name]
      ,[clientId]
      ,[originalFields]
      ,[originalContent]
      ,[annotationId]
      ,[type]
      ,[author]
      ,[stats]
      ,[configuration]
      ,[noSubmissions]
      ,[hasError]
      ,[errorType]
      ,[latestErrorMessage]
      ,[createdAt]
      ,[updatedAt]
      ,[dataSourceId]
      ,[expectedTotal]
    FROM [DataStore.Db.MicroServices].[dbo].[DataSets]
    WHERE [clientId] = '${from_organization}'
"@
    $result = $command.ExecuteReader()
    $table = New-Object System.Data.DataTable
    $table.Load($result)
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/datasets.json"

    # these are the source set groups
    $command.CommandText = @"
    SELECT
      [id]
      ,[name]
      ,[clientId]
      ,[author]
      ,[editors]
      ,[createdAt]
      ,[updatedAt]
    FROM [DataStore.Db.MicroServices].[dbo].[DataSourceSets]    
    WHERE [clientId] = '${from_organization}'
"@
    $result = $command.ExecuteReader()
    $table = New-Object System.Data.DataTable
    $table.Load($result)
    $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray | Out-File "$outdir/datasourcesets.json"
  }

# TODO: do NOT import these... but we need to have provisions in the related tables...
# SELECT TOP (1000) [id]
#       ,[processing]
#       ,[mimeType]
#       ,[size]
#       ,[fileName]
#       ,[filePath]
#       ,[md5]
#       ,[originalContent]
#   FROM [DataStore.Db.MicroServices].[dbo].[DataSourceFiles]
# likewise with FROM [DataStore.Db.MicroServices].[dbo].[DataSources]

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
}

### MAIN ###
if (Test-Path env:TRANSER_SKIP_MAIN)
{
  # we are running unit tests
  Write-Host "running unit tests"
}
else
{
  # read configs
  $config = Get-Content -Path ./config.json | ConvertFrom-Json
  serialize($config)  
}
