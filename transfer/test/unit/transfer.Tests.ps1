# run me from the \transfer folder
Write-Host $pwd
if (!($pwd -clike '*transfer'))
{
    Write-Host error: run from transfer folder only!!!
    exit -1
}

# ensure when we source the script we do not run the main
$env:TRANSER_SKIP_MAIN = "true"

# source the script under test
. '.\serialize.ps1'

# clean up data folders
# if data_* folder contains at least one .json file then we rmdir the folder
Write-Host cleaning up data_* folders from previous runs
Get-ChildItem -Path .\ –Directory | foreach {
    if ($_.Name -clike 'data_*')
    {
        $dir = $_.Name;
        $haveJson = $false
        Get-ChildItem -Path .\$dir\ -File | foreach {
            #Write-Host file $_.Name
            if ($_.Name -clike '*.json')
            {
                $haveJson = $true
            }
        }
        if ($haveJson)
        {
            Write-Host deleting $dir
            Remove-Item $dir -Recurse -Force
        }
        else
        {
            Write-Host skipping $dir
        }
    }
}

# set the default if not already set
if (!(Test-Path env:DEFAULT_CONNECTION_STRING))
{
    $env:DEFAULT_CONNECTION_STRING = "Data source=localhost;Initial catalog=DataStore.Db.OpenCommunication;User Id=sa;Password=yourStrong(!)Password;connection timeout=10;"
}

#Describe "HelloWorld" {
#    It "does something useful" {
#        $true | Should Be $false
#    }
#}

Describe "Invalidate Config" {
    It "pass invalidate config" {
        $config = @"
        {
            "from_organization_id_missing": "79898C75-BC05-4E74-888E-7E2FEF37AE5E",
            "to_organization_id_missing": "79898C75-BC05-4E74-888E-7E2FEF37AE5E",
            "to_user_id_missing": "edfff584-59b3-42ba-b00b-2b88d72153e2",
            "open_communication_connection_string": "invalid"
        }
"@
        Write-Host $config
        $thown = $false
        try
        {
            serialize($config | ConvertFrom-Json)
        }
        catch
        {
            $thown = $true
        }
        $thown | Should be $true
    }
}

function GetOrgs()
{
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $env:DEFAULT_CONNECTION_STRING
    $connection.Open()
    $command = $connection.CreateCommand()

    $command.CommandText = @"
    SELECT
        [Id]
        ,[OrganizationName]
    FROM [DataStore.Db.OpenCommunication].[dbo].[OrganizationProfile]
"@

    $result = $command.ExecuteReader()
    $table = New-Object System.Data.DataTable
    $table.Load($result)
    $out = $table | Select-Object $table.Columns.ColumnName | ConvertTo-Json -AsArray

    $connection.Close()

    return $out
}

# use 'cluedin' if found, or the first one, otherwise if there is only one result return it
function OrgIdToUse()
{
    $ret = ""
    $orgs = GetOrgs
    #Write-Host orgs are $orgs
    $orgsArray = $orgs | ConvertFrom-Json
    if ($orgsArray.Length -eq 0)
    {
        $ret = $orgsArray[0].Id
    }
    elseif ($orgsArray.Length -gt 0)
    {
        $ret = $orgsArray[0].Id
        $orgsArray | foreach {
            if ($_.OrganizationName -eq 'cluedin')
            {
                $ret = $_.Id
            }
        }
    }
    else
    {
        Write-Host error: no orgs found in the database!!!
        $orgsArray.Length | Should Be -gt 0
        exit -1
    }
    return $ret
}

Describe "Default Config" {
    It "run default config" {
        $id = OrgIdToUse
        $config = @"
        {
            "from_organization_id": "$id",
            "to_organization_id": "$id",
            "to_user_id": "edfff584-59b3-42ba-b00b-2b88d72153e2",
            "open_communication_connection_string": "$env:DEFAULT_CONNECTION_STRING",
            "outdir": "./data_test_default_config"
        }
"@
        # $orgs = GetOrgs
        # Write-Host $orgs
        # $orgsArray = $orgs | ConvertFrom-Json
        # Write-Host "number of orgs is " $orgsArray.Length
        # Write-Host $orgsArray[0].Id
        
        # $id = "";
        # foreach ($org in $orgsArray)
        # {
        #     if ($org.OrganizationName -eq "cluedin")
        #     {
        #         $id = $org.Id
        #     }
        # }

        # Write-Host "id of cluedin org is" $id

        Write-Host $config
        serialize($config | ConvertFrom-Json)
    }
}

Describe "Different outdir" {
    It "read the config into another outdir" {
        $id = OrgIdToUse
        $config = @"
        {
            "from_organization_id": "$id",
            "to_organization_id": "$id",
            "to_user_id": "edfff584-59b3-42ba-b00b-2b88d72153e2",
            "open_communication_connection_string": "$env:DEFAULT_CONNECTION_STRING",
            "outdir": "./data_test_different_outdir"
        }
"@
        Write-Host $config
        serialize($config | ConvertFrom-Json)
    }
}

Describe "process entities only" {
    It "dump out entities only" {
        $id = OrgIdToUse
        $config = @"
        {
            "from_organization_id": "$id",
            "to_organization_id": "$id",
            "to_user_id": "edfff584-59b3-42ba-b00b-2b88d72153e2",
            "open_communication_connection_string": "$env:DEFAULT_CONNECTION_STRING",
            "outdir": "./data_test_entities_only",
            "process_filter": true,
            "process_entities": true
        }
"@
        Write-Host $config
        serialize($config | ConvertFrom-Json)

        $haveJson = $false
        $numOfFiles = 0
        Get-ChildItem -Path ".\data_test_entities_only\" -File | foreach {
            if ($_.Name -eq 'entity-type.json')
            {
                $haveJson = $true
            }
            $numOfFiles++
        }

        $haveJson | Should Be $true
        $numOfFiles | Should Be 1
    }
}

Describe "lookup to_org and to_user by name" {
    It "read the config into another outdir" {
        $id = OrgIdToUse
        $config = @"
        {
            "from_organization_id": "$id",
            "to_organization": "transfer",
            "to_user": "admin@transfer.com",
            "open_communication_connection_string": "$env:DEFAULT_CONNECTION_STRING",
            "outdir": "./data_test_default_config",
            "process_filter": true,
            "process_rules": true
        }
"@
        Write-Host $config
        # TODO: implement me
        #unserialize($config | ConvertFrom-Json)
    }
}

# restore this environment to empty
$env:TRANSER_SKIP_MAIN = ""


