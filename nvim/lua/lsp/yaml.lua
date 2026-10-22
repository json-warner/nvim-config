-- npm installs an extensionless shim and a .cmd; Windows can only spawn the .cmd.
local server = vim.fn.has("win32") == 1 and "yaml-language-server.cmd" or "yaml-language-server"

if vim.fn.executable(server) == 1 then
  vim.lsp.config("yamlls", { cmd = { server, "--stdio" } })
  vim.lsp.enable("yamlls")
end
