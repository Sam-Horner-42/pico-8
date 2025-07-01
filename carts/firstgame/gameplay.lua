

gameplay = {
    stars={},
    thruster_particles={},
    enemies={},
    pickups={},
    init = function()
        warningcolourtimer = 20
        gameplay.game_start_timer = 0
        enemy_spawn_timer = 0
        enemy_spawn_interval = 7
        warningcolour = 8
        is_warning_sound_playing = false
        has_music_started = false
        hit_sound_cooldown = 0
        
        gameplay.player = player:new({
            x = 58,
            y = 83,
            alive = true,
            health = 50,
            score = 0,
            menu = false,
            health_bar_timer = 0,
        })
        
        stars = {}
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

        projectiles={}
        gameplay.enemies = {}
        gameplay.thruster_particles = {}
        gameplay.pickups = {}
    end,

    update = function ()
        local player =  gameplay.player
        local enemies =  gameplay.enemies
        local thruster_particles =  gameplay.thruster_particles
        local check_collision =  gameplay.check_collision
        local pickups = gameplay.pickups

        enemy_spawn_timer += 1 --increment spawn timer
        
        gameplay.game_start_timer += 1 -- increment game timer
        
        if hit_sound_cooldown > 0 then
            hit_sound_cooldown -= 1
        end
        if warningcolourtimer > 0 then
            warningcolourtimer -= 1
        elseif warningcolourtimer <= 0 then
            if warningcolour < 8 then
                warningcolour += 1
            elseif warningcolour == 8 then 
                warningcolour = 7
            end
            warningcolourtimer = 20
        end

        if gameplay.game_start_timer >= 20 and not has_music_started then -- TODO change to check below a certain threshold
                sfx(-1, 2)
                music(-1)
                music(0,7)
                has_music_started = true
        end
        if gameplay.game_start_timer >= 240 and enemy_spawn_timer >= enemy_spawn_interval then -- it has been long enough between enemy spawns
			enemy_spawn_timer=0
            add(enemies, enemy:new({
				x = rnd(120),
				y = -8,
                sprite_id = 4
			}))
		end
		-- TODO add second wave
        
        --player movement
        if player.alive then
            player:update()
        end

        
        
        for i=#projectiles,1,-1 do
            local proj = projectiles[i]
            proj:update()
            if proj.y > 128 then
                deli(projectiles, i)
            end
        end
        for i=#thruster_particles,1,-1 do
            local p = thruster_particles[i]
            p:update()
            if p.life <= 0 then
                deli(thruster_particles, i)
            end
        end
        

        
        for projectile in all(projectiles) do
            for enemy in all(enemies) do
                if check_collision(projectile, enemy) and enemy.state == "alive" and enemy.y > 0 then
                    enemy.health -= 1
                    if enemy.health == 0 then
                        if hit_sound_cooldown == 0 then
                            sfx(1, 2)
                            hit_sound_cooldown = 5
                        end
                        enemy.state="hit"
                        enemy.explosion_timer = 5
                        del(projectiles, projectile)
                        player.score+=100
                        
                        break -- break enemy loop after hit
                    end
                end
            end
        end
        --player collisions
        for enemy in all(enemies) do
            if player.alive and enemy.state == "alive" and check_collision(player, enemy) then
                sfx(2, 3)
                player.health -= 10
                player.health_bar_timer = 5
                enemy.state = "hit"
            end
        end
        for pickup in all(pickups) do
            if player.alive and pickup.state == "alive" and check_collision(player, pickup) then
                sfx(14, 3)
                pickup.state = "hit"
            end
        end
        --spawn enemies
        for enemy in all(enemies) do
            enemy:update()
            if enemy.y > 128 then
                del(enemies, enemy) --delete enemies
            end
        end
        for i=#gameplay.pickups,1,-1 do
            local p = gameplay.pickups[i]
            p:update()
            if p.y > 128 then
                deli(gameplay.pickups, i)
            end
        end
        
       
    end,


    --checks if two objects, a and b are colliding, need to change the constants to variables for future enemies
    check_collision = function(a,b)
        return a.x < b.x + b.w and
            a.x + a.w > b.x and
            a.y < b.y + b.h and
            a.y + a.h > b.y
    end,

    print_centered = function(str, y, text_col, zoffset)
        local text_width = #str * 4
        local x = 64 - (text_width / 2)
        -- foreground
        print(str, x, y, text_col)
    end,

    draw_warning = function()
         print_centered("! warning !", 50,  warningcolour, -1)
         print_centered("! asteroid field incoming !", 60,  warningcolour, -1)
    end,

    draw = function()
        for projectile in all(projectiles) do 
            projectile:draw()
        end

        for enemy in all(gameplay.enemies) do 
            enemy:draw() --spawn enemies
        end
        for pickup in all(gameplay.pickups) do
            pickup:draw()
        end
        
        gameplay.player:draw() --display the player

        
        if gameplay.game_start_timer <= 180 and gameplay.game_start_timer >= 60 then
            gameplay.draw_warning()
        end
    end
}