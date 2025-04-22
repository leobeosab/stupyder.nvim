local M = {
    run_options = {
        print_debug_info = false,
        default_mode = "virtual_lines",
    },
    tools = {
        python = {
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
                    cmd = { "gcc {code_file} -o {code_file}.bin", "./{code_file}.bin" },
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
        }
    },
    contexts = {
        default = {},
    },
}


return M
