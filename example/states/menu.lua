local MainMenu = St8.new()

function MainMenu:draw()
  textbox("< press space to start a new game >", 100, 300)
  textbox("o for options menu", 100, 317)
end

-- using ':' so `self` becomes the previous callback's return value
function MainMenu:keypressed(key)
  if self then return self end -- skip handling if this key was handled already
  
  if key == " " then
    St8.pause(require"states.game")
  elseif key == "o" then
    St8.push(require"states.options", "pop")
  end
end

return MainMenu