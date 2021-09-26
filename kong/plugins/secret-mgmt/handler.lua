local kong = kong
local ngx = require "ngx"
local BasePlugin = require "kong.plugins.base_plugin"
local ngx_set_header = ngx.req.set_header
local runloop = require "kong.runloop.handler"
local keyring = require("kong.keyring")
local null    = ngx.null
local env = require("lapis.environment")


local secretMgmt = BasePlugin:extend()

secretMgmt.PRIORITY = 920

local function keyring_enabled()
  local ok, enabled = pcall(function()
    return kong.configuration.keyring_enabled
  end)

  return ok and enabled or nil
end


local is_keyring_enabled = keyring_enabled()

function secretMgmt:new()
  secretMgmt.super.new(self, "secret-mgmt")
end

-- This method is to set the secret value as a header dynamically when the request reaches this plugin
local function set_header(conf, value)
  kong.log.info("################# set_header start ")
  if conf.export_as_header_prefix ~= nil then
    ngx_set_header(conf.export_as_header_name, conf.export_as_header_prefix .. " " .. value)
  else
    ngx_set_header(conf.export_as_header_name, value)
  end
end

-- This method is to set the secret value as an kong.ctx.shared variable dynamically when the request reaches this plugin
local function set_shared_ctx_variable(conf, value)
  kong.log.info("################# set_shared_ctx_variable start ")
  kong.ctx.shared[conf.export_as_kong_ctx_shared_variable_name] = value 
end

-- This will execute when the client request hits the plugin
-- This method is to decrypt the secret value and export as header or as kong.ctx.shared variable to achieve decryption in transit
function secretMgmt:access(conf)
    kong.log.info("######################### SecretMgmt Access Phase start ##################### ")
    kong.log.info("conf.export_as_kong_ctx_shared_variable: ",conf.export_as_kong_ctx_shared_variable)
    local secret_value_decrypted;
    if(is_keyring_enabled) then 
      if(keyring.active_key_id() ~= nil) then    
         secret_value_decrypted = keyring.decrypt(conf.secret_value)
         if(conf.export_as_header == true) then 
           set_header(conf, secret_value_decrypted)
         end
         if(conf.export_as_kong_ctx_shared == true) then 
           set_shared_ctx_variable(conf, secret_value_decrypted)
         end
      else
         kong.log.err("Active Key Id not found for Keyring ")
         return kong.response.exit(500, { message = "Active Key Id not found for Keyring" } )
      end
    else
      kong.log.err("Keyring should be enabled ")
      return kong.response.exit(500, { message = "Keyring should be enabled" } )
    end 
    kong.log.info("#########################  SecretMgmt Access Phase end ##################### ")
end
return secretMgmt


