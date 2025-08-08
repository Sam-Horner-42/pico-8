-- helper functions ------------------------
function is_within_radius(x1, y1, x2, y2, r)
    local dx = x2 - x1
    local dy = y2 - y1
    return dx*dx + dy*dy <= r*r
end

function decrement_timer(x)
  if x > 0 then return x - 1 end
  return 0
end

function print_centered(str, y, text_col)
    local x = 64 - (#str * 4 / 2)
    print(str, x, y, text_col)
end

function print_3d_centered(str, y, shadow_col, text_col)
    local x = 64 - (#str * 4 / 2)
    -- shadow
    print(str, x, y+1, shadow_col)
    -- foreground
	print(str, x, y, text_col)
end

function print_3d_centered_parts(parts, y, shadow_col)
    -- calculate total width
    local total_chars = 0
    for part in all(parts) do total_chars += #part.text end
    local x = 64 - (total_chars * 4 / 2)

    -- draw each part
    for part in all(parts) do
        -- shadow
        print(part.text, x, y+1, shadow_col)
        -- foreground
        print(part.text, x, y, part.col)
        x += #part.text * 4
    end
end

-- warn the player about asteroids
function draw_warning()
    print_centered("! warning !", 50,  warningcolour)
    print_centered("! asteroid field incoming !", 60,  warningcolour)
end

--outline sprites
function outline_spr(id, x, y, w, h, flip_x, flip_y, col)
    -- remap all colors to outline color
    pal()
    for c = 1, 15 do pal(c, col) end
    -- draw sprite 4 times around offsets
    spr(id, x + 1, y, w, h, flip_x, flip_y)
    spr(id, x - 1, y, w, h, flip_x, flip_y)
    spr(id, x, y + 1, w, h, flip_x, flip_y)
    spr(id, x, y - 1, w, h, flip_x, flip_y)
    pal()  -- reset palette
    pal(0,129,1)
    -- draw normal sprite
    spr(id, x, y, w, h, flip_x, flip_y)
end

-- pickups --------------------------------------
function pickup_function(spr, player)
    if spr < 13 then sfx(1, 3) else sfx(14, 3) end
    if spr == 9 then
        --logic for shields
        if not player.shield then player.shield = true end
    elseif spr == 10 then
        --logic for missiles
        player.rocket_count += 1
    elseif spr == 11 then
        --logic for laser
        player.weapon = "laser"
        player.laser_timer = 120 -- 3 seconds of lasers
    elseif spr == 12 then
        --logic for health pickup
        if player.health < 3 then player.health += 1 end 
    elseif spr ==  13 then player.score += 500 end -- coins
end

-- collisions -------------------
function check_collision(a,b)
	return a.x < b.x + b.w and
		a.x + a.w > b.x and
		a.y < b.y + b.h and
		a.y + a.h > b.y
end

-- UI ---------------------------

-- displays the main menu
function start_menu()
	stars={}

	for i=1,40 do 
		local star_type=rnd({star})
		add(stars,star_type:new({
			x=rnd(127),
			y=rnd(127),
			spd = 0.005
		}))	
	end
	for i=1,60 do 
		local star_type=rnd({far_star})
		add(stars,star_type:new({
			x=rnd(127),
			y=rnd(127),
			spd = 0.0005
		}))	
	end
	for i=1,7 do 
		local star_type=rnd({close_star})
		add(stars,star_type:new({
			x=rnd(127),
			y=rnd(127),
			spd = 0.1
		}))	
	end
end

function start_game()
	sfx(-1) music(-1)
	game_state = "play"

	-- rebuild the tables for the main gameplay
	stars={}
    enemies={}
    pickups={}
    rockets={}
	projectiles = {}
	laser_beams = {}

    player.health = 3
    player.score = 0
    player.alive=true

	-- define variables for use in gameplay
	warningcolourtimer = 60
	game_start_timer = 0
	enemy_spawn_timer = 0
	enemy_spawn_interval = 10
	pickup_spawn_timer = 0
	pickup_spawn_interval = 240
	warningcolour = 8
	is_warning_sound_playing = false
	has_music_started = false
	hit_sound_cooldown = 0
	popup_x = 0
	popup_y = 0
	popup_timer = 0
	
	for i=1,60 do 
		local star_type=rnd({star})
		add(stars,star_type:new({
			x=rnd(127),
			y=rnd(127)
		}))	
	end
	for i=1,80 do 
		local star_type=rnd({far_star})
		add(stars,star_type:new({
			x=rnd(127),
			y=rnd(127)
		}))	
	end

end


function draw_menu()
	circfill(33,57,15, 8)
	circfill(92,57,15, 8)
    rectfill(31,42,94,72, 8)
	rectfill(28,46,98,68, 2)
	print_3d_centered("[blasteroids]", 50, 12, 7)
	
	print_3d_centered_parts({
    {text="PRESS ", col=7},
    {text="x", col=xcolour},
    {text=" TO START", col=7}
	}, 60, 1)
	if btnp(5) then --Z
		start_game()
		game_state = "play"
	end
end

function draw_game_over(score)
	if not game_over_sound_playing then
		sfx(19, 3)
		game_over_sound_playing = true
	end
	
	print_3d_centered("game over!", 50, 8, 7)
	print_3d_centered("YOUR SCORE:" .. score, 60, 8, 7)
	print_3d_centered_parts({
    {text="press ", col=9},
    {text="z", col=xcolour},
    {text=" to restart", col=9}
	}, 70, -1, 1)
	if grace_period_started == true and grace_period <= 0 then
		for star in all(stars) do
			star.spd = 0
		end
	end
	
	if grace_period <= 0 and btnp(4) then --Z
		start_game()
	end
end

function enemy_hit(enemy, src, dmg)
	enemy.health -= dmg
	enemy.state = "hit"
    if enemy.health <= 0 and src ~= player then
        player.score+=100
        popup_timer = 30
        popup_x=enemy.x
        popup_y=enemy.y
    end
end



function _init() 
    cls()
	game_state = "main_menu"
	menu_colourtimer = 20
    warningcolourtimer = 0
    warningcolour = 8
	xcolour = 14
	grace_period = 0
	game_over_sound_playing = false
	grace_period_started = false
	start_menu()
end

function _update60() --every frame
	-- TODO add screen shake
    -- TODO add asteroid tails
    -- TODO add weapon/ability swapping
    cls()
    game_start_timer = flr(time()) -- increment game timer

	for star in all(stars) do star:update() end
	
    
    if warningcolourtimer <= 0 then
        if warningcolour < 8 then
            warningcolour += 1
        elseif warningcolour == 8 then 
            warningcolour = 7
        end
        warningcolourtimer = 60
    end
    
	if game_state == "main_menu" then
		menu_colourtimer = decrement_timer(menu_colourtimer)
		if menu_colourtimer <= 0 then
			if xcolour < 15 then xcolour += 1 elseif xcolour >= 15 then xcolour = 14 end 
			menu_colourtimer = 20
		end
	end
	
	if game_state == "play" then
		
		--player movement
        if player.alive then player:update() end
        
        for p in all(projectiles) do p:update() end
        
        for laser in all(laser_beams) do laser:update(player) end

        for r in all(rockets) do r:update() end
        -- weapon collisions
		for enemy in all(enemies) do
			enemy:update()

            if player.alive and enemy.state ~= "exploded" and check_collision(player, enemy) and player.invuln_timer == 0 then
                enemy_hit(enemy, player, 10)
                if not player.shield then
                    if hit_sound_cooldown <= 0 then
                        hit_sound_cooldown = 30
                        sfx(2, 3)
                    end
                    player.health -= 1
                    player.fire_cooldown = 10
                    player.invuln_timer = 10
                    player.hit_effect_timer = 20
                elseif player.shield == true then
                    player.invuln_timer = 10 -- half a second of invulnerability
                    sfx(15, 3)
                    player.shield = false
                end
            end
			for projectile in all(projectiles) do
				if check_collision(projectile, enemy) and enemy.y > 0 then
					enemy_hit(enemy, projectile, 1)
					del(projectiles, projectile)
				end
			end
			for laser in all(laser_beams) do
				if check_collision(laser, enemy) and enemy.state == "alive" then
					enemy_hit(enemy, laser, 10)
				end
			end
			for rocket in all(rockets) do
				if check_collision(rocket, enemy) and enemy.state=="alive" then
					rocket:destroy()
				end
			end
        end
        
        for p in all(pickups) do
            p:update()
            if p.y > 128 or p.x < 4 or p.x > 128 then
                deli(pickups, p)
            end
            
			if player.alive and p.state == "alive" and check_collision(player, p) then
                
                pickup_function(p.sprite_id, player)
                p.state = "hit"
            end
        end
        
        
        --wait 1 second before startinng the music
        if game_start_timer >= 1 and not has_music_started then 
            sfx(-1, 2)
            music(-1)
            music(0,1200,7)
            has_music_started = true
        end
        if game_start_timer >= 6 and enemy_spawn_timer >= enemy_spawn_interval then -- it has been long enough between enemy spawns
			enemy_spawn_timer = 0
            add(enemies, enemy:new({
				x = rnd(120),
				y = -8,
                sprite = 4,
                spd = flr(rnd(2)) + 1
			}))
		end
        if game_start_timer >= 6 and rnd() < 0.01 and pickup_spawn_timer >= pickup_spawn_interval then -- it has been long enough between enemy spawns
			pickup_spawn_timer = 0
            add(pickups, pickup:new({
                x = rnd(118) + 2,
				y = -8,
                sprite_id = flr(rnd(4)) + 9,
                }))
        end
        
		-- TODO add second wave
        

		enemy_spawn_timer += 1 --increment spawn timer
        
        pickup_spawn_timer += 1 -- increment pickup timer

        popup_timer = decrement_timer(popup_timer)
        hit_sound_cooldown = decrement_timer(hit_sound_cooldown)
        warningcolourtimer = decrement_timer(warningcolourtimer)
        player.weapon_timer = decrement_timer(player.weapon_timer)
        
	elseif game_state == "game_over" then
		music(-1)
        decrement_timer(grace_period)
	end
end

function _draw()
	cls() -- clear the screen
	
    pal(0,129,1)     
	for star in all(stars) do star:draw() end --spawn stars
	if game_state == "main_menu" then
		draw_menu()
		outline_spr(0, 58, 82, 1, 1, false, false, 2)
        spr(28, 66, 82, 1, 1 , true)
        spr(28, 49, 82)
	elseif game_state == "play" then
		for pickup in all(pickups) do pickup:draw() end
        for enemy in all(enemies) do enemy:draw() end -- draw enemies
        
        if popup_timer > 0 then
            print("+100", popup_x, popup_y, 8)
            print("+100", popup_x - 1, popup_y, 7)
        end
        
        player:draw() --display the player
        
        -- draw projectiles
        for projectile in all(projectiles) do projectile:draw() end
        for laser in all(laser_beams) do laser:draw() end
        for r in all(rockets) do r:draw() end

        --display player score
        print("score "..player.score, 5, 5, 8)
        
        if game_start_timer <= 5 and game_start_timer >= 2 then 
            draw_warning() 
        end
		
	elseif game_state == "game_over" then
		draw_game_over(player.score)
		if grace_period_started == false then
			grace_period = 60
			grace_period_started = true
		end
	end
end