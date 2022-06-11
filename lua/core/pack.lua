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
      clone_timeout = 60,
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
      threshold = 1, -- integer in milliseconds
    },
    autoremove = true,
  })
  require("utils.key").load_wk({
    name = "Packer",
    c = { "<cmd>PackerCompile<cr>", "Compile" },
    C = { "<cmd>PackerClean<cr>", "Clean" },
    i = { "<cmd>PackerInstall<cr>", "Install" },
    s = { "<cmd>PackerSync<cr>", "Sync" },
    S = { "<cmd>PackerStatus<cr>", "Status" },
    u = { "<cmd>PackerUpdate<cr>", "Update" },
    r = { require("core").reload, "Reload" },
  }, { prefix = "<Leader>p", mode = "n" })
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
end

return M
