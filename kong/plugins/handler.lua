-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------
local kong     = kong
local ngx      = ngx
local cjson = require "cjson"
local client = require "resty.kafka.client"
local producer = require "resty.kafka.producer"

-- 引入插件基类
local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"

-- 派生出一个子类，其实这里是为了继承来自 Classic 的 __call 元方法，
-- 方便 Kong 在 init 阶段预加载插件的时候执行构造函数 new()
local HttpDumpHandler = BasePlugin:extend()
HttpDumpHandler.PRIORITY = 1000  -- set the plugin priority, which determines plugin execution order
HttpDumpHandler.VERSION = "1.0"  -- set the plugin priority, which determines plugin execution order


-- 插件的构造函数，用于初始化插件的 _name 属性，后面会根据这个属性打印插件名
-- 其实这个方法不是必须的，只是用于插件调试
function HttpDumpHandler:new()
  HttpDumpHandler.super.new(self, "httpdump")
end


-- runs in the 'access_by_lua_block'
function HttpDumpHandler:access(conf)
  -- your custom code here
  kong.log.inspect(plugin_conf)   -- check the logs for a pretty-printed config!
  ngx.req.set_header(plugin_conf.request_header, "this is on a request")

end --]]


--[[ runs in the 'header_filter_by_lua_block'
function plugin:header_filter(plugin_conf)

  -- your custom code here, for example;
  ngx.header[plugin_conf.response_header] = "this is on the response"

end --]]


--[[ runs in the 'body_filter_by_lua_block'
function plugin:body_filter(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'body_filter' handler")

end --]]

function HttpDumpHandler:log(conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'log' handler")
  local body = kong.request.get_raw_query()
  local method = kong.request.get_method()
  local pathWithQuery = kong.request.get_path_with_query()
  kong.log.info(method,pathWithQuery,body)

  local message = kong.log.serialize()

  kong.log.info(conf.status_code,conf.content_type,conf.body,conf.message,conf.filter)
  kong.log.info(conf,cjson.encode(message));
end


-- return our plugin object
return plugin
