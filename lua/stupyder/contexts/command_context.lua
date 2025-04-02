local utils = require("stupyder.utils")
local Runner = require("stupyder.runner")

local CommandContext = {}
CommandContext.__index = CommandContext
CommandContext.runner = Runner:new()

function CommandContext:run(language, content, win, config)
    if self:is_running() then
        print("Currently running: " .. self.runner.current_command)
    end

    local tmpFileName = utils.create_temp_filename(language)
    local tmpfile = io.open(tmpFileName, "w")
    if not tmpfile then
        print("err")
        return
    end

    win:open()
    win:clear_buff()

    tmpfile:write(content)
    tmpfile:close()

    local runCmd = config.tools[language].contexts.command_context.cmd
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
            win:append_to_buffer( { string.format("------ Running: %s ------", data.command) } )
        end

        if event == "stdout" or event == "stderr" then
            local lines = {}

            for token in string.gmatch(data, "(.-)\n") do
                table.insert(lines, token)
            end

            win:append_to_buffer(lines)
        end

        if event == "exit" then
            local ec = data
            win:append_to_buffer({ string.format("------ Finished with code: %d ------", ec) })
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
