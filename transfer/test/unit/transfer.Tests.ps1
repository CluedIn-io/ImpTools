# run me from the \transfer folder
Write-Host $pwd

# ensure when we source the script we do not run the main
$env:TRANSER_SKIP_MAIN = "true"

# source the script under test
. '.\serialize.ps1'

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
        $thown = $false;
        try
        {
            serialize($config | ConvertFrom-Json)
        }
        catch
        {
            $thown = $true;
        }
        $thown | Should be $true;
    }
}

Describe "Default Config" {
    It "run default config" {
        $config = @"
        {
            "from_organization_id": "79898C75-BC05-4E74-888E-7E2FEF37AE5E",
            "to_organization_id": "79898C75-BC05-4E74-888E-7E2FEF37AE5E",
            "to_user_id": "edfff584-59b3-42ba-b00b-2b88d72153e2",
            "open_communication_connection_string": "Data source=localhost;Initial catalog=DataStore.Db.OpenCommunication;User Id=sa;Password=yourStrong(!)Password;connection timeout=10;"
        }
"@
        Write-Host $config
        serialize($config | ConvertFrom-Json)
    }
}

# restore this environment to empty
$env:TRANSER_SKIP_MAIN = ""


