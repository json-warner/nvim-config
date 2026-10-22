# nvim-config
Neovim configurations for lazy loading funcitonality

## Setup (Windows)

Config is versioned in `nvim\`; plugin/runtime data goes to `nvim-data\` (git-ignored).
Set these in your PowerShell profile, adjusting the path to where you cloned the repo:

```powershell
$env:XDG_CONFIG_HOME = "C:\gitws\OTHER\nvim-config"   # config -> <repo>\nvim
$env:XDG_DATA_HOME   = "C:\gitws\OTHER\nvim-config"   # data   -> <repo>\nvim-data
$env:NVIM_JDK_ROOTS  = "C:\aft\jdks\Amazon"           # optional; ";"-separated dirs of installed JDKs
```

- `NVIM_JDK_ROOTS`: directories whose subfolders are JDKs (each has a `release` file).
  `lsp\java.lua` registers them as runtimes and points nvim-java at the matching JDK
  (`JAVA_HOME` if 21+, else the newest 21+), so no OpenJDK is downloaded.
- Java uses [nvim-java](https://github.com/nvim-java/nvim-java), which downloads
  jdtls, Lombok, java-test, java-debug and Spring Boot tools into `nvim-data\` on first
  start. Plugins load only when a Java buffer is opened.
