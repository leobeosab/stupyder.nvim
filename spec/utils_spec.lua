local utils = require("stupyder.utils")

describe("Test Utils", function()

  it ("Generates a random string", function ()
    local strOne = utils.generateRandomString()
    local strTwo = utils.generateRandomString()
    local len = #strOne

    assert.are.same(len, 12)

    assert.are_not.equal(strOne, strTwo)
  end)

  it ("Can see if a number is inbetween another set", function()
    local valOne = 10
    local valTwo = 25
    local valThree = -1

    local min = 5
    local max = 20

    assert.True(utils.isInbetween(valOne, min, max))
    assert.falsy(utils.isInbetween(valTwo, min, max))
    assert.falsy(utils.isInbetween(valThree, min, max))

  end)

  it ("Successfully gets a tables length", function()
    local tableOne = {1,2,3,4,5}
    local tableTwo = {
      a = "ah",
      b = 10,
      "oops"
    }

    assert.are.equal(utils.table_length(tableOne), 5)
    assert.are.equal(utils.table_length(tableTwo), 3)

  end)

  it ("Successfully detects an included string", function()
    local stringPass = "hello world!"
    local stringFail = "hello Steve!"

    assert.True(utils.str_includes(stringPass, "world"))
    assert.falsy(utils.str_includes(stringFail, "world"))

  end)
end)
