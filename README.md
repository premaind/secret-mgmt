# Secret Management Plugin
## Overview
Secret Management plugin is used to store any upstream tokens in a secured manner in Kong and export as header and send to upstream. 
This plugin is useful when upstream tokens should not be shared with client and to be maintained in Kong for upstream authentication. 
This plugin uses Kong's Keyring feature to store secrets in encrypted format.
Kong's Keyring feature uses encryption at REST (only in DB). But, this plugin is enhanced to use Kong's Keyring feature
-  To encrypt in Kong admin API layer
-  To encrypt in Kong GUI layer
-  To encrypt in Kong DB layer 
-  To decrypt only in transit (Kong Proxy layer) 

By this way, this plugin ensures encryption is done in all layers of Kong with atmost security.

## Additional Features
- To avoid re-encryption of secret value on deck sync operation, we should set config.is_secret_value_encrypted flag to true
- To use this secret value in any other custom plugins, we have a feature to export as a Kong shared ctx variable and use in other plugins

## Tested in Kong Release
Kong Enterprise 2.2.1.0

## Installation
Recommended:
```
git clone https://github.com/premaind/secret-mgmt  
cd secret-mgmt
$ luarocks install kong-plugin-secret-mgmt-0.1.0-1.all.rock
```

Other:
```
$ git clone https://github.com/premaind/secret-mgmt  
cd secret-mgmt
$ luarocks make kong-plugin-secret-mgmt-0.1.0-1.rockspec
```

## Pre-requisite to use this plugin
### Keyring Enablement in Kong
The plugin requires Kong's Keyring feature to be enabled.

**Step:1 - Generate keyring certificates using below commands**
```
 openssl genrsa -out key.pem 2048
 openssl rsa -in key.pem -pubout -out cert.pem
```

**Step:2 - Add below configurations in kong.conf**
```
keyring_enabled = on 
keyring_strategy = cluster 
keyring_public_key = /path/to/cert.pem 
keyring_private_key = /path/to/key.pem 
```

**Step:3 - Restart Kong**
```
 kong restart 
```
**Step:4 Generate Key**
```
 curl -X POST -s localhost:8001/keyring/generate

**Response**
{"key":"7a58eLDqjcN3p0\/WMiizCabRhXf0NxgFcPiSFcwvccU=","id":"6jtjRnLX"}
```

**Step:5 - Activate Key** 
Note: The id in above response("6jtjRnLX") is used here to activate the key 
```
curl -s localhost:8001/keyring/activate -d key=6jtjRnLX 
```

**Step:6 - Export Key (Save it for future use when Kong is restarted)**
```
curl -X POST -s localhost:8001/keyring/export

**Sample Response**
{"data":"eyJrIjoiVnZJQ3NkNHhQNkt5ZFI3QjBnTkVaS205NUlDMnpEVGU1YVBqK01sOWV4RldsdjVZRDVFRlpXRXJDU3UzS280NFhWVVBvdnhreHVoY1FCYkZkZkVRR3JvVWhQUTJTYjNvMk9jU2c5eG5wdGx1MVN6WCsrbE5WQXFRUkdrQ3JDbXc3Mnh1ajh5UWlOVGxXS0FBMVZJUU1IVXFXZDdMSDNQQkcwNDJpdHNPUE5WNjZCRFdRQU0wdlU3NkVqZkREakw1cXlUbUlxR2EySmJ4bEtrZ3B0Q2JZNTZhWkVxY2R5cnpsUjZhb0llMWZaTjR6emRjZk51VlEwWUhlQ0ZlMHJnVVpMV0ZyUExcL0NxU0hXeWZ4UG9UTEZBdCtJVmNQeVZcL3pzOWlJb0s4V1FvSjFUK3V2cDF1WHo4b2lpNjF5NkkrYUhmU052bnlURDdqNVUyU0VEUnJGTGc9PSIsImQiOiIzMVJVdEFqWUpPdzFzeGUyTm91XC83d2lyU3JqR1E0eHp4WkVqXC95M1FWQ3hjaGFKdHh1N3g4dlhVeVVkRFcxcnJnNWxxNTN6dTFcL3FPXC9BZjBUeDRSZzM0RlpMeVByWjFuNHlwQlZlNHBlQldkQ3BjWGVOYnAzMDg9IiwibiI6IkNmTll6OEx0RVZQcHRyWEEifQ=="}
```

**Step:7 - Import Key (Import the exported key in Step:6, everytime when kong is restarted)**

