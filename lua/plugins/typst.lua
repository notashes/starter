return {
    {
        'chomosuke/typst-preview.nvim',
        ft = 'typst',
        version = '0.1.*',
        opts = {
          get_root = function(path_of_main_file)
            local root = os.getenv 'TYPST_ROOT'
            if root then
              return root
            end
            return vim.fn.getcwd()
          end,
        },
        build = function() require 'typst-preview'.update() end,
    },
}
