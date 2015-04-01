local Game, PlayerMoveState, EnemyMoveState, ExitOverlay = St8.new(), St8.new(), St8.new(), St8.new()
local player, enemy, xvel, yvel, score, time, etime

function Game:enter()
  player = {x=100, y=100}
  enemy  = {x=400, y=400}
  xvel, yvel = 0, 0
  score, time, etime = 0, 0, 0
  
  St8.push(EnemyMoveState)
end
function Game:draw()
  love.graphics.setColor(70, 70, 70)
  for x=0,800,20 do
    love.graphics.line(x, 0, x, 600)
  end
  for y=0,600,20 do
    love.graphics.line(0, y, 800, y)
  end
  
  love.graphics.setColor(255, 255, 155)
  love.graphics.circle("fill", player.x, player.y, 20)
  love.graphics.setColor(255, 155, 155)
  love.graphics.circle("fill", enemy.x, enemy.y, 15)
  
  love.graphics.print("Score: "..score, 740, 20)
  love.graphics.print("arrows - move; esc - back to main menu; p - pause", 10, 577)
end
-- using ':' so `self` becomes the previous callback's return value
function Game:keypressed(key)
  if self then return self end -- skip handling if this key was handled already
  if key == "p" then
    St8.pause(require"states.pausemenu")
  elseif key == "escape" then
    St8.push(ExitOverlay)
  end
end

function EnemyMoveState:enter()
  if math.pow(enemy.x-player.x,2)+math.pow(enemy.y-player.y,2) <= 900 then -- if touching
    score = score+1
  end
end
function EnemyMoveState:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle("fill", enemy.x, enemy.y, 6)
end
function EnemyMoveState:update(dt)
  time = time+dt
  etime = etime+dt
  if time > 2 then
    time = 0
    St8.pop(EnemyMoveState)
    St8.push(PlayerMoveState)
  end
  enemy.x, enemy.y = love.math.noise(1, etime/4)*800, love.math.noise(-1, etime/3)*600
end

function PlayerMoveState:draw()
  love.graphics.setColor(0, 0, 0)
  love.graphics.circle("fill", player.x, player.y, 11)
end
function PlayerMoveState:update(dt)
  time = time+dt
  if time > 2 then
    time = 0
    St8.pop(PlayerMoveState)
    St8.push(EnemyMoveState)
  end
  xvel, yvel = xvel/1.25, yvel/1.25
  if love.keyboard.isDown"left" then
    xvel = xvel - 50
  end
  if love.keyboard.isDown"right" then
    xvel = xvel + 50
  end
  if love.keyboard.isDown"up" then
    yvel = yvel - 50
  end
  if love.keyboard.isDown"down" then
    yvel = yvel + 50
  end
  player.x, player.y = player.x + xvel*dt, player.y + yvel*dt
end

function ExitOverlay:draw()
  textbox("Really exit? y/n", 10, 10)
end
function ExitOverlay:keypressed(key)
  if key == "y" then
    St8.resume()
  elseif key == "n" then
    St8.pop(ExitOverlay)
  end
end

return Game