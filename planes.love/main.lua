debug = true

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2 
canShootTimer = canShootTimerMax
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- Player Object
player = { x = 200, y = 710, speed = 150, img = nil }
isAlive = true
score  = 0

-- Image Storage
bulletImg = nil
enemyImg = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies on screen

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function love.load()
	player = { x = 300, y = 410, speed = 350, img = nil }
	player.img = love.graphics.newImage("assets/airplane.png")
	bulletImg = love.graphics.newImage('assets/bullet.png')
	enemyImg = love.graphics.newImage('assets/airplane.png')
end

function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	if love.keyboard.isDown('left','a') then
		if player.x > 0 then -- restricting the map
			player.x = player.x - (player.speed*dt)
		end

		elseif love.keyboard.isDown('right','d') then
			if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
				player.x = player.x + (player.speed*dt)
			end
		end

		canShootTimer = canShootTimer - (1 * dt)
		if canShootTimer < 0 then
			canShoot = true
		end

		if love.keyboard.isDown('space', 'rctrl', 'lctrl', 'ctrl') and canShoot then
			newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
			table.insert(bullets, newBullet)
			canShoot = false
			canShootTimer = canShootTimerMax
		end

		for i, bullet in ipairs(bullets) do
			bullet.y = bullet.y - (250 * dt)

		  	if bullet.y < 0 then -- off screen removing bullets
		  		table.remove(bullets, i)
		  	end
		end

		-- Time out enemy creation
		createEnemyTimer = createEnemyTimer - (1 * dt)
		if createEnemyTimer < 0 then
			createEnemyTimer = createEnemyTimerMax

			-- Create an enemy
			randomNumber = math.random(10, love.graphics.getWidth() - 10)
			newEnemy = { x = randomNumber, y = -10, img = enemyImg }
			table.insert(enemies, newEnemy)
		end

		-- update the positions of enemies
		for i, enemy in ipairs(enemies) do
			enemy.y = enemy.y + (200 * dt)

			if enemy.y > 850 then -- remove enemies when they pass off the screen
				table.remove(enemies, i)
			end
		end

		for i, enemy in ipairs(enemies) do
			for j, bullet in ipairs(bullets) do
				if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
					table.remove(bullets, j)
					table.remove(enemies, i)
					score = score + 1
				end
			end

			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) 
			and isAlive then
				table.remove(enemies, i)
				isAlive = false
			end
		end


		if not isAlive and love.keyboard.isDown('r') then
			-- remove all our bullets and enemies from screen
			bullets = {}
			enemies = {}

			-- reset timers
			canShootTimer = canShootTimerMax
			createEnemyTimer = createEnemyTimerMax

			-- move player back to default position
			player.x = 50
			player.y = 710

			-- reset our game state
			score = 0
			isAlive = true
		end


end

function love.draw(dt)
	love.graphics.setBackgroundColor(255,255,255)
	love.graphics.draw(player.img, player.x, player.y)
	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, enemy in ipairs(enemies) do
	love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end

	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end
end

