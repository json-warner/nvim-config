-- Java via nvim-java. Nothing is loaded until the first Java buffer is opened.
-- JDKs are never downloaded: they are discovered from the directories listed
-- in NVIM_JDK_ROOTS (";"-separated, set machine-locally in local.ps1). Each
-- subdirectory containing a `release` file is treated as a JDK.

local MINIMUM_JDTLS_HOST_VERSION = 21

-- Exported Eclipse formatter profiles live at the repo root, next to nvim/.
local FORMATTER_PROFILE_FILE =
  vim.fs.normalize(vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h") .. "/eclipse_formatter.xml")

local function readMajorVersion(jdkHome)
  local releaseFile = io.open(jdkHome .. "/release", "r")
  if not releaseFile then
    return nil
  end
  local contents = releaseFile:read("*a")
  releaseFile:close()
  local version = contents:match('JAVA_VERSION="([^"]+)"')
  if not version then
    return nil
  end
  -- Java 8 reports "1.8.0_x"; later versions report "21.0.x".
  local major = version:match("^1%.(%d+)") or version:match("^(%d+)")
  return tonumber(major)
end

local function discoverJdks()
  local jdks = {}
  local roots = vim.env.NVIM_JDK_ROOTS or ""
  for root in roots:gmatch("[^;]+") do
    for _, jdkHome in ipairs(vim.fn.glob(root .. "/*", false, true)) do
      local major = readMajorVersion(jdkHome)
      if major then
        table.insert(jdks, { major = major, path = vim.fs.normalize(jdkHome) })
      end
    end
  end
  table.sort(jdks, function(left, right)
    return left.major < right.major
  end)
  return jdks
end

local function toRuntimes(jdks, defaultMajor)
  local runtimes = {}
  for _, jdk in ipairs(jdks) do
    table.insert(runtimes, {
      name = jdk.major == 8 and "JavaSE-1.8" or ("JavaSE-" .. jdk.major),
      path = jdk.path,
      default = jdk.major == defaultMajor or nil,
    })
  end
  return runtimes
end

-- jdtls itself needs a modern JDK to run; prefer JAVA_HOME, else newest suitable.
local function pickHostJdk(jdks)
  local javaHome = vim.env.JAVA_HOME and vim.fs.normalize(vim.env.JAVA_HOME)
  for _, jdk in ipairs(jdks) do
    if jdk.path == javaHome and jdk.major >= MINIMUM_JDTLS_HOST_VERSION then
      return jdk
    end
  end
  for index = #jdks, 1, -1 do
    if jdks[index].major >= MINIMUM_JDTLS_HOST_VERSION then
      return jdks[index]
    end
  end
end

-- nvim-java bundles jdtls, Lombok, java-test, java-debug and Spring Boot tools.
-- Plugins are installed at startup but only loaded when a Java buffer opens.
local javaPlugins = {
  { name = "spring-boot.nvim", src = "https://github.com/JavaHello/spring-boot.nvim",
    version = "218c0c26c14d99feca778e4d13f5ec3e8b1b60f0" },
  { name = "nui.nvim", src = "https://github.com/MunifTanjim/nui.nvim" },
  { name = "nvim-dap", src = "https://github.com/mfussenegger/nvim-dap" },
  { name = "nvim-java", src = "https://github.com/nvim-java/nvim-java" },
}

vim.pack.add(javaPlugins, { load = function() end })

local isConfigured = false

local function configureJava()
  if isConfigured then
    return
  end
  isConfigured = true

  for _, plugin in ipairs(javaPlugins) do
    vim.cmd.packadd(plugin.name)
  end

  local jdks = discoverJdks()
  local hostJdk = pickHostJdk(jdks)
  if not hostJdk then
    vim.notify(
      "No JDK >= " .. MINIMUM_JDTLS_HOST_VERSION .. " found in NVIM_JDK_ROOTS; Java LSP disabled",
      vim.log.levels.WARN
    )
    return
  end

  -- Use the existing JDK for jdtls instead of letting nvim-java download one.
  require("java").setup({
    jdk = { auto_install = false, path = hostJdk.path },
  })

  vim.lsp.config("jdtls", {
    settings = {
      java = {
        configuration = {
          runtimes = toRuntimes(jdks, hostJdk.major),
        },
        format = {
          settings = {
            url = FORMATTER_PROFILE_FILE,
            profile = "GoogleStyle",
          },
        },
      },
    },
  })
  vim.lsp.enable("jdtls")
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserLspJava", { clear = true }),
  pattern = "java",
  callback = configureJava,
})

-- Decompiled/jar sources open as jdt:// buffers whose names are far too long
-- and full of illegal characters to be used as a Windows swap file name (E303).
vim.api.nvim_create_autocmd({ "BufNew", "BufReadCmd" }, {
  group = vim.api.nvim_create_augroup("UserJdtNoSwap", { clear = true }),
  pattern = "jdt://*",
  callback = function(event)
    vim.bo[event.buf].swapfile = false
  end,
})

-- Exposed for inspection/testing.
return { discoverJdks = discoverJdks, toRuntimes = toRuntimes, pickHostJdk = pickHostJdk }
