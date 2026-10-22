vim.lsp.config("*", {
  root_markers = { ".git" },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/foldingRange") then
      local window = vim.api.nvim_get_current_win()
      vim.wo[window][0].foldmethod = "expr"
      vim.wo[window][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
    end

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gy", vim.lsp.buf.type_definition, "Go to type definition")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("gr", vim.lsp.buf.references, "References")

    -- Eclipse-style bindings
    map("<F3>", vim.lsp.buf.definition, "Open declaration")
    map("<C-t>", vim.lsp.buf.implementation, "Open implementation")
    map("<F4>", function()
      vim.lsp.buf.typehierarchy("subtypes")
    end, "Type hierarchy (subtypes)")
    map("<M-Left>", "<C-o>", "Back")
    map("<M-Right>", "<C-i>", "Forward")
    map("K", vim.lsp.buf.hover, "Hover")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<C-f>", function()
      vim.lsp.buf.format({ async = true })
    end, "Format buffer")
  end,
})

-- Each language module owns its own config and enables itself.
-- vim.lsp.enable only starts a server when a matching filetype is opened.
require("lsp.json")
require("lsp.xml")
require("lsp.yaml")
require("lsp.java")
