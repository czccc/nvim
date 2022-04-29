local M = {}
local path = require("utils.path")

function M.init()
  local install_path = path.pack_install_dir
  local package_root = path.pack_dir
  local compile_path = path.pack_compile_path

  -- local github_proxy = "https://hub.fastgit.xyz/"
  local github_proxy = "git@github.com:"
  -- local github_proxy = "https://ghproxy.com/https://github.com/"

  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({ "git", "clone", "--depth", "1", github_proxy .. "wbthomason/packer.nvim", install_path })
    vim.cmd("packadd packer.nvim")
  end

  local _, packer = pcall(require, "packer")
  packer.init({
    package_root = package_root,
    compile_path = compile_path,
    log = { level = "WARN" },
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
    LeaderpKey("c", "<cmd>PackerCompile<CR>", "Compile"),
    LeaderpKey("C", "<cmd>PackerClean<CR>", "Clean"),
    LeaderpKey("i", "<cmd>PackerInstall<CR>", "Install"),
    LeaderpKey("s", "<cmd>PackerSync<CR>", "Sync"),
    LeaderpKey("S", "<cmd>PackerStatus<CR>", "Status"),
    LeaderpKey("u", "<cmd>PackerUpdate<CR>", "Update"),
    LeaderpKey("r", require("core").reload, "Reload"),
  })
end

function M.setup()
  local configurations = require("plugins").packers
  local packer_available, packer = pcall(require, "packer")
  if not packer_available then
    vim.notify("skipping loading plugins until Packer is installed", "WARN")
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
    vim.notify("problems detected while loading plugins' configurations\n" .. debug.traceback(), "ERROR")
  end
  require("core.colors").setup()
end

return M
