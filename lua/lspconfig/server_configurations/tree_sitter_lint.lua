local util = require 'lspconfig.util'
local lsp = vim.lsp

local function fix_all(opts)
  opts = opts or {}

  local tree_sitter_lint_lsp_client = util.get_active_client_by_name(opts.bufnr, 'tree_sitter_lint')
  if tree_sitter_lint_lsp_client == nil then
    return
  end

  local request
  if opts.sync then
    request = function(bufnr, method, params)
      tree_sitter_lint_lsp_client.request_sync(method, params, nil, bufnr)
    end
  else
    request = function(bufnr, method, params)
      tree_sitter_lint_lsp_client.request(method, params, nil, bufnr)
    end
  end

  local bufnr = util.validate_bufnr(opts.bufnr or 0)
  request(0, 'workspace/executeCommand', {
    command = 'tree-sitter-lint.applyAllFixes',
    arguments = {
      {
        uri = vim.uri_from_bufnr(bufnr),
        version = lsp.util.buf_versions[bufnr],
      },
    },
  })
end

local root_file = {
  '.tree-sitter-lint.yml',
}

return {
  default_config = {
    cmd = { './.tree-sitter-lint/tree-sitter-lint-local/target/release/tree-sitter-lint-local-lsp'},
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
      'vue',
      'svelte',
      'astro',
      'rust',
    },
    root_dir = util.root_pattern(unpack({'.tree-sitter-lint.yml'})),
  },
  commands = {
    TreeSitterLintFixAll = {
      function()
        fix_all { sync = true, bufnr = 0 }
      end,
      description = 'Fix all tree-sitter-lint problems for this buffer',
    },
  },
  docs = {
    description = [[
https://github.com/helixbass/tree-sitter-lint

`tree-sitter-lint` is a tree-sitter-based linter for multiple languages.
It can be installed via `cargo`:

```sh
cargo install tree-sitter-lint
```

`tree-sitter-lint` provides a `TreeSitterLintFixAll` command that can be used to format a document on save:
```lua
lspconfig.tree_sitter_lint.setup({
  --- ...
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "TreeSitterLintFixAll",
    })
  end,
})
```
]],
  },
}
