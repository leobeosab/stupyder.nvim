--TODO add cleanup options ( save files to delete )
--TODO add support for only outputting info from certain commands
--or by default the last command
local Context = require("stupyder.contexts.context")
local utils = require("stupyder.utils")
local Runner = require("stupyder.runner")

local CommandContext = setmetatable({}, { __index = Context })
CommandContext.runner = Runner:new()
CommandContext.type = "command_context"

CommandContext.default_config = vim.tbl_deep_extend("force", CommandContext.default_config, {
    cwd = "./",
    cmd = "echo \"not implemented\"",
    env = {},
    event_handlers = {
        on_command_start = function(mode, event)
            if event.run_info.config.run_options.print_debug_info then
                mode:append_lines({ string.format("------ Running: %s ------", event.data.command) })
            end
        end,
        on_command_end = function(mode, event)
            if event.run_info.config.run_options.print_debug_info then
                mode:append_lines({ string.format("------ Finished with code: %s ------", event.data.exit_status) })
            end
        end
    }
})

function CommandContext:_create_file(content, config, cwd)
    local filename

    if type(config.filename) == "function" then
        filename = filename(config)
    else
        filename = config.filename
    end

    if not filename or config.tmpfile then
        filename = utils.generateRandomString()
    end

    filename = vim.fs.normalize(filename .. config.ext)

    local path = cwd .. utils.dir_sep .. filename

    local tmpfile = io.open(path, "w")
    if not tmpfile then
        return nil, "Error opening file"
    end

    tmpfile:write(content)
    tmpfile:close()

    return { path=path, filename=filename }, nil
end

function CommandContext:_build_commands(cmd_bp, config, filename)
    local cmd

    if type(cmd_bp) == "function" then
        cmd = config.cmd(config)
    else
        cmd = cmd_bp
    end

    if utils.str_includes(cmd, "{tmpdir}") then
        cmd = cmd:gsub("{tmpdir}", utils.get_tmp_dir())
    end

    if utils.str_includes(cmd, "{code_file}") then
        cmd = cmd:gsub("{code_file}", filename)
    end

    return cmd
end

function CommandContext:_build_cwd(config)
    local cwd

    if type(cwd) == "function" then
        cwd = config.cwd()
    else
        cwd = config.cwd
    end

    if utils.str_includes(cwd, "{tmpdir}") then
        cwd = cwd:gsub("{tmpdir}", utils.get_tmp_dir())
    end

    vim.fn.mkdir(cwd, 'p')
    return vim.fs.normalize(cwd)
end

function CommandContext:run(mode, run_info)
    run_info.config = vim.tbl_deep_extend("force", self.default_config, run_info.config)
    local config = run_info.config

    if self:is_running() then
        print("Currently running: " .. self.runner.current_command)
    end

    local tmpFileName = utils.create_temp_filename(run_info.block.language)
    local tmpfile = io.open(tmpFileName, "w")
    if not tmpfile then
        print("err")
        return
    end

    config.event_handlers.on_start(mode, {
        run_info = run_info
    })

    local cwd = self:_build_cwd(config)
    local file, err = self:_create_file(run_info.block.code, config, cwd)
    if not file or err then
        config.event_handlers.on_error(mode, {err or "Cannot create a file"}, {
            run_info = run_info,
        })
        config.event_handlers.on_end(mode, {
            data = { result_status = 1 },
            run_info = run_info,
        })
        return
    end

    local runCmd = config.cmd
    if type(runCmd) ~= "table" then
        runCmd = { runCmd }
    end

    local cmds = {}

    for _, cmd in ipairs(runCmd) do
        table.insert(cmds, self:_build_commands(cmd, config, file.filename))
    end

    self.runner.cwd = cwd
    self.runner:run_commands(cmds, function(event, data)
        if event == "start" then
            config.event_handlers.on_command_start(mode, {
                data = { command = data.command },
                run_info = run_info
            })
        end

        if event == "stdout" or event == "stderr" then
            local lines = {}

            for token in string.gmatch(data, "(.-)\n") do
                table.insert(lines, token)
            end

            if event == "stderr" then
                config.event_handlers.on_error(mode, lines, { run_info=run_info })
            else
                config.event_handlers.on_data(mode, lines, { run_info=run_info })
            end
        end

        if event == "exit" then
            config.event_handlers.on_command_end(mode, {
                data = { exit_status = data },
                run_info = run_info
            })
        end

        if event == "done" then
            config.event_handlers.on_end(mode, {
                data = { result_status = data },
                run_info = run_info
            })
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
