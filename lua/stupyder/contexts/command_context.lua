local utils = require("stupyder.utils")
local Runner = require("stupyder.runner")

local CommandContext = {}
CommandContext.__index = CommandContext
CommandContext.runner = Runner:new()
CommandContext.type = "command_context"

function CommandContext:run(content, win, config)
    if self:is_running() then
        print("Currently running: " .. self.runner.current_command)
    end

    local tmpFileName = utils.create_temp_filename(config.tool)
    local tmpfile = io.open(tmpFileName, "w")
    if not tmpfile then
        print("err")
        return
    end


    -- TODO maybe add config to all events?
    config.event_handlers.on_start(win, {
        config = config
    })

    tmpfile:write(content)
    tmpfile:close()

    local runCmd = config.cmd
    if type(runCmd) ~= "table" then
        runCmd = { runCmd }
    end

    local cmds = {}

    for _, cmd in ipairs(runCmd) do
        cmd = cmd:gsub("{tmpfile}", tmpFileName)
        table.insert(cmds, cmd)
    end

    self.runner:run_commands(cmds, function(event, data)
        if event == "start" then
            config.event_handlers.on_command_start(win, { data = { command = data.command }})
        end

        if event == "stdout" or event == "stderr" then
            local lines = {}

            for token in string.gmatch(data, "(.-)\n") do
                table.insert(lines, token)
            end

            -- TODO make stderr call the error cb?

            config.event_handlers.on_data(win, { data = { lines = lines }})
        end

        if event == "exit" then
            config.event_handlers.on_command_end(win, { data = { exit_status = data }})
        end

        if event == "done" then
            config.event_handlers.on_end(win, { data = { result_status = data }})
        end
    end)
end

function CommandContext:is_running()
    return self.runner:is_busy()
end

function CommandContext:cancel(force)
    return self.runner:exit(force)
end

return CommandContext
