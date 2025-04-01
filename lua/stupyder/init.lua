local utils = require("stupyder.utils")
local ui = require("stupyder.ui")
local contexts = require("stupyder.contexts")
local ts = vim.treesitter

local M = {}
M.current_context = nil

local config = {
    tools = {
        python = {
            cmd = "python3 {filename}"
        },
        c = {
            cmd =  { "gcc {filename} -o {filename}.bin", "{filename}.bin" }
        },
        bash = {
            cmd = { "chmod +x {filename}", "bash {filename}" }
        },
    }
}

local win = nil

local block_query = ts.query.parse("markdown", [[ (fenced_code_block (info_string (language) @lang) (code_fence_content) @content) ]])

local getCodeBlocks = function ()
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

        code_blocks[#code_blocks+1] = code_block
    end

    return code_blocks
end

M.setup = function (opts)

end

M.run_on_cursor = function()
    local block = M.check()
    if block == nil then
        print("nope")
    end

    M.run_code(block.language, block.code)
end

M.run_code = function(language, content)
    if not win then
        win = ui:new()
    end
    contexts.CommandContext:run(language, content, win, config)
end

M.check = function ()
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
