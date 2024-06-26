local kit = require('gtd.kit')
local LSP = require('gtd.kit.LSP')
local Async = require('gtd.kit.Async')
local Client = require('gtd.kit.LSP.Client')
local Position = require('gtd.kit.LSP.Position')

---@class gtd.source.LSPDefinitionSource : gtd.Source
---@field public is_deprecated boolean
local Source = {}
Source.__index = Source

---@param is_deprecated? boolean
function Source.new(is_deprecated)
  local self = setmetatable({}, Source)
  self.is_deprecated = not not is_deprecated
  return self
end

function Source:get_position_encoding_kind()
  return LSP.PositionEncodingKind.UTF8
end

---@param definition_params gtd.kit.LSP.DefinitionParams
---@param context gtd.Context
function Source:execute(definition_params, context)
  if self.is_deprecated then
    vim.api.nvim_echo({ { '[gtd] `lsp` source is renamed. Please use `lsp_definition` instead.', 'WarningMsg' } }, true, {})
  end
  return Async.run(function()
    local locations = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      ---@type gtd.kit.LSP.ServerCapabilities
      local server_capabilities = client.server_capabilities
      if server_capabilities.definitionProvider then
        ---@type gtd.kit.LSP.TextDocumentDefinitionResponse
        local response = Client.new(client):textDocument_definition({
          textDocument = definition_params.textDocument,
          position = Position.to(
            context.text,
            definition_params.position,
            self:get_position_encoding_kind(),
            server_capabilities.positionEncoding or client.offset_encoding or LSP.PositionEncodingKind.UTF32
          ),
        }):await()
        if response then
          if response.range then
            locations = kit.concat(locations, { response })
          else
            locations = kit.concat(locations, response)
          end
        end
      end
    end
    return locations
  end)
end

return Source
