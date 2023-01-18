

function New-DataSet{
    [CmdletBinding()] param (
    [Parameter()] [string] $ADFDataSetContainer,
    [Parameter()] [string] $ADFDataSetFolderPath,
    [Parameter()] [string] $ADFDataSetTemplate,
    [Parameter()] [string] $ADFDataSetSrcFile,
    [Parameter()] [string] $ADFDataSetName,
    [Parameter()] [string] $ADFBLOBLinkedService
    )

    $Config = Get-Content $ADFDataSetTemplate | ConvertFrom-Json -Depth 10
    $Config.properties.linkedServiceName.referenceName = $ADFBLOBLinkedService
    $Config.properties.folder.name = $Folder
    $Config.properties.typeProperties.location.container = $ADFDataSetContainer
    $Config.properties.typeProperties.location.folderPath= $ADFDataSetFolderPath
    $Config.properties.typeProperties.location.fileName = $ADFDataSetSrcFile
    $Config.properties.typeProperties.location.type = "AzureBlobStorageLocation"
    $Config | ConvertTo-Json -Depth 10 | set-content $pathToTmpJson
    #Remove-Variable Config


    try {
      New-AzDataFactoryV2Dataset -DataFactoryName $ADF.DataFactoryName -ResourceGroupName $ADF.ResourceGroupName -Name $ADFDataSetName -File $pathToTmpJson
      Remove-Item -Path $pathToTmpJson
    }
    catch {
        Write-Warning $Error[0]
    }
    
}

function New-DataFlow{
    [CmdletBinding()] param (
        [Parameter()] [string] $ADFDataSetTemplate,
        [Parameter()] [string] $ADFDataSetName
    )
    
    $Config = Get-Content $ADFDataSetTemplate | ConvertFrom-Json -Depth 100
    $Config.properties.folder.name = $Folder

    #Set Source
    foreach ($currentItemName in $Config.properties.typeProperties.sources) {
      
        foreach ($currentItemName1 in $currentItemName.dataset) {
           $currentItemName1.referenceName = $SCR_DataSetName
        }
    }
    #Set Sink
    foreach ($currentItemName in $Config.properties.typeProperties.sinks) {
      
        foreach ($currentItemName1 in $currentItemName.dataset) {
           $currentItemName1.referenceName = $TGT_DataSetName
        }
    }

    
    
    $Config | ConvertTo-Json -Depth 100 | set-content $pathToTmpJson
    Remove-Variable Config

    try {
      Set-AzDataFactoryV2DataFlow -ResourceGroupName $ADF.ResourceGroupName -DataFactoryName $ADF.DataFactoryName -Name $ADFDataSetName -DefinitionFile $pathToTmpJson
      Remove-Item -Path $pathToTmpJson
  }
  catch {
      Write-Warning $Error[0]
  }


}
   
function New-Pipeline{
        [CmdletBinding()] param (
            [Parameter()] [string] $ADFPipelineTemplate,
            [Parameter()] [string] $ADFPipelineName,
            [Parameter()] [string] $ADFIngestionEndpoint,
            [Parameter()] [string] $ADFRESTDataset,
            [Parameter()] [string] $ADFDataSetSrcName,
            [Parameter()] [string] $ADFDFL_Name
        )

        $Config = Get-Content $ADFPipelineTemplate| ConvertFrom-Json -Depth 100
        $Config.properties.folder.name = $Folder

        #Process 
        foreach ($currentItemName in $Config.properties.activities) {

            foreach ($currentItemName1 in $currentItemName) {
             
              ### Dataflow Activity
               if ($currentItemName1.name -eq 'JSON Flattening Dataflow') {
                  
               foreach ($currentItemName2 in $currentItemName.typeProperties) {              
                     #Set Dataflow Name
                     $currentItemName2.dataflow.referenceName = $ADFDFL_Name
                  }
               }
               ### Copy Data Activity
               if ($currentItemName1.name -eq 'DF_Output-CluedIn') {
                  
                 
                  foreach ($InputSettings in $currentItemName.inputs) {
                     #Set DataCopy Sink
                     $InputSettings.referenceName = $ADFDataSetSrcName
                
                  }
                  foreach ($OutputSettings in $currentItemName.outputs) {
                     #Set DataCopy Sink
                     $OutputSettings.referenceName = $ADFRESTDataset
                     $OutputSettings.parameters.relativeUrl = "upload/api/endpoint/$ADFIngestionEndpoint" 

                  }
      
                  
               }
               ### Delete Activity
               if ($currentItemName1.name -eq 'Remove_DF_Output') {
                  
                  foreach ($RemoveDS in $currentItemName.typeProperties) {
                     #Set DataCopy Sink
                     $RemoveDS.dataset.referenceName = $ADFDataSetSrcName
      
                  }
      
               }
      
            }
      
         }

         $Config | ConvertTo-Json -Depth 100 | set-content $pathToTmpJson
         Remove-Variable Config

         try {
            New-AzDataFactoryV2Pipeline -ResourceGroupName $ADF.ResourceGroupName -DataFactoryName $ADF.DataFactoryName -Name $ADFPipelineName -DefinitionFile $pathToTmpJson
            Remove-Item -Path $pathToTmpJson
         }
         catch {
             Write-Warning $Error[0]
         }
       
         
} 

function Remove-CluedInFlattenPieline  {
    param (
      
    )
    Remove-AzDataFactoryV2Pipeline -DataFactoryName $ADF.DataFactoryName -ResourceGroupName $ADF.ResourceGroupName -Name $PLI_Name -Force
    Remove-AzDataFactoryV2DataFlow -DataFactoryName $ADF.DataFactoryName -ResourceGroupName $ADF.ResourceGroupName -Name $DFL_Name -Force
    Remove-AzDataFactoryV2Dataset -DataFactoryName $ADF.DataFactoryName -ResourceGroupName $ADF.ResourceGroupName -Name $SCR_DataSetName -Force
    Remove-AzDataFactoryV2Dataset -DataFactoryName $ADF.DataFactoryName -ResourceGroupName $ADF.ResourceGroupName -Name $TGT_DataSetName -Force
 }
 
 function new-CluedInFlattenPieline {
 
    ## Src Dataset
    New-DataSet -ADFDataSetContainer $SRC_DataSetContainer -ADFDataSetFolderPath $SRC_DataSetFolderPath -ADFDataSetSrcFile $SRC_DataSetSrcFile -ADFDataSetName $SCR_DataSetName -ADFDataSetTemplate $SRC_pathToJson -ADFBLOBLinkedService $BLOBLinkedServiceName
    ## TGT Dataset
    New-DataSet -ADFDataSetContainer $TGT_DataSetContainer -ADFDataSetFolderPath $TGT_DataSetFolderPath -ADFDataSetSrcFile $TGT_DataSetSrcFile -ADFDataSetName $TGT_DataSetName -ADFDataSetTemplate $TGT_pathToJson -ADFBLOBLinkedService $BLOBLinkedServiceName
    ### Dataflow
    New-DataFlow -ADFDataSetTemplate $DFL_pathToJson -ADFDataSetName $DFL_Name 
    ### Pipeline
    New-Pipeline -ADFPipelineTemplate $PLI_pathToJson -ADFPipelineName $PLI_Name -ADFDataSetSrcName $TGT_DataSetName  -ADFIngestionEndpoint $cluedInIngestionEndpoint -ADFDFL_Name $DFL_Name -ADFRESTDataset $RESTDataset
 }
 
 
 
 write-Host "ADF Functions"