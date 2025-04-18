local Context = {}
Context.default_config = {
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
}

-- I had run/cancel/etc defined but they cause LSP warnings for overriding a function

return Context
