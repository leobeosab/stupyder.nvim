local M = {
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
    contexts = {
        default = {
            event_handlers = {
                on_data = function(mode, event)
                    mode:append_lines(event.data.lines)
                end,
                on_error = function(mode, event)
                    local error = event.error

                    if error then
                        local msg = "Error "

                        if error.code then
                            msg = msg .. " Status Code " .. event.error
                        end

                        if error.message then
                            msg = msg .. "\n " .. error.message
                        end

                        print(msg)
                    end

                    print(error)
                end,
                on_start = function(mode, event)
                    mode:start(event)
                    mode:append_lines(
                        {string.format(
                            "====== Executing: %s Using: %s ======", event.run_info.config.tool, event.run_info.config.context)})
                end,
                on_end = function(mode, event)
                    mode:append_lines(
                        {string.format("====== Finished ======")}
                    )
                    mode:done()
                end,
            }
        },
    },
}


-- HACKY but I'm lazy
-- TODO fix this with a config file
-- adding in the context name values the config
-- we could also just have a display name but whatever
for k, _ in pairs(M.contexts) do
    M.contexts[k].context = k
end

return M
