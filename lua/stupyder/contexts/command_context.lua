local utils = require("stupyder.utils")
local Runner = require("stupyder.runner")
local default_context = require("stupyder.config").contexts.default

local CommandContext = {}
CommandContext.__index = CommandContext
CommandContext.runner = Runner:new()
CommandContext.type = "command_context"

local default_config = vim.tbl_deep_extend("force", default_context, {
    cwd = "./",
    cmd = "echo \"not implemented\"",
    env = {},
    event_handlers = {
        on_command_start = function(mode, event)
            mode:append_lines({ string.format("------ Running: %s ------", event.data.command) })
        end,
        on_command_end = function(mode, event)
            mode:append_lines({ string.format("------ Finished with code: %s ------", event.data.exit_status) })
        end
    }
})

local function create_file(content, config, cwd)
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

local function build_commands(cmd_bp, config, filename)
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

local function build_cwd(config)
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

function CommandContext:run(content, win, run_info)
    run_info.config = vim.tbl_deep_extend("force", default_config, run_info.config)
    local config = run_info.config

    if self:is_running() then
        print("Currently running: " .. self.runner.current_command)
    end

    local tmpFileName = utils.create_temp_filename(run_info.tool)
    local tmpfile = io.open(tmpFileName, "w")
    if not tmpfile then
        print("err")
        return
    end

    -- TODO maybe add config to all events?
    config.event_handlers.on_start(win, {
        run_info = run_info
    })

    local cwd = build_cwd(config)
    local file, err = create_file(content, config, cwd)
    if not file or err then
        config.event_handlers.on_error(win, {
            error = { message = err or "" }
        })
        -- TODO make a cleanup label
        return
    end

    local runCmd = config.cmd
    if type(runCmd) ~= "table" then
        runCmd = { runCmd }
    end

    local cmds = {}

    for _, cmd in ipairs(runCmd) do
        table.insert(cmds, build_commands(cmd, config, file.filename))
    end

    self.runner.cwd = cwd
    self.runner:run_commands(cmds, function(event, data)
        if event == "start" then
            config.event_handlers.on_command_start(win, { data = { command = data.command }})
        end

        if event == "stdout" or event == "stderr" then
            local lines = {}

            for token in string.gmatch(data, "(.-)\n") do
                table.insert(lines, token)
            end

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
