describe("St8", function ()
  local _ = require("luassert.match")._

  local function stub_all(tbl, ...)
    for i=1,select("#", ...) do
      stub(tbl, select(i, ...))
    end
    return tbl
  end

  describe("", function ()
    before_each(function ()
      _G.love = {handlers={draw=function()end, update=function()end, keypressed=function()end}}
      package.loaded.st8 = nil
      St8 = require "st8"
    end)

    after_each(function ()
      St8, _G.love = nil, nil
    end)

    it("doesn't explode", function ()
      assert.has_no.errors(function ()
        St8.push({})

        St8.update()
      end)
    end)

    it("passes calls through", function ()
      local state = {}
      stub(state, "update")
      St8.push(state)

      St8.update(10)

      assert.stub(state.update).was_called_with(_, 10)
    end)

    it("supports colon syntax", function ()
      assert.is_not_nil(St8.bind_instance)

      local state = {}
      stub(state, "update")
      St8.push(St8.bind_instance(state))

      St8.update(20)

      assert.stub(state.update).was_called_with(state, _, 20)
    end)

    describe("when pushing States", function ()
      before_each(function ()
        one, two, three = {}, {}, {}
      end)

      it("calls enter", function ()
        stub(one, "enter")
        St8.push(one)

        St8.update(10)

        assert.stub(one.enter).was_called()
      end)

      it("only calls enter on the new State", function ()
        stub(one, "enter")
        stub(two, "enter")

        St8.push(one)
        St8.push(two)

        assert.stub(one.enter).was_called(1)
        assert.stub(two.enter).was_called(1)
      end)

      it("calls all callbacks", function ()
        stub(one, "update")
        stub(three, "update")

        St8.push(one)
        St8.push(two)
        St8.push(three)

        St8.update(10)

        assert.stub(one.update).was_called_with(_, 10)
        assert.stub(three.update).was_called_with(_, 10)
      end)

      it("passes values through all States", function ()
        stub(one,   "draw", "one")
        stub(two,   "draw", "two")
        stub(three, "draw", "three")

        St8.push(one)
        St8.push(two)
        St8.push(three)

        St8.draw()

        assert.stub(one.draw).was_called_with("two")
        assert.stub(two.draw).was_called_with("three")
      end)

      it("supports reversing the order", function ()
        assert.is_not_nil(St8.order)

        stub(one,   "draw", "one")
        stub(two,   "draw", "two")
        stub(three, "draw", "three")

        St8.push(one)
        St8.push(two)
        St8.push(three)

        St8.order("draw", "bottom")
        St8.draw()

        assert.spy(  one.draw).was_called_with(nil)
        assert.spy(  two.draw).was_called_with("one")
        assert.spy(three.draw).was_called_with("two")

          one.draw:clear()
          two.draw:clear()
        three.draw:clear()

        St8.order("draw", "bottom-up")
        St8.draw(1)

        assert.spy(  one.draw).was_called_with(nil,   1)
        assert.spy(  two.draw).was_called_with("one", 1)

          one.draw:clear()
          two.draw:clear()
        three.draw:clear()

        St8.order("draw")
        St8.draw(true)

        assert.spy(  one.draw).was_called_with("two",   true)
        assert.spy(  two.draw).was_called_with("three", true)
        assert.spy(three.draw).was_called_with(nil,     true)
      end)
    end)

    describe("when popping States", function ()
      before_each(function ()
        one, two, three = {}, {}, {}
        St8.push(one)
      end)

      it("calls exit", function ()
        stub(one, "exit")
        St8.pop()
        assert.stub(one.exit).was_called()
      end)
    end)

    describe("when pausing Stacks", function ()
      before_each(function ()
        one, two, three = {}, {}, {}
        stub_all(one,   "pause", "enter", "draw")
        stub_all(two,   "pause", "enter", "draw")
        stub_all(three, "pause", "enter", "draw")
      end)

      it("calls enter and pause", function ()
        St8.push(one)
        St8.pause(two)

        assert.stub(one.pause).was_called()
        assert.stub(two.enter).was_called()
      end)

      it("only calls the new States", function ()
        St8.push(one)
        St8.pause(two)

        St8.draw(3)

        assert.stub(one.draw).was_not_called()
        assert.stub(two.draw).was_called_with(_, 3)
      end)

      it("pushes States to the current Stack", function ()
        St8.push(one)
        St8.pause(two)
        St8.push(three)

        St8.draw(3)

        assert.stub(  one.draw).was_not_called()
        assert.stub(  two.draw).was_called_with(_, 3)
        assert.stub(three.draw).was_called_with(_, 3)
      end)

      it("allows passing a Stack of new States", function ()
        St8.push(one)
        St8.pause{two, three}

        St8.draw(3)

        assert.stub(  one.draw).was_not_called()
        assert.stub(  two.draw).was_called_with(_, 3)
        assert.stub(three.draw).was_called_with(_, 3)
      end)

      it("allows passing data to the new Stack", function ()
        St8.push(one)
        St8.pause(two, "data", "flows")

        assert.stub(two.enter).was_called_with(_, "data", "flows")
      end)
    end)

    describe("when resuming Stacks", function ()
      before_each(function ()
        one, two, three = {}, {}, {}
        stub_all(one,   "resume", "exit", "draw")
        stub_all(two,   "resume", "exit", "draw")
        stub_all(three, "resume", "exit", "draw")

        St8.push(one)
        St8.pause(two)
      end)

      it("calls exit and resume", function ()
        St8.resume()

        assert.stub(one.resume).was_called()
        assert.stub(two.exit).was_called()
      end)

      it("only calls the old stack's States", function ()
        St8.resume()

        St8.draw(3)

        assert.stub(one.draw).was_called_with(_, 3)
        assert.stub(two.draw).was_not_called()
      end)

      it("pushes States to the current Stack", function ()
        St8.resume()
        St8.push(three)

        St8.draw(3)

        assert.stub(  two.draw).was_not_called()
        assert.stub(  one.draw).was_called_with(_, 3)
        assert.stub(three.draw).was_called_with(_, 3)
      end)

      it("allows passing data to the old Stack", function ()
        St8.resume("react", 2, "this")

        assert.stub(one.resume).was_called_with(_, "react", 2, "this")
      end)

      it("errors if there is no Stack left", function ()
        assert.has_no.errors(St8.resume)
        assert.has_error(St8.resume, "no Stack to resume")

        St8.pause(one)
        St8.pause(two)

        assert.has_no.errors(St8.resume)
        assert.has_no.errors(St8.resume)
        assert.has_error(St8.resume, "no Stack to resume")
      end)
    end)
  end)

  describe("when hooking functions", function ()
    setup(function ()
      _G.love = {}
      St8 = require "st8"
    end)

    teardown(function ()
      St8, _G.love = nil, nil
    end)

    it("creates functions", function ()
      St8.hook()

      assert.is_not_nil(love.draw)
      assert.is_not_nil(love.update)
      assert.is_not_nil(love.keypressed)
    end)

    it("passes calls through", function ()
      local state = {}
      stub(state, "update")
      St8.push(state)

      love.update(10)

      assert.stub(state.update).was_called_with(nil, 10)
    end)
  end)
end)
