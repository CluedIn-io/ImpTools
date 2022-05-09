# Transfer Metadata and Settings between CluedIn Organizations

Certain configuration objects can be extracted (serialized) from CluedIn (from the Sql Server at this time) and stored as a folder of json files. These json files can later be pushed (unserialized) to the same or another CluedIn instance. This is useful for CI/CD type scanarios.

## Configuration

Use `config.json` to provide the ID of the organization to be exported (`from_organization_id`), and the ID of the organization to be imported {`to_organization_id`}.
`to_user_id` is the ID of an existing user in the target organization.
`open_communication_connection_string` is the connection string to `OpenCommunication` database. You may need to port-forward it first.

```json
{
  "from_organization_id": "79898C75-BC05-4E74-888E-7E2FEF37AE5E",
  "to_organization_id": "79898C75-BC05-4E74-888E-7E2FEF37AE5E",
  "to_user_id": "edfff584-59b3-42ba-b00b-2b88d72153e2",
  "open_communication_connection_string": "Data source=localhost;Initial catalog=DataStore.Db.OpenCommunication;User Id=sa;Password=yourStrong(!)Password;connection timeout=10;"
}
```

### Other Configuration

To assist with unit tests and advanced scenarios, other environment varibles and configuration can be altered.

| Name | Comments |
| --- | --- |
| Environment `TRANSER_SKIP_MAIN` | Set to true if we are running unit tests in order to skip the main function from being executed. |
| Environment `DEFAULT_CONNECTION_STRING` | If defined then used by the unit tests to know which database to connect to, otherwise this will be set by the unit tests if run the first time. |
| `config.json` "outdir" | override the output directory for the json files (default is `./data`) |

## Serialization

The following command will dump all the necessary data to `./data` directory:

```powershell
.\serialize.ps1
```

## Deserialization

The following command will restore the `./data` files to the `to_organization_id` organization:

```powershell
.\deserialize.ps1
```

All fields with the `from_organization_id` will be replaced with `to_organization_id` value.
All fields with user IDs will be replaced with `to_user_id` value.

## Testing

Unit tests require a local sql server running (perhaps in docker), that has been preped by the CluedIn installation process.

To run the unit tests, open a powershell window and ensure you are in this folder (i.e. the `transfer` folder) then run the command:

```powershell
PS C:\src\CluedIn-io\ImpTools> cd .\transfer\
PS C:\src\CluedIn-io\ImpTools\transfer> Invoke-Pester 
```