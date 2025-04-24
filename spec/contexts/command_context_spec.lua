local ccontext = require("stupyder.contexts.command_context")
local helpers = require("spec.helpers")
--TODO compare output, finish tests

describe("Command Context Tests", function ()
  local og_io_open

  setup(function()
    og_io_open = io.open
  end)

  it("Creates a file correctly", function ()
    local file_mock = {
      write = function() end,
      close = function() end
    }
    spy.on(file_mock, "write")
    spy.on(file_mock, "close")

    io.open = function() return file_mock end
    spy.on(io, "open")

    local _, err = ccontext:_create_file("somewords", { ext = "c" }, "/tmp")

    assert.falsy(err)
    assert.spy(file_mock.write).was.called_with(file_mock, "somewords")
  end)

end)
