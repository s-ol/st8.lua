local St8 = require"st8"

function textbox(text, x, y, r, g, b)
  if not r then
    r, g, b = 20, 155, 20
  end
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle("fill", x-2, y-2, font:getWidth(text)+4, 17)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(text, x, y)
end

-- set up the metatables for all our states
local MainMenu, Game, PauseMenu, OptionsMenu, ExitOverlay = St8.new(), St8.new(), St8.new(), St8.new(), St8.new()

function love.load()
  St8.init(MainMenu) -- start running the MainMenu state
  font = love.graphics.getFont() -- let's not have _too_ much overhead
end

--- MAIN MENU ---
function MainMenu:draw()
  textbox("< press space to start a new game >", 100, 300)
  textbox("o for options menu", 100, 317)
end

-- using ':' so `self` becomes the previous callback's return value
function MainMenu:keypressed(key)
  if self then return self end -- skip handling if this key was handled already
  
  if key == " " then
    St8.pause(Game)
  elseif key == "o" then
    St8.push(OptionsMenu, "pop")
  end
end

--- OPTIONS MENU ---
function OptionsMenu:draw()
  textbox("Options: f to toggle fullscreen", 280, 150, 125, 20, 20)
  textbox("       esc to resume whatever you were doing", 280, 167, 125, 20, 20)
end

function OptionsMenu:keypressed(key)
  if key == "f" then
    love.window.setFullscreen(not love.window.getFullscreen())
    return true -- indicate to MainMenu that we handled this key
  elseif key == "escape" then
    St8.pop()
    return true
  end
end

--- GAME ---
function Game:enter()
  -- those would normally end up as local variables inside a seperate file (game.lua)
  -- don't forget to reset in `:enter` if they're supposed to be!
  Game.player = {x=100, y=100}
  Game.xvel, Game.yvel = 0, 0
  Game.score = 0
end

function Game:update(dt)
  Game.xvel, Game.yvel = Game.xvel/1.05, Game.yvel/1.05
  if love.keyboard.isDown"left" then
    Game.xvel = Game.xvel - 50
  end
  if love.keyboard.isDown"right" then
    Game.xvel = Game.xvel + 50
  end
  if love.keyboard.isDown"up" then
    Game.yvel = Game.yvel - 50
  end
  if love.keyboard.isDown"down" then
    Game.yvel = Game.yvel + 50
  end
  Game.player.x, Game.player.y = Game.player.x + Game.xvel*dt, Game.player.y + Game.yvel*dt
end

function Game:draw()
  love.graphics.setColor(255, 255, 155)
  love.graphics.circle("fill", Game.player.x, Game.player.y, 20)
  love.graphics.print("Score: "..Game.score, 740, 20)
  love.graphics.print("arrows - move; esc - back to main menu; p - pause", 10, 577)
end

function Game:keypressed(key)
  if self then return self end -- skip handling if this key was handled already
  if key == "p" then
    St8.pause(PauseMenu)
  elseif key == "escape" then
    St8.push(ExitOverlay)
  end
end

--- PAUSE MENU ---
function PauseMenu:draw()
  textbox("< p to resume game >", 280, 300)
  textbox("o for options menu", 280, 317)
end

function PauseMenu:keypressed(key)
  if self then return self end
  if key == "p" then
    St8.resume()
  elseif key == "o" then
    St8.push(OptionsMenu, "pop")
  end
end

--- EXIT OVERLAY ---
function ExitOverlay:draw()
  textbox("Really exit? y/n", 10, 10)
end

function ExitOverlay:keypressed(key)
  if key == "y" then
    St8.resume()
  elseif key == "n" then
    St8.pop()
  end
end