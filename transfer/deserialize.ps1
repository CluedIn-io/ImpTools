function deserialize($config)
{
  $connection = New-Object System.Data.SqlClient.SqlConnection
  $connection.ConnectionString = $config.open_communication_connection_string
  $connection.Open()  
  $command = $connection.CreateCommand()
  
  # TODO: this one should be looked up instead
  # TODO: alternatively, if config has only one and not the other then we can look it up
  $to_organization = $config.to_organization

  $to_organization_id = $config.to_organization_id
  $to_user_id = $config.to_user_id

  $indir = "./data"
  if ([bool](Get-member -Name "indir" -InputObject $config -MemberType Properties))
  {
    $indir = $config.indir
  }

  # TODO: we should support filtering by process_*
  $process_rules = $true
  $process_entities = $true
  $process_dynamic_vocabularies = $true
  $process_annotations = $true
  $process_mappings = $true;
  $process_datasets = $true;
  
  ###############################################################################
  # RULES
  ###############################################################################
  
  if ($process_rules)
  {
    # ProcessingRules
    Get-Content "$indir/processing-rules.json" | ConvertFrom-Json | foreach {
      $id = $_.Id
      $owned_by = $_.OwnedBy
      $name = $_.Name
      $description = $_.Description
      $active = $_.Active
      $created_date = $_.CreatedDate
      $condition = $_.Condition
      $modified_date = $_.ModifiedDate
      $order = $_.Order
    
      #Write-Host 'ProcessingRules', $id
    
      $command.CommandText = @"
        IF (NOT EXISTS (SELECT NULL FROM [DataStore.Db.OpenCommunication].[dbo].[ProcessingRules] WHERE [Id] = '${id}'))
        BEGIN
          INSERT INTO [DataStore.Db.OpenCommunication].[dbo].[ProcessingRules]
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
          UPDATE [DataStore.Db.OpenCommunication].[dbo].[ProcessingRules]
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
    Get-Content "$indir/rules.json" | ConvertFrom-Json | foreach {
      $id = $_.Id
      $name = $_.Name
      $description = $_.Description
      $active = $_.Active
      $created_date = $_.CreatedDate
      $model = $_.Model
      $modified_date = $_.ModifiedDate
      $order = $_.Order
      $type = $_.Type
    
      #Write-Host 'Rules', $id
    
      $command.CommandText = @"
        IF (NOT EXISTS (SELECT NULL FROM [DataStore.Db.OpenCommunication].[dbo].[Rules] WHERE [Id] = '${id}'))
        BEGIN
          INSERT INTO [DataStore.Db.OpenCommunication].[dbo].[Rules]
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
    Get-Content "$indir/processing-rule-rules.json" | ConvertFrom-Json | foreach {
      $processing_rule_id = $_.ProcessingRuleId
      $rule_id = $_.RuleId
    
      #Write-Host 'ProcessingRuleRules', $_.ProcessingRuleId, $_.RuleId
    
      $command.CommandText = @"
        IF (NOT EXISTS (SELECT NULL FROM [DataStore.Db.OpenCommunication].[dbo].[ProcessingRuleRules] WHERE [ProcessingRuleId] = '${processing_rule_id}' AND [RuleId] = '${rule_id}'))
        BEGIN
          INSERT INTO [DataStore.Db.OpenCommunication].[dbo].[ProcessingRuleRules]
          ( [ProcessingRuleId],
            [RuleId])
          VALUES
          ( '${processing_rule_id}',
            '${rule_id}')
        END
"@
    
      $command.ExecuteScalar()
    }
  }
  
  ###############################################################################
  # ENTITIES
  ###############################################################################
  
  if ($process_entities)
  {
    Get-Content "$indir/entity-type.json" | ConvertFrom-Json | foreach {
      $id = $_.Id
      $type = $_.Type
      $icon = $_.Icon
      $route = $_.Route
      $display_name = $_.DisplayName
      $active = $_.Active
      $layout_configuration = $_.LayoutConfiguration
    
      #Write-Host 'Rules', $id
    
      $command.CommandText = @"
        IF (NOT EXISTS (SELECT NULL FROM [DataStore.Db.OpenCommunication].[dbo].[EntityType] WHERE [Id] = '${id}'))
        BEGIN
          INSERT INTO [DataStore.Db.OpenCommunication].[dbo].[EntityType]
          ( [Id],
          [Type],
          [Icon],
          [Route],
          [DisplayName],
          [Active],
          [LayoutConfiguration] )
          VALUES
          ( '${id}',
            '${type}',
            '${icon}',
            '${route}',
            '${display_name}',
            '${active}',
            '${layout_configuration}')
        END
"@
    
      $command.ExecuteScalar()
    }
  }
 
  # TODO: RUDI UPTO HERE!!!
  # update all these SELECTs to INSERTs

  exit -1;

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
    # TODO: filter by organization - how?
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
    # TODO: filter by organization - how?
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
    # TODO: filter by organization - how?
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
  # read the config file
  $config = Get-Content -Path ./config.json | ConvertFrom-Json
  deserialize($config)  
}
