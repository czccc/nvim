local M = {}

M.setup = function()
  local status_ok, go = pcall(require, "go")
  if not status_ok then
    return
  end

  local lsp_installer_servers = require("nvim-lsp-installer.servers")
  local _, requested_server = lsp_installer_servers.get_server("gopls")

  go.setup({
    go = "go", -- go command, can be go[default] or go1.18beta1
    goimport = "gopls", -- goimport command, can be gopls[default] or goimport
    fillstruct = "gopls", -- can be nil (use fillstruct, slower) and gopls
    gofmt = "gofumpt", --gofmt cmd,
    max_line_len = 120, -- max line length in goline format
    tag_transform = false, -- tag_transfer  check gomodifytags for details
    test_template = "", -- g:go_nvim_tests_template  check gotests for details
    test_template_dir = "", -- default to nil if not set; g:go_nvim_tests_template_dir  check gotests for details
    comment_placeholder = "", -- comment_placeholder your cool placeholder e.g. ﳑ       
    icons = { breakpoint = "🧘", currentpos = "🏃" }, -- setup to `false` to disable icons setup
    verbose = false, -- output loginf in messages
    lsp_gofumpt = true, -- true: set default gofmt in gopls format to gofumpt
    lsp_on_attach = function(client, bufnr)
      require("plugins.lsp").common_on_attach(client, bufnr)
      local Key = require("utils.key").Key
      require("utils.key").load({
        Key("n", "<Leader>mF", "<cmd>GoFmt<cr>", "GoFmt"):buffer(bufnr),
        Key("n", "<Leader>ms", "<cmd>GoFillStruct<cr>", "GoFillStruct"):buffer(bufnr),
        Key("n", "<Leader>mS", "<cmd>GoFillSwitch<cr>", "GoFillSwitch"):buffer(bufnr),
        Key("n", "<Leader>me", "<cmd>GoIfErr<cr>", "GoIfErr"):buffer(bufnr),
        Key("n", "<Leader>mm", "<cmd>GoMake<cr>", "GoMake"):buffer(bufnr),
        Key("n", "<Leader>mb", "<cmd>GoBuild<cr>", "GoBuild"):buffer(bufnr),
        Key("n", "<Leader>mg", "<cmd>GoGenerate<cr>", "GoGenerate"):buffer(bufnr),
        Key("n", "<Leader>mr", "<cmd>GoRun<cr>", "GoRun"):buffer(bufnr),
        Key("n", "<Leader>mv", "<cmd>GoVet<cr>", "GoVet"):buffer(bufnr),
        Key("n", "<Leader>mc", "<cmd>GoCoverage<cr>", "GoCoverage"):buffer(bufnr),
        Key("n", "<Leader>mT", "<cmd>GoTest<cr>", "GoTest"):buffer(bufnr),
        Key("n", "<Leader>mp", "<cmd>GoTestPkg<cr>", "GoTestPkg"):buffer(bufnr),
        Key("n", "<Leader>mt", "<cmd>GoTestFunc<cr>", "GoTestFunc"):buffer(bufnr),
        Key("n", "<Leader>mf", "<cmd>GoTestFile<cr>", "GoTestFile"):buffer(bufnr),
        Key("n", "<Leader>md", "<cmd>GoDoc<cr>", "GoDoc"):buffer(bufnr),
        Key("n", "<Leader>mD", "<cmd>GoDebug<cr>", "GoDebug"):buffer(bufnr),
        Key("n", "<Leader>ma", "<cmd>GoCodeAction<cr>", "GoCodeAction"):buffer(bufnr),
        Key("n", "<Leader>mc", "<cmd>GoCmt<cr>", "GoCmt "):buffer(bufnr),
      })
    end, -- nil: use on_attach function defined in go/lsp.lua,
    --      when lsp_cfg is true
    -- if lsp_on_attach is a function: use this function as on_attach function for gopls
    lsp_keymaps = false, -- set to false to disable gopls/lsp keymap
    lsp_codelens = true, -- set to false to disable codelens, true by default, you can use a function
    -- function(bufnr)
    --    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>F", "<cmd>lua vim.lsp.buf.formatting()<CR>", {noremap=true, silent=true})
    -- end
    -- to setup a table of codelens
    lsp_diag_hdlr = true, -- hook lsp diag handler
    -- virtual text setup
    lsp_diag_virtual_text = { space = 0, prefix = "" },
    lsp_diag_signs = true,
    lsp_diag_update_in_insert = false,
    lsp_document_formatting = true,
    -- set to true: use gopls to format
    -- false if you want to use other formatter tool(e.g. efm, nulls)
    gopls_cmd = nil, -- if you need to specify gopls path and cmd, e.g {"/home/user/lsp/gopls", "-logfile","/var/log/gopls.log" }
    gopls_remote_auto = true, -- add -remote=auto to gopls
    dap_debug = true, -- set to false to disable dap
    dap_debug_keymap = true, -- true: use keymap for debugger defined in go/dap.lua
    -- false: do not use keymap in go/dap.lua.  you must define your own.
    dap_debug_gui = true, -- set to true to enable dap gui, highly recommand
    dap_debug_vt = true, -- set to true to enable dap virtual text
    build_tags = nil, -- set default build tags
    textobjects = true, -- enable default text jobects through treesittter-text-objects
    test_runner = "go", -- richgo, go test, richgo, dlv, ginkgo
    run_in_floaterm = false, -- set to true to run in float window.
    --float term recommand if you use richgo/ginkgo with terminal color
    lsp_cfg = {
      -- true: use non-default gopls setup specified in go/lsp.lua
      -- false: do nothing
      -- if lsp_cfg is a table, merge table with with non-default gopls setup in go/lsp.lua, e.g.
      --   lsp_cfg = {settings={gopls={matcher='CaseInsensitive', ['local'] = 'your_local_module_path', gofumpt = true }}}
      -- other setups
      settings = {
        gopls = {
          -- gofumpt = true, -- A stricter gofmt
          codelenses = {
            gc_details = true, -- Toggle the calculation of gc annotations
            generate = true, -- Runs go generate for a given directory
            regenerate_cgo = true, -- Regenerates cgo definitions
            tidy = true, -- Runs go mod tidy for a module
            upgrade_dependency = true, -- Upgrades a dependency in the go.mod file for a module
            vendor = true, -- Runs go mod vendor for a module
          },
          diagnosticsDelay = "300ms",
          experimentalWatchedFileDelay = "100ms",
          symbolMatcher = "fuzzy",
          completeUnimported = true,
          staticcheck = true,
          matcher = "Fuzzy",
          usePlaceholders = true, -- enables placeholders for function parameters or struct fields in completion responses
          analyses = {
            -- fieldalignment = true, -- find structs that would use less memory if their fields were sorted
            nilness = true, -- check for redundant or impossible nil comparisons
            shadow = true, -- check for possible unintended shadowing of variables
            unusedparams = true, -- check for unused parameters of functions
            unusedwrite = true, -- checks for unused writes, an instances of writes to struct fields and arrays that are never read
          },
        },
      },
      cmd_env = requested_server._default_options.cmd_env,
      on_init = require("plugins.lsp").common_on_init,
    },
  })
end

return M