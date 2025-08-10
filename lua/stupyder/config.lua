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
        rust = {
            contexts = {
                command_context = {
                    ext = ".rs",
                    cmd = {
                        "rustc {code_file} -o out_rs",
                        "./out_rs",
                    },
                    remove_files = { "out_rs" },
                    cwd = "{tmpdir}/stupyder/rust",
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
                    cmd = { "chmod +x {code_file}", "bash {code_file}" },
                    cwd = "{tmpdir}/stupyder/bash"
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
            enter_on_open = true,
            win_config = {
                split = "below",
                height = 10
            }
        },
        yank = {
            register = "*"
        }
    },
    contexts = {
        default = {},
        command_context = {
            -- This is appended onto each code file created with the command context
            -- to remove set to ""
            stupyder_file_id = "_stupyder"
        }
    },
}

local M = default_config

function M:apply_user_config(config)
    for k, v in pairs(config) do
        M[k] = vim.tbl_deep_extend("force", M[k], v)
    end
end


return M
