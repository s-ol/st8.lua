local OptionsMenu = {}

--                                                                      options
--                                                          ┏━┓┏━┓╺┳╸╻┏━┓┏┓╻┏━┓
--                                                          ┃ ┃┣━┛ ┃ ┃┃ ┃┃┗┫┗━┓
--                                                          ┗━┛╹   ╹ ╹┗━┛╹ ╹┗━┛
function OptionsMenu:draw()
  textbox("Options: f to toggle fullscreen", 280, 150, 125, 20, 20)
  textbox("       esc to resume whatever you were doing", 280, 167, 125, 20, 20)
end

-- using ':' so `self` becomes the previous callback's return value
function OptionsMenu:keypressed(key)
  if key == "f" then
    love.window.setFullscreen(not love.window.getFullscreen())
    return true -- indicate to MainMenu that we handled this key
  elseif key == "escape" then
    St8.pop()
    return true
  end
end

return OptionsMenu
