local utils = require("stupyder.utils")
local ui = require("stupyder.ui")
local contexts = require("stupyder.contexts")
local ts = vim.treesitter

local modes = {
    win = require("stupyder.modes.win"),
    yank = require("stupyder.modes.yank")
}

local M = {}
M.current_context = nil

-- TODO support for multiple temp files

local config = {
    tools = {
        python = {
            contexts = {
                command_context = {
                    ext = ".py",
                    filename = "test",
                    cmd = "python3 {code_file}"
                }
            }
        },
        c = {
            contexts = {
                command_context = {
                    ext =".c",
                    cmd = { "gcc {code_file} -o {code_file}.bin", "./{code_file}.bin" },
                    cwd = "{tmpdir}/stupyder/c"
                }
            }
        },
        bash = {
            contexts = {
                command_context = {
                    ext = ".sh",
                    cmd = { "chmod +x {code_file}", "bash {code_file}" }
                }
            }
        },
        lua = {
            --TODO maybe add enable toggles?
            contexts = { nvim_context = { enable = true } }
        },
    },
    contexts = {
        default = {
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
                end,
                on_start = function(mode, event)
                    mode:start()
                    mode:append_lines(
                        {string.format(
                            "====== Executing: %s Using: %s ======", event.config.tool, event.config.context)})
                end,
                on_end = function(mode, event)
                    mode:append_lines(
                        {string.format("====== Finished ======")}
                    )
                    mode:done()
                end,
            }
        },
        nvim_context = {

        },
    },
}

-- HACKY but I'm lazy
-- TODO fix this with a config file
-- adding in the context name values the config
-- we could also just have a display name but whatever
for k, _ in pairs(config.contexts) do
    config.contexts[k].context = k
end

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

M.run_on_cursor = function()
    local block = M.check()
    if block == nil then
        print("nope")
    end

    M.run_code(block.language, block.code)
end

M.run_code = function(language, content)
    local lang_conf = config.tools[language]
    if not lang_conf or not lang_conf.contexts or utils.table_length(lang_conf.contexts) < 1 then
        print("lang context not implemented")
        print(language)
        return
    end

    -- Match language up with a context
    -- TODO support for multiple enabled contexts
    for k, v in pairs(lang_conf.contexts) do
        if not contexts[k] then
            print(k .. " context does not exist")
        end

        local context_conf = lang_conf.contexts[k]

        -- add tool/language to config
        context_conf.tool = language

        contexts[k]:run(content, modes.yank, context_conf)
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
