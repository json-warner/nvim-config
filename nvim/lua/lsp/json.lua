-- npm installs an extensionless shim and a .cmd; Windows can only spawn the .cmd.
local server = vim.fn.has("win32") == 1 and "vscode-json-language-server.cmd" or "vscode-json-language-server"

if vim.fn.executable(server) == 1 then
  vim.lsp.config("jsonls", { cmd = { server, "--stdio" } })
  vim.lsp.enable("jsonls")
end
