-- schema.lua
local keyring = require("kong.keyring")

local function keyring_enabled()
  local ok, enabled = pcall(function()
    return kong.configuration.keyring_enabled
  end)

  return ok and enabled or nil
end

local null          = ngx.null
local is_keyring_enabled = keyring_enabled()


local function validate_fields_encrypt_secret_value(conf) 
 if(conf.export_as_header == false and conf.export_as_kong_ctx_shared == false) then
   return false,"Atleast one of the field export_as_header or export_as_kong_ctx_shared should be true"
 end
 if(conf.export_as_header == true and (conf.export_as_header_name == null or conf.export_as_header_name == '')) then
   return false,"export_as_header_name cannot be nil if export_as_header is true"
 end
 if(conf.export_as_kong_ctx_shared == true and (conf.export_as_kong_ctx_shared_variable_name == null or conf.export_as_kong_ctx_shared_variable_name == '')) then
   return false,"export_as_kong_ctx_shared_variable_name cannot be nil if export_as_kong_ctx_shared is true"
 end
 if(is_keyring_enabled) then 
   if(is_secret_value_encrypted ~= true) then
      if(keyring.active_key_id() ~= nil) then    
        conf.secret_value=keyring.encrypt(conf.secret_value)
        conf.is_secret_value_encrypted = true
      else
        return false,"Active Key Id not found for Keyring "
      end
   end 
 else
   return false,"Keyring should be enabled"
 end
 return true
end

return {
  name = "secret-mgmt",
  fields = {
    {
      config = {
        type = "record",
        custom_validator = validate_fields_encrypt_secret_value,
        fields = {
          { secret_name = { type = "string", required = true }},
          { secret_value = { type = "string", required = true }},
          { is_secret_value_encrypted = { type = "boolean", required = true, default = false }},
          { export_as_header = { type = "boolean", default = false }},
          { export_as_header_name = { type = "string"}},
          { export_as_header_prefix = { type = "string"}},
          { export_as_kong_ctx_shared = {  type = "boolean", default = false }},
          { export_as_kong_ctx_shared_variable_name = { type = "string" }},
        }
      },
    },
  },
}



