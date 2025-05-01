local Context = require("stupyder.contexts.context")
local utils = require("stupyder.utils")
local Runner = require("stupyder.runner")

local CommandContext = setmetatable({}, { __index = Context })
CommandContext.runner = Runner:new()
CommandContext.type = "command_context"
CommandContext.current_run = {
    remove_files = {},
    cwd = "",
}

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
    local filename = utils.generateRandomString()

    filename = vim.fs.normalize(filename .. ".stupyder" .. config.ext)

    local path = cwd .. utils.dir_sep .. filename

    local tmpfile = io.open(path, "w")
    if not tmpfile then
        return nil, "Error opening file"
    end

    tmpfile:write(content)
    tmpfile:close()

    self.current_run.remove_files[#self.current_run.remove_files+1] = path

    return { path=path, filename=filename}, nil
end

function CommandContext:_build_commands(cmds, config, filename)
    local bps = cmds
    if type(bps) ~= "table" then
        bps = { bps }
    end

    local cmds = {}

    for i, bp in ipairs(bps) do
        local cmd = utils.run_func_or_return(bp)

        if utils.str_includes(cmd, "{tmpdir}") then
            cmd = cmd:gsub("{tmpdir}", utils.get_tmp_dir())
        end

        if utils.str_includes(cmd, "{code_file}") then
            cmd = cmd:gsub("{code_file}", filename)
        end

        -- We only want to output the last command
        table.insert(cmds, {cmd,
            {
                output_stdout = i == #bps
            }
        })
    end

    return cmds
end

function CommandContext:_build_cwd(config)
    local cwd = utils.run_func_or_return(config.cwd)

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

    config.event_handlers.on_start(mode, {
        run_info = run_info
    })

    self.current_run.cwd = self:_build_cwd(config)
    local file, err = self:_create_file(run_info.block.code, config, self.current_run.cwd)
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

    local cmds = self:_build_commands(config.cmd, config, file.filename)

    self.runner.cwd = self.current_run.cwd
    self.runner:run_commands(cmds, function(event, data, cmd)
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
            elseif cmd[2].output_stdout then
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

            self:cleanup(config)
        end
    end)

end

function CommandContext:cleanup(config)
    if config.remove_files then
        for _,v in ipairs(config.remove_files) do
            table.insert(self.current_run.remove_files, self.current_run.cwd .. utils.dir_sep .. v)
        end
    end

    for _, v in ipairs(self.current_run.remove_files) do
        pcall(os.remove, v)
    end

    self.current_run = { remove_files = {}, cwd = "" }
end

function CommandContext:is_running()
    return self.runner:is_busy()
end

function CommandContext:cancel(force)
    return self.runner:exit(force)
end

return CommandContext
