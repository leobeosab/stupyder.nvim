local M = {
    run_options = {
        print_debug_info = false
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
            --TODO maybe add enable toggles?
            contexts = { nvim_context = { enable = true } }
        },
    },
    modes = {
        win = require("stupyder.modes.win"),
        virtual_lines = require("stupyder.modes.virtual_lines"),
        yank = require("stupyder.modes.yank")
    },
    contexts = {
        default = {},
    },
}


return M
