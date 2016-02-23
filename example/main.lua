St8 = require"st8" -- global so other files don't need to re-require

-- draw a well-formatted textbox
function textbox(text, x, y, r, g, b)
  if not r then
    r, g, b = 20, 155, 20
  end
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle("fill", x-2, y-2, font:getWidth(text)+4, 17)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(text, x, y)
end

function love.load()
  St8.hook()                      -- subscribe to LÖVE callbacks
  St8.push(require"states.menu")  -- start running the MainMenu state
  St8.order("draw", "bottom")     -- make draw run bottom-to-top so specific gamestates draw over general ones
  font = love.graphics.getFont()  -- let's not have _too_ much overhead
end
