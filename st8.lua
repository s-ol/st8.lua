local St8 = {
  _VERSION = "St8 v1.0",
  _DESCRIPTION = "A tiny double-stacked state manging library for Lua/LÖVE",
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2014 Sol Bekic

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

local CALLBACKS = {"draw", "errhand", "focus", "keypressed", "keyreleased", "load", "mousefocus", "mousemoved", "mousepressed", "mousereleased", "quit", "resize", "run", "textinput", "threaderror", "update", "visible"}

local State = {}
for _,cb in ipairs({"enter", "exit", "pause", "resume", unpack(CALLBACKS)}) do
  State[cb] = function (p, ...) return p end
end
St8.old = setmetatable({}, {__index=State})

---------------------------------------------------
-- register St8 with LÖVE callbacks and enter `state` (if `state` is numerically indexed, it will be used as a _Stack_)
function St8.init(state, ...)
  for _,cb in ipairs(CALLBACKS) do
    St8.old[cb] = love[cb]
    love[cb] = function (...)
      return St8.handle(cb, ...)
    end
  end
  if not state[1] then state = {state} end
  St8.stacks = {state}
  St8.handle("enter", ...)
end

---------------------------------------
-- handle `evt` using the current _Stack_
function St8.handle(evt, ...)
  print("handlin",evt,...)
  local stack = St8.stacks[#St8.stacks]
  local prev = nil
  for i=#stack,1,-1 do
    prev = stack[i][evt](prev, ...)
  end
  return St8.old[evt](prev)
end

------------------------------------------
-- create a new _State_ (set it's metatable)
function St8.new()
  return setmetatable({}, {__index=State})
end

------------------------------------------
-- push the _State_ `new` to the current _Stack_ (it will run in parallel to the current one)
function St8.push(new, ...)
  table.insert(St8.stacks, new)
  new:enter(nil, ...)
end

---------------------------------------
-- pop one _State_ from the current _Stack_
function St8.pop(...)
  assert(#St8.stacks[#St8.stacks] ~= 0, "Stack is already empty!")
  table.remove(St8.stacks[#St8.stacks]):exit(nil, ...)
end

--------------------------------------------------
-- pause current _Stack_ and transition to `new` _State_ (if `new` is numerically indexed, it will be used as a new Stack)
function St8.pause(new, ...)
  St8.handle("pause", ...)
  if not new[1] then new = {new} end
  table.insert(St8.stacks, new)
  St8.handle("enter", ...)
end

------------------------
-- resume previous _Stack_
function St8.resume(...)
  assert(#St8.stacks ~= 0, "no Stack to resume!")
  St8.handle("exit", ...)
  table.remove(St8.stacks)
  St8.handle("resume", ...)
end

return St8
