local utils = require("stupyder.utils")
local ts = vim.treesitter

local Reader = {}

local block_query = ts.query.parse("markdown",
    [[ (fenced_code_block (info_string (language) @lang) (code_fence_content) @content) ]])

function Reader:get_code_blocks(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local parser = ts.get_parser(bufnr, "markdown")
    local root = parser:parse()[1]:root()

    local code_blocks = {}

    -- Create and execute the Treesitter query
    for _, match, _ in block_query:iter_matches(root, bufnr, 0, -1) do
        local code_block = {}

        for id, nodes in pairs(match) do
            for _, node in ipairs(nodes) do
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
        end

        code_blocks[#code_blocks + 1] = code_block
    end

    return code_blocks
end

function Reader:get_block_under_cursor()
    local blocks = self:get_code_blocks()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    for _, v in ipairs(blocks) do
        if utils.isInbetween(current_line, v.loc.start_line, v.loc.end_line) then
            return v
        end
    end

    return nil
end


return Reader
