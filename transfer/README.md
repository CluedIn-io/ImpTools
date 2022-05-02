# Transfer Metadata and Settings between CluedIn Organizations

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

## Serialization

The following command will dump all the necessary data to `/data` directory:

```powershell
.\serialize.ps1
```

## Deserialization

The following command will restore the `/data` files to the `to_organization_id` organization:

```powershell
.\deserialize.ps1
```

All fields with the `from_organization_id` will be replaced with `to_organization_id` value.
All fields with user IDs will be replaced with `to_user_id` value.
