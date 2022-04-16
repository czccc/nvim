local M = {}
local path = require("utils.path")
local Log = require("core.log")
local compile_path = path.pack_compile_path

function M.init_packer()
  local install_path = path.pack_install_dir
  local package_root = path.pack_dir
  local in_headless = #vim.api.nvim_list_uis() == 0

  -- local github_proxy = "https://hub.fastgit.xyz/"
  -- local github_proxy = "git@github.com:"
  local github_proxy = "https://ghproxy.com/https://github.com/"

  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({ "git", "clone", "--depth", "1", github_proxy .. "wbthomason/packer.nvim", install_path })
    vim.cmd("packadd packer.nvim")
  end

  local log_level = in_headless and "debug" or Log.config.level

  local _, packer = pcall(require, "packer")
  packer.init({
    package_root = package_root,
    compile_path = compile_path,
    log = { level = log_level },
    git = {
      clone_timeout = 30,
      subcommands = {
        -- this is more efficient than what Packer is using
        fetch = "fetch --no-tags --no-recurse-submodules --update-shallow --progress",
      },
      default_url_format = github_proxy .. "%s",
    },
    max_jobs = 50,
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "rounded" })
      end,
    },
    profile = {
      enable = false,
      threshold = 1, -- integer in milliseconds, plugins which load faster than this won't be shown in profile output
    },
    autoremove = true,
  })
  local LeaderpKey = require("utils.key").PrefixModeKey("<Leader>p", "n")
  require("utils.key").load({
    LeaderpKey(""):group("Packer"),
    LeaderpKey("c", "<cmd>PackerSync<CR>"):desc("Sync"),
    LeaderpKey("C", "<cmd>PackerClean<CR>"):desc("Clean"),
    LeaderpKey("i", "<cmd>PackerInstall<CR>"):desc("Install"),
    LeaderpKey("s", "<cmd>PackerSync<CR>"):desc("Sync"),
    LeaderpKey("S", "<cmd>PackerStatus<CR>"):desc("Status"),
    LeaderpKey("u", "<cmd>PackerUpdate<CR>"):desc("Update"),
    LeaderpKey("r", require("core").reload):desc("Reload"),
  })
end

function M.init()
  M.init_packer()
  -- require("plugins").init()
end

function M.setup()
  M.load(require("plugins").packers)
end

-- packer expects a space separated list
local function pcall_packer_command(cmd, kwargs)
  local status_ok, msg = pcall(function()
    require("packer")[cmd](unpack(kwargs or {}))
  end)
  if not status_ok then
    Log:warn(cmd .. " failed with: " .. vim.inspect(msg))
    Log:trace(vim.inspect(vim.fn.eval("v:errmsg")))
  end
end

function M.clean()
  if vim.fn.delete(compile_path) == 0 then
    Log:debug("deleted packer_compiled.lua")
  end
end

function M.recompile()
  M.cache_clear()
  pcall_packer_command("compile")
  if path.is_file(compile_path) then
    Log:debug("generated packer_compiled.lua")
  end
end

function M.load(configurations)
  configurations = configurations or {}
  Log:debug("loading plugins configuration")
  local packer_available, packer = pcall(require, "packer")
  if not packer_available then
    Log:warn("skipping loading plugins until Packer is installed")
    return
  end
  local status_ok, _ = xpcall(function()
    packer.reset()
    packer.startup(function(use)
      use({ "wbthomason/packer.nvim" })
      for _, plugin in pairs(configurations) do
        use(plugin)
      end
    end)
  end, debug.traceback)
  if not status_ok then
    Log:warn("problems detected while loading plugins' configurations")
    Log:trace(debug.traceback())
  end
  require("core.colors").setup()
end

return M
