--TODO add a kill last mode cleanup step on running other modes
--TODO clean up this mess ( init.lua )

local utils = require("stupyder.utils")
local config = require("stupyder.config")
local reader = require("stupyder.reader")

local M = {}

M.init_modes = function()
    M.last_mode = nil
    M.modes = {}
    M.modes.win = require("stupyder.modes.win")
    M.modes.virtual_lines = require("stupyder.modes.virtual_lines")
    M.modes.yank = require("stupyder.modes.yank")
end

M.setup = function(opts)
    config:apply_user_config(opts)

    M.init_modes()
    M.contexts = require("stupyder.contexts")
end

M.run_on_cursor = function(mode)
    local block = reader:get_block_under_cursor()
    if block == nil then
        print("No code block under cursor")
    end

    if mode == "" then
        mode = config.run_options.default_mode
    end

    for i, v in pairs(M.modes) do
        if i == mode:lower() then
            M.run_code(v, block)
            return
        end
    end

    print("Invalid mode")
end

M.run_code = function(mode, block)
    -- clean last mode output if we changed modes
    if M.last_mode and M.last_mode ~= mode then
        M.last_mode:clean()
    end

    local lang_conf = config.tools[block.language]
    if not lang_conf or not lang_conf.contexts or utils.table_length(lang_conf.contexts) < 1 then
        print("lang context not implemented")
        print(block.language)
        return
    end

    -- Match language up with a context
    -- TODO support for multiple enabled contexts
    for k, _ in pairs(lang_conf.contexts) do
        if not M.contexts[k] then
            print(k .. " context does not exist")
        end

        local run_config = lang_conf.contexts[k]
        run_config.run_options = config.run_options

        local run_info = {
            block = block,
            config = run_config
        }

        M.last_mode = mode
        M.contexts[k]:run(mode, run_info)
    end
end



return M
