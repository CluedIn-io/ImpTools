. "$PSScriptRoot\ADF_Functions.ps1"

$pathToLog = "$PSScriptRoot\Templates\transcript.txt"
#Start-Transcript -Path $pathToLog -Append

############################################Customize Below #################################################################################################

#This script will create a structred set of ADF objects that will flatton nested JSON source files 

#ADF Vars 
#Name is used as prefix for all ADF objects
$Name = "JSON_Flatten"
#CluedIn Ingestion Endpoint Settings
$cluedInIngestionEndpoint = "C6A87B66-EFA8-4BBE-944C-B5B2B688327A"

#Source Datasets
$SRC_DataSetContainer = "JSONContainer"
$SRC_DataSetFolderPath = "dir/path"
$SRC_DataSetSrcFile = "test.json"

#Target Dataset/Output 
$TGT_DataSetContainer = "JSONContainer"
$TGT_DataSetFolderPath = "dir/path"
$TGT_DataSetSrcFile = "output.json"

#Azure & ADF Linked Services
$ADF_ResGroup = 'rg-cluedin-d'
$BLOBLinkedServiceName = "BLOB_STORAGE"
$RESTDataset = "CluedIn_JSON_Fatten_Endpoint"


##########################################  Customize Above ############################################################################





$Folder = $Name
#DataSet Vars
$SCR_DataSetName  = "SRC_$Name"
$TGT_DataSetName = "TGT_$Name"
#Datflow Vars
$DFL_Name = "DFL_$Name"
#Pipeline Vars
$PLI_Name = "PLI_$Name"


# JSON Template Files
$ADF = Get-AzDataFactoryV2 -ResourceGroupName $ADF_ResGroup
$SRC_pathToJson = "$PSScriptRoot\Templates\Datasets\SRC_JSON.json"
$TGT_pathToJson = "$PSScriptRoot\Templates\Datasets\TGT_JSON.json"
$PLI_pathToJson = "$PSScriptRoot\Templates\Pipeline\JSON_Flatten_Post_To_CluedIn.json"
$DFL_pathToJson = "$PSScriptRoot\Templates\Dataflow\DFL_JSON_Flatten.json"
### Temp File For JSON Processing to ADF
$pathToTmpJson = "$PSScriptRoot\Templates\tmp.json"


new-CluedInFlattenPieline 


