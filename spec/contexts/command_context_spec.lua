local ccontext = require("stupyder.contexts.command_context")
local utils = require("stupyder.utils")
--TODO compare output, finish tests

local moc = function(source, target, func, spy, finally)
  local og = source[target]
  source[target] = func
  spy.on(source, target)

  finally(function()
    source[target]:clear()
    source[target] = og
  end)
end

describe("Command Context Tests", function ()
  it("Creates a file correctly", function ()
    moc(utils, "generateRandomString", function() return "heythere" end, spy, finally)

    local file_mock = {
      write = function() end,
      close = function() end
    }
    spy.on(file_mock, "write")
    spy.on(file_mock, "close")

    moc(io, "open", function() return file_mock end, spy, finally)

    local out, err = ccontext:_create_file("somewords", { ext = ".c" }, "/tmp")

    assert.falsy(err)
    assert.spy(file_mock.write).was.called_with(file_mock, "somewords")

    local expected = { filename="heythere.c", path = "/tmp/heythere.c" }
    for k, _ in pairs(out) do
      assert.equal(expected[k], out[k])
    end
  end)

  it("Creates a file correctly with a stupyder id", function ()
    moc(utils, "generateRandomString", function() return "heythere" end, spy, finally)

    local file_mock = {
      write = function() end,
      close = function() end
    }
    spy.on(file_mock, "write")
    spy.on(file_mock, "close")

    moc(io, "open", function() return file_mock end, spy, finally)

    local out, err = ccontext:_create_file("somewords", { ext = ".c", stupyder_file_id = "_stupyder" }, "/tmp")

    assert.falsy(err)
    assert.spy(file_mock.write).was.called_with(file_mock, "somewords")

    local expected = { filename="heythere_stupyder.c", path = "/tmp/heythere_stupyder.c" }
    for k, _ in pairs(out) do
      assert.equal(expected[k], out[k])
    end
  end)

  it("Creates a file correctly with a filename set", function ()
    moc(utils, "generateRandomString", function() return "heythere" end, spy, finally)

    local file_mock = {
      write = function() end,
      close = function() end
    }
    spy.on(file_mock, "write")
    spy.on(file_mock, "close")

    moc(io, "open", function() return file_mock end, spy, finally)

    local out, err = ccontext:_create_file("somewords", { ext = ".c", filename = "testfile" }, "/tmp")

    assert.falsy(err)
    assert.spy(file_mock.write).was.called_with(file_mock, "somewords")

    local expected = { filename="testfile.c", path = "/tmp/testfile.c" }
    for k, _ in pairs(out) do
      assert.equal(expected[k], out[k])
    end
  end)


  local cwd_tests = {
    {
      input = "{tmpdir}/stupyder",
      expect = "/tmp/stupyder",
      test = function(result)
        assert.spy(utils.get_tmp_dir).was.called(1)
      end,
    },
    {
      input = "/stupyder",
      expect = "/stupyder",
      test = function(result)
        assert.spy(utils.get_tmp_dir).was.called(0)
      end,
    },
  }

  it("Builds cwds correctly", function()
    moc(vim.fn, "mkdir", function() end, spy, finally)
    moc(utils, "get_tmp_dir", function() return "/tmp" end, spy, finally)

    -- Test with tmp dir
    for _, t in pairs(cwd_tests) do
      local o = ccontext:_build_cwd({ cwd = t.input })
      assert.equal(t.expect, o)
      t.test(o)
      utils.get_tmp_dir:clear()
    end
  end)

  local command_tests = {
    {
      input = {"gcc {code_file} -o {code_file}.bin", "myfile.c"},
      expect = {
        {"gcc myfile.c -o myfile.c.bin", {output_stdout=true}}
      },
      test = function()

      end,
    },

    {
      input = {"gcc {code_file} -o {tmpdir}/{code_file}.bin", "myfile.c"},
      expect = {
        {"gcc myfile.c -o /tmp/myfile.c.bin", {output_stdout=true}}
      },
      test = function()
        assert.spy(utils.get_tmp_dir).was.called(1)
      end,
    },

    {
      input = {{"gcc {code_file} -o {tmpdir}/{code_file}.bin", "./{code_file}.bin"}, "myfile.c"},
      expect = {
        {"gcc myfile.c -o /tmp/myfile.c.bin", {output_stdout = false}},
        {"./myfile.c.bin", {output_stdout=true}},
      },
      test = function()
        assert.spy(utils.get_tmp_dir).was.called(1)
      end,
    },

    {
      input = {"gcc {code_file} -o {code_file}.bin", "myfile.c"},
      expect = {{"gcc myfile.c -o myfile.c.bin", {output_stdout=true}}},
      test = function()

      end,
    },
  }

  it("Builds commands correctly", function()
    moc(utils, "get_tmp_dir", function () return "/tmp" end, spy, finally)
  
    for _, t in pairs(command_tests) do
      local o = ccontext:_build_commands(t.input[1], {}, t.input[2])
      assert.same(t.expect, o)
      t.test()
      utils.get_tmp_dir:clear()
    end

  end)

  
end)
