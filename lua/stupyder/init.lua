local utils = require("stupyder.utils")
local config = require("stupyder.config")
local contexts = require("stupyder.contexts")
local ts = vim.treesitter

local M = {}
local modes = {
    win = require("stupyder.modes.win"),
    virtual_lines = require("stupyder.modes.virtual_lines"),
    yank = require("stupyder.modes.yank")
}

local block_query = ts.query.parse("markdown",
    [[ (fenced_code_block (info_string (language) @lang) (code_fence_content) @content) ]])

local getCodeBlocks = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local parser = ts.get_parser(bufnr, "markdown")
    local root = parser:parse()[1]:root()

    local code_blocks = {}

    -- Create and execute the Treesitter query
    for _, match, _ in block_query:iter_matches(root, bufnr, 0, -1) do
        local code_block = {}

        for id, node in pairs(match) do
            local name = block_query.captures[id] -- Name of the capture from the query
            local start_line, _, end_line, _ = node:range()

            if name == "lang" then
                code_block.language = ts.get_node_text(node, bufnr)
            end

            if name == "content" then
                code_block.code = ts.get_node_text(node, bufnr)
                code_block.loc = {
                    start_line = start_line,
                    end_line = end_line
                }
            end
        end

        code_blocks[#code_blocks + 1] = code_block
    end

    return code_blocks
end

M.setup = function(opts)

end

M.run_on_cursor = function(mode)
    local block = M.check()
    if block == nil then
        print("nope")
    end

    if mode == "" then
        -- TODO add default mode to config
        mode = "virtual_lines"
    end

    for i, v in pairs(modes) do
        if i == mode:lower() then
            M.run_code(v, block)
            return
        end
    end

    print("Invalid mode")
end

M.run_code = function(mode, block)
    local lang_conf = config.tools[block.language]
    if not lang_conf or not lang_conf.contexts or utils.table_length(lang_conf.contexts) < 1 then
        print("lang context not implemented")
        print(block.language)
        return
    end

    -- Match language up with a context
    -- TODO support for multiple enabled contexts
    for k, _ in pairs(lang_conf.contexts) do
        if not contexts[k] then
            print(k .. " context does not exist")
        end

        local run_config = lang_conf.contexts[k]
        run_config.run_options = config.run_options

        local run_info = {
            block = block,
            config = run_config
        }

        contexts[k]:run(mode, run_info)
    end
end

M.check = function()
    local blocks = getCodeBlocks()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    for _, v in ipairs(blocks) do
        if utils.isInbetween(current_line, v.loc.start_line, v.loc.end_line) then
            return v
        end
    end

    return nil
end

return M
