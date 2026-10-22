-- LemMinX (XML) runs from its jar using the JDK already on PATH. The jar is
-- downloaded into stdpath("data") the first time an XML buffer is opened.
local VERSION = "0.31.2"
local JAR_URL = "https://repo.eclipse.org/repository/lemminx-maven2-releases/org/eclipse/lemminx/org.eclipse.lemminx/"
  .. VERSION .. "/org.eclipse.lemminx-" .. VERSION .. "-uber.jar"
local jar = vim.fs.joinpath(vim.fn.stdpath("data"), "lemminx", "lemminx-" .. VERSION .. ".jar")

local function ensureJar()
  if vim.uv.fs_stat(jar) then
    return true
  end
  vim.fn.mkdir(vim.fs.dirname(jar), "p")
  vim.notify("Downloading LemMinX " .. VERSION .. "...")
  local result = vim.system({ "curl", "-fsSL", "-o", jar, JAR_URL }):wait()
  if result.code ~= 0 then
    vim.fn.delete(jar)
    vim.notify("LemMinX download failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
    return false
  end
  return true
end

local isConfigured = false

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserLspXml", { clear = true }),
  pattern = "xml",
  callback = function()
    if isConfigured then
      return
    end
    isConfigured = true

    if vim.fn.executable("java") ~= 1 then
      vim.notify("java not found on PATH; XML LSP disabled", vim.log.levels.WARN)
      return
    end
    if not ensureJar() then
      return
    end
    vim.lsp.config("lemminx", { cmd = { "java", "-jar", jar } })
    vim.lsp.enable("lemminx")
  end,
})
