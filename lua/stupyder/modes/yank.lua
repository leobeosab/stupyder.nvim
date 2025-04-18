local Yank = {}
Yank.type = "yank"

local content = {}

--TODO some sort of running indicator

function Yank:start()
    content = {}
end

function Yank:append_lines(lines)
    for _, v in ipairs(lines) do
        content[#content+1] = v
    end
end

function Yank:done()
    local output = ""

    for _, v in ipairs(content) do
        output = output .. v .. "\n"
    end


    -- TODO make this configurable
    -- "" for unnamed
    -- * for system cb
    vim.fn.setreg('*', output)
end

return Yank
