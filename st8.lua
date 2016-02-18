local St8 = {
  _VERSION = "St8 v1.1",
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

local HANDLERS = {"draw", "update"}
if love and love.handlers then
  for handler in pairs(love.handlers) do
    table.insert(HANDLERS, handler)
  end
end

local St8 = {}
local stacks = {{}}
local order = {}

--                                                          utilities & options
--                           ╻ ╻╺┳╸╻╻  ╻╺┳╸╻┏━╸┏━┓   ┏┓     ┏━┓┏━┓╺┳╸╻┏━┓┏┓╻┏━┓
--                           ┃ ┃ ┃ ┃┃  ┃ ┃ ┃┣╸ ┗━┓   ┃╺╋╸   ┃ ┃┣━┛ ┃ ┃┃ ┃┃┗┫┗━┓
--                           ┗━┛ ╹ ╹┗━╸╹ ╹ ╹┗━╸┗━┛   ┗━┛    ┗━┛╹   ╹ ╹┗━┛╹ ╹┗━┛

-- hooks to the LÖVE handlers
function St8.hook()
  for _, event in ipairs(HANDLERS) do
    local orig = love[event]
    love[event] = function (...)
      local ret
      if orig then
        ret = orig(...)
      end
      St8.handle(event, ...)
      return ret
    end
  end
end

-- sets the Stack execution order for a given event type
-- default values for 'direction' are anything except "bottom" and "bottom-up"
function St8.order(event, direction)
  order[event] = direction
end

function St8.bind_instance(state)
  local proxy = {}
  for key, val in pairs(state) do
    if type(val) == "function" or getmetatable(val).__call then
      proxy[key] = function (...)
        state[key](state, ...)
      end
    end
  end
  return setmetatable(proxy, {__index=state})
end

--                                                           stack manipulation
--                           ┏━┓╺┳╸┏━┓┏━╸╻┏    ┏┳┓┏━┓┏┓╻╻┏━┓╻ ╻╻  ┏━┓╺┳╸╻┏━┓┏┓╻
--                           ┗━┓ ┃ ┣━┫┃  ┣┻┓   ┃┃┃┣━┫┃┗┫┃┣━┛┃ ┃┃  ┣━┫ ┃ ┃┃ ┃┃┗┫
--                           ┗━┛ ╹ ╹ ╹┗━╸╹ ╹   ╹ ╹╹ ╹╹ ╹╹╹  ┗━┛┗━╸╹ ╹ ╹ ╹┗━┛╹ ╹
function St8.push(state, ...)
  table.insert(stacks[#stacks], state)
  if state.enter then
    return state.enter(...)
  end
end

function St8.pop(...)
  local s = table.remove(stacks[#stacks])
  if not next(stacks[#stacks]) then
    table.insert(stacks[#stacks], {})
  end
  return s.exit(...)
end

function St8.new()
  return {}
end

function St8.pause(state, ...)
  -- treat as stack if empty or numerically-indexed
  if not state[1] and next(state) then
    state = {state}
  end
  St8.handle("pause", ...)
  table.insert(stacks, state)
  St8.handle("enter", ...)
end

function St8.resume(...)
  if not stacks[2] then
    error("no Stack to resume")
  end
  St8.handle("exit", ...)
  table.remove(stacks)
  St8.handle("resume", ...)
end

function St8.handle(event, ...)
  local l
  if order[event] == "bottom-up" or order[event] == "bottom" then
    for _, state in ipairs(stacks[#stacks]) do
      if state[event] then
        l = state[event](l, ...)
      end
    end
  else
    local stack = stacks[#stacks]
    for i=#stack,1,-1 do
      if stack[i][event] then
        l = stack[i][event](l, ...)
      end
    end
  end
  return l
end

return setmetatable(St8, {
  __index = function (St8, key)
    St8[key] = function (...)
      St8.handle(key, ...)
    end
    return St8[key]
  end
})