```
curl -i -X POST http://localhost:8001/keyring/import -d 
data="eyJrIjoiVnZJQ3NkNHhQNkt5ZFI3QjBnTkVaS205NUlDMnpEVGU1YVBqK01sOWV4RldsdjVZRDVFRlpXRXJDU3UzS280NFhWVVBvdnhreHVoY1FCYkZkZkVRR3JvVWhQUTJTYjNvMk9jU2c5eG5wdGx1MVN6WCsrbE5WQXFRUkdrQ3JDbXc3Mnh1ajh5UWlOVGxXS0FBMVZJUU1IVXFXZDdMSDNQQkcwNDJpdHNPUE5WNjZCRFdRQU0wdlU3NkVqZkREakw1cXlUbUlxR2EySmJ4bEtrZ3B0Q2JZNTZhWkVxY2R5cnpsUjZhb0llMWZaTjR6emRjZk51VlEwWUhlQ0ZlMHJnVVpMV0ZyUExcL0NxU0hXeWZ4UG9UTEZBdCtJVmNQeVZcL3pzOWlJb0s4V1FvSjFUK3V2cDF1WHo4b2lpNjF5NkkrYUhmU052bnlURDdqNVUyU0VEUnJGTGc9PSIsImQiOiIzMVJVdEFqWUpPdzFzeGUyTm91XC83d2lyU3JqR1E0eHp4WkVqXC95M1FWQ3hjaGFKdHh1N3g4dlhVeVVkRFcxcnJnNWxxNTN6dTFcL3FPXC9BZjBUeDRSZzM0RlpMeVByWjFuNHlwQlZlNHBlQldkQ3BjWGVOYnAzMDg9IiwibiI6IkNmTll6OEx0RVZQcHRyWEEifQ=="
```

## Plugin Configuration
### Admin API
```
curl -X POST http://{HOST}:8001/services/{SERVICE}/plugins \ <br />
 --data "name=secret-mgmt" \ <br />
 --data "config.secret_name=<secret_name>" \ <br />
 --data "config.secret_value=<secret_token_value>" \ <br />
 --data "config.export_as_header=true" \ <br />
 --data "config.export_as_header_name=<http_header_name>" \
```

### Declarative (YAML)
```
plugins:
- name: secret-mgmt
  config:
    export_as_header: true
    export_as_header_name: {http_header_name}
    export_as_header_prefix: {http_header_prefix}
    export_as_kong_ctx_shared: false
    export_as_kong_ctx_shared_variable_name: null
    is_secret_value_encrypted: false
    secret_name: {secret_name}
    secret_value: {secret_value}
  enabled: true
  protocols:
  - grpc
  - grpcs
  - http
  - https
```

### Parameters
Here's a list of all the parameters which can be used in this plugin's configuration:

| FORM PARAMETER                                           | DESCRIPTION                                             |
| ---                                                      | -----------                                             |
| name <br /> Type: string                                 | The name of the plugin to use, in this case secret-mgmt |
| service.id <br /> Type: string                           | The ID of the Service the plugin targets                |
| route.id <br /> Type: string                             | The ID of the Route the plugin targets                  |
| enabled <br /> Type: boolean <br /> Default value: true  | Whether this plugin will be applied                     |
| config.secret_name  <br /> required <br /> Type: string  | The name to identify  the secret name                   |
| config.secret_value <br /> required <br /> Type: string  | The secret value/token to be stored securely in Kong and passed to upstream                     |
| config.is_secret_value_encrypted <br /> required <br /> Type: String <br /> Default value: false  | This is to make the plugin decide whether to encrypt the secret value entered here. This is helpful when doing decK sync and when this flag is true, the encrypted data will not be re-encrypted again                     |
| config.export_as_header <br /> semi-optional <br /> Type: boolean             | Whether to decrypt the token and export as header on transit |
| config.export_as_header_name <br /> semi-optional <br /> Type: string         | The header name in which the secret value to be decrypted and sent to upstream      |
| config.export_as_header_prefix <br /> semi-optional <br /> Type: string       | The header prefix name (Eg) Bearer/Basic)                    |
| config.export_as_kong_ctx_shared <br /> semi-optional <br /> Type: boolean    | Whether to decrypt the token and assign in kong.ctx.shared variable  |
| config.export_as_kong_ctx_shared_variable_name <br /> semi-optional <br /> Type: string    | The kong.ctx.shared variable name in which secret value to be decrypted and sent which can be used by any other plugin     |

## Schema Validation Errors
| ERROR                                                    | Fix Required                                                  |
| ---                                                      | -----------                                                   |
| schema violation (config.secret_name: required field missing) | To provide non empty value for config.secret_name        |
| schema violation (config.secret_value: required field missing) | To provide non empty value for config.secret_value      |
|schema violation (config: Atleast one of the field export_as_header or export_as_kong_ctx_shared should be true)| Either one of the field export_as_header or export_as_kong_ctx_shared to be true. | 
|schema violation (config: export_as_header_name cannot be nil if export_as_header is true) | If export_as_header is true then export_as_header_name value to be non empty | 
|schema violation (config: export_as_kong_ctx_shared_variable_name cannot be nil if export_as_kong_ctx_shared is true)|  If export_as_kong_ctx_shared_variable_name is true then export_as_kong_ctx_shared value to be non empty | 
| schema violation (config: Active Key Id not found for Keyring ) | Activate the key/ or Import the Key for Keyring | 
|schema violation (config:Keyring should be enabled)       |Enable Keyring in kong.conf                             |


## Request Processing Errors
| HTTP ERROR Code     | HTTP Error Message                                            | Fix Required                                                  |
| ---                 | -----------                                                   |-----------                                                    |
| 500                 | Active Key Id not found for Keyring                           | Activate the key/ or Import the Key for Keyring               |
| 500                 | Keyring should be enabled                                     | Enable Keyring in kong.conf                                   |

## Contributors
Design and Implementation By – Prema.Namasivayam@VERIFONE.com  <br />
Guided By:  Vineet.Dutt@VERIFONE.com <br />
Supported By: Satyajit.Sial@VERIFONE.com <br />