local typedefs = require "kong.db.schema.typedefs"

local schema = {
  name = "httpdump",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          { filter = { type = "string", required = true }, }
        },
        entity_checks = {

        },
      },
    },
  },
}

return schema
