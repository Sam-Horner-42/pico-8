

gameplay = {
    stars={},
    thruster_particles={},
    enemies={},
    pickups={},
    rockets={},
    init = function()
        warningcolourtimer = 20
        gameplay.game_start_timer = 0
        enemy_spawn_timer = 0
        enemy_spawn_interval = 7
        pickup_spawn_timer = 0
        pickup_spawn_interval = 120
        warningcolour = 8
        is_warning_sound_playing = false
        has_music_started = false
        hit_sound_cooldown = 0
        gameplay.popup_x = 0
        gameplay.popup_y = 0
        gameplay.popup_timer = 0

        gameplay.player = player:new({
            x = 58,
            y = 83,
            alive = true,
            health = 50,
            score = 0,
            menu = false,
            health_bar_timer = 0,
            shield=false,
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
        gameplay.laser_beams = {}
        gameplay.enemies = {}
        gameplay.thruster_particles = {}
        gameplay.pickups = {}
        gameplay.rockets = {}
    end,
    
    

    update = function ()
        local player =  gameplay.player
        local enemies =  gameplay.enemies
        local thruster_particles =  gameplay.thruster_particles
        local check_collision =  gameplay.check_collision
        local pickups = gameplay.pickups

        enemy_spawn_timer += 1 --increment spawn timer
        
        pickup_spawn_timer += 1 -- increment pickup timer
        
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
        if player.weapon_timer > 0 then
            player.weapon_timer -= 1
        end
        --wait 1 second before startinng the music
        if gameplay.game_start_timer >= 20 and not has_music_started then 
                sfx(-1, 2)
                music(-1)
                music(0,1200,7)
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
        if gameplay.game_start_timer >= 240 and rnd() < 0.1 and pickup_spawn_timer >= pickup_spawn_interval then -- it has been long enough between enemy spawns
			pickup_spawn_timer = 0
            add(gameplay.pickups, pickup:new({
                x = rnd(120),
				y = -8,
                sprite_id = flr(rnd(4)) + 9,
                }))
        end
        
		-- TODO add second wave
        
        --player movement
        if player.alive then
            player:update()
        end

        for p in all(projectiles) do
            p:update()
            if p.y > 128 then
                deli(projectiles, p)
            end
        end
        for p in all(thruster_particles) do
            p:update()
            if p.life <= 0 then
                deli(thruster_particles, i)
            end
        end
        for laser in all(gameplay.laser_beams) do
            laser:update(player)
        end
        for r in all(gameplay.rockets) do
            r:update()
        end
        -- weapon collisions
        for projectile in all(projectiles) do
            for enemy in all(enemies) do
                if check_collision(projectile, enemy) and enemy.state == "alive" and enemy.y > 0 then
                    enemy.health -= 1
                    if enemy.health == 0 then
                        gameplay.popup_x = enemy.x
                        gameplay.popup_y = enemy.y - 8
                        
                        if hit_sound_cooldown == 0 then
                            sfx(1, 2)
                            hit_sound_cooldown = 5
                        end
                        enemy.state="hit"
                        enemy.explosion_timer = 5
                        del(projectiles, projectile)
                        gameplay.popup_timer = gameplay.game_start_timer
                        player.score+=100
                        break -- break enemy loop after hit
                    end
                end
            end
        end
        --TODO fix laser logic 
        for laser in all(gameplay.laser_beams) do
            for enemy in all(gameplay.enemies) do
                if gameplay.check_collision(laser, enemy) and enemy.state == "alive" then
                    enemy.health -= 1
                    if enemy.health <= 0 then
                        enemy.state = "hit"
                        gameplay.popup_x = enemy.x
                        gameplay.popup_y = enemy.y - 8
                        gameplay.popup_timer = gameplay.game_start_timer
                        player.score+=100
                    end
                end
            end
        end
        for rocket in all(gameplay.rockets) do
            for enemy in all(gameplay.enemies) do
                if check_collision(rocket, enemy) and enemy.state=="alive" then
                    enemy.health -= 3 -- stronger hit?
                    if enemy.health <= 0 then
                        enemy.state = "hit"
                        enemy.explosion_timer = 5
                    end
                    --del(gameplay.rockets, rocket)
                    break
                end
            end
        end
        for p in all(gameplay.pickups) do
            p:update()
            if p.y > 128 then
                deli(gameplay.pickups, p)
            end
        end
        for pickup in all(pickups) do
            if player.alive and pickup.state == "alive" and check_collision(player, pickup) then
                sfx(14, 3)
                gameplay.pickup_function(pickup.sprite_id, player)
                pickup.state = "hit"
            end
        end
        --player collisions
        for enemy in all(enemies) do
            enemy:update()
            if enemy.y > 128 then
                del(enemies, enemy) --delete enemies
            end
            if player.alive and enemy.state == "alive" and check_collision(player, enemy) and player.invuln_timer == 0 then
                enemy.state = "hit"
                if player.shield == false then
                    sfx(2, 3)
                    player.health -= 10
                    player.health_bar_timer = 5
                    player.weapon_timer = 10
                    player.invuln_timer = 10
                    player.hit_effect_timer = 5
                elseif player.shield == true then
                    player.invuln_timer = 10 -- half a second of invulnerability
                    sfx(15, 3)
                    player.shield = false
                end
            end
        end
        
        if gameplay.popup_timer > 0 and gameplay.popup_x > 0 and gameplay.popup_x > 0 then
            gameplay.popup_x -= 1
            gameplay.popup_y -= 1
        end
       
    end,


    --checks if two objects, a and b are colliding, need to change the constants to variables for future enemies
    check_collision = function(a,b)
        return a.x < b.x + b.w and
            a.x + a.w > b.x and
            a.y < b.y + b.h and
            a.y + a.h > b.y
    end,

    pickup_function = function(spr, player)
        if spr == 9 then
            --logic for shield here
            if player.shield == false then
                player.shield = true
            end
        elseif spr == 10 then
            --logic for missiles
            if player.rocket_count != player.max_rockets then
                player.rocket_count += 1
            end
        elseif spr == 11 then
            --logic for laser
            player.weapon = "laser"
            player.weapon_timer = 120 -- 3 seconds of lasers
        elseif spr == 12 then
            --logic for health pickup
            if player.health < 50 then
                player.health += 10  
            end  
        end
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
        
        for laser in all(gameplay.laser_beams) do
            laser:draw()
        end
        for enemy in all(gameplay.enemies) do 
            enemy:draw() --spawn enemies
        end
        for r in all(gameplay.rockets) do
            r:draw()
        end
        for pickup in all(gameplay.pickups) do
            pickup:draw()
        end
        if gameplay.popup_timer > 0 and gameplay.game_start_timer - gameplay.popup_timer < 15 then
            print("+100", gameplay.popup_x, gameplay.popup_y, 8)
            print("+100", gameplay.popup_x - 1, gameplay.popup_y, 7)
        end
        
        
        
        
        gameplay.player:draw() --display the player

        
        if gameplay.game_start_timer <= 180 and gameplay.game_start_timer >= 60 then
            gameplay.draw_warning()
        end
    end,
}