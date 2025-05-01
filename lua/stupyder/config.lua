local default_config = {
    run_options = {
        print_debug_info = false,
        default_mode = "virtual_lines",
    },
    tools = {
        go = {
            contexts = {
                command_context = {
                    ext = ".go",
                    cmd = {"go fmt {code_file}", "go run {code_file}"}
                }
            }
        },
        python = {
            -- TODO support for venv
            contexts = {
                command_context = {
                    ext = ".py",
                    filename = "test",
                    cmd = "python3 {code_file}"
                }
            }
        },
        c = {
            contexts = {
                command_context = {
                    ext =".c",
                    cmd = { "gcc {code_file} -o out.bin", "./out.bin" },
                    remove_files = { "out.bin" },
                    cwd = "{tmpdir}/stupyder/c"
                }
            }
        },
        bash = {
            contexts = {
                command_context = {
                    ext = ".sh",
                    cmd = { "chmod +x {code_file}", "bash {code_file}" }
                }
            }
        },
        lua = {
            contexts = { nvim_context = {} }
        },
    },
    modes = {
        virtual_lines = {
            hl_group = nil,
            error_hl_group = "ErrorMsg"
        },
        win = {
            close_shortcut = "q",
            win_config = {
                split = "below",
                height = 10
            }
        },
        yank = {
            register = "\"\""
        }
    },
    contexts = {
        default = {},
    },
}

local M = default_config

function M:apply_user_config(config)
    for k, v in pairs(config) do
        M[k] = vim.tbl_deep_extend("force", M[k], v)
    end
end


return M
