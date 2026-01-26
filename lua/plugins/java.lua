return {
    -- Disable the nvim-java meta plugin to avoid its custom downloader flow
    { "nvim-java/nvim-java", enabled = false },

    -- Vanilla JDTLS using mason-installed binary
    {
        "mfussenegger/nvim-jdtls",
        ft = { "java" },
        config = function()
            local jdtls = require("jdtls")
            local base = require("nvchad.configs.lspconfig")

            local root_markers = {
                "settings.gradle",
                "settings.gradle.kts",
                "pom.xml",
                "build.gradle",
                "build.gradle.kts",
                "mvnw",
                "gradlew",
                ".git",
            }

            local function find_root()
                return vim.fs.root(0, root_markers) or vim.loop.cwd()
            end

            local function start_jdtls()
                local root_dir = find_root()
                if not root_dir then
                    vim.notify("JDTLS: no project root found", vim.log.levels.WARN)
                    return
                end

                local workspace_dir = vim.fn.stdpath("data") .. "/jdtls/" .. vim.fs.basename(root_dir)
                vim.fn.mkdir(workspace_dir, "p")

                local cmd = { vim.fn.stdpath("data") .. "/mason/bin/jdtls", "-data", workspace_dir }

                local config = {
                    cmd = cmd,
                    root_dir = root_dir,
                    capabilities = base.capabilities,
                    on_attach = function(client, bufnr)
                        jdtls.setup_dap({ hotcodereplace = "auto" })
                        jdtls.setup.add_commands()
                        if base.on_attach then
                            base.on_attach(client, bufnr)
                        end
                    end,
                    settings = {
                        java = {
                            configuration = {
                                runtimes = {
                                    {
                                        name = "JavaSE-21",
                                        path = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
                                        default = true,
                                    },
                                },
                            },
                        },
                    },
                }

                jdtls.start_or_attach(config)
            end

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = start_jdtls,
            })
        end,
    },
}
