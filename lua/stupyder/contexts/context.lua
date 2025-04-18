local Context = {}
Context.default_config = {
    event_handlers = {
        on_data = function(mode, lines, event)
            mode:append_lines(lines)
        end,
        on_error = function(mode, message, event)
            print(message)
        end,
        on_start = function(mode, event)
            mode:start(event)
            if event.run_info.config.run_options.print_debug_info then
                mode:append_lines(
                    {string.format(
                        "====== Executing: %s Using: %s ======", event.run_info.config.tool, event.run_info.config.context)})
            end
        end,
        on_end = function(mode, event)
            if event.run_info.config.run_options.print_debug_info then
                mode:append_lines(
                    {string.format("====== Finished ======")}
                )
            end
            mode:done()
        end,
    }
}

-- I had run/cancel/etc defined but they cause LSP warnings for overriding a function

return Context
