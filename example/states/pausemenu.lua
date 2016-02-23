local PauseMenu = {}

--                                                                   pause menu
--                                               ┏━┓┏━┓╻ ╻┏━┓┏━╸   ┏┳┓┏━╸┏┓╻╻ ╻
--                                               ┣━┛┣━┫┃ ┃┗━┓┣╸    ┃┃┃┣╸ ┃┗┫┃ ┃
--                                               ╹  ╹ ╹┗━┛┗━┛┗━╸   ╹ ╹┗━╸╹ ╹┗━┛
function PauseMenu:draw()
  textbox("< p to resume game >", 280, 300)
  textbox("o for options menu", 280, 317)
end

-- using ':' so `self` becomes the previous callback's return value
function PauseMenu:keypressed(key)
  if self then return self end -- skip handling if this key was handled already
  if key == "p" then
    St8.resume()
  elseif key == "o" then
    St8.push(require"states.options", "pop")
  end
end

return PauseMenu
