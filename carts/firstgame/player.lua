function outline_spr(id, x, y, w, h, flip_x, flip_y, col)
    -- remap all colors to outline color
    pal()
    for c = 1, 15 do
        pal(c, col)
    end
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

player = {
	x = 58,
	y = 83,
	spdx = 0,
    spdy = 0,
    sprite = 0,
    fire_cooldown = 0,
    score = 0,
    health = 100,
    alive = true,
    w = 8,
    h = 8,
    menu = false,
    is_thrusting = false,
    shield = false,
    invuln_timer = 0,
    weapon = "blaster",
    weapon_timer = 0,
    rocket_timer = 0,
    rocket_count = 0,
    max_rockets = 5,
    hit_effect_timer = 0,
    rocket_fired = false,
    laser_timer = 0,
    max_laser_timer = 120,

	new = function(self, tbl)
		tbl = tbl or {}
		setmetatable(tbl, { __index = self })
		return tbl
	end,
    
	update = function(self)
        self.sprite = 0
        if self.menu == false then
            if self.invuln_timer > 0 then
                self.invuln_timer -= 1
            end
            if self.hit_effect_timer > 0 then
                self.hit_effect_timer -= 1
            end
            if self.laser_timer > 0 then
                if btn(5) then 
                    self.laser_timer -= 1
                end
            else
                gameplay.laser_beams = {}
            end
            if self.rocket_timer > 0 then
                self.rocket_timer -= 1
            end
            self.spdx =0 
            self.spdy = 0
            -- movement
            if btn(1) then -- right
                self.spdx = 2 
                self.sprite = 19
            end 
            if btn(0) then -- left
                self.spdx = -2 
                self.sprite = 18
            end 
            if btn(3) then self.spdy = 2 end -- down
            if btn(2) then self.spdy = -2 end -- up

            if self.x > 127 then
                self.x = -5
            end
            if self.x < -5 then
                self.x = 127
            end

            self.x=self.x+self.spdx
            self.y=self.y+self.spdy
            if not btn (3) and not btn(2) then
                add(thruster_particles, thruster_particle:new({
                        x = self.x + 4,
                        y = self.y + 7,
                        dx = rnd(0.1) - 0.1,
                        dy = rnd(0.3) + 0.2,
                        life = 7,
                        size = 2,
                        smoke = false
                    }))
            end
            
            
            -- damaged ship
            if self.health <= 90 then
                add(thruster_particles, thruster_particle:new({
                    x = self.x + 6,
                    y = self.y + 2,
                    dx = rnd(1),
                    dy = rnd(1) + 1,
                    size = flr(rnd((1))) + 10/self.health,
                    life = 7,
                    smoke = true
                }))
                add(thruster_particles, thruster_particle:new({
                    x = self.x+1,
                    y = self.y + 2,
                    dx = -rnd(1),
                    dy = rnd(1) + 1,
                    size = flr(rnd((1))) + 10/self.health,
                    life = 7,
                    smoke = true
                }))    
            end

            --shooting logic 
            if self.fire_cooldown > 0 then
                self.fire_cooldown -=1
            end
            
            -- cleanup laser beams if released or time ran out
            if self.weapon == "laser" then
                if not btn(5) or self.laser_timer <= 0 then
                    gameplay.laser_beams = {}
                    sfx(16, -2)
                end
            end
            if self.health == 0 then
                self.alive = false --TODO add player score the game over screen
                game_state = "game_over"
            end
            --rockets
            if self.rocket_count > 0 and btn(4) and self.rocket_timer <= 0 then 
                if self.rocket_fired == false then
                    self.rocket_fired = true
                end
                -- fire rocket
                add(gameplay.rockets, rocket:new({
                    x = self.x+1,
                    y = self.y+1,
                }))
                self.rocket_timer = 20
                self.rocket_count -= 1
            end
            if self.laser_timer <= 0 then
                self.weapon = "blaster"
            end
            -- blasters and lasers
            if self.fire_cooldown == 0 then
                if btn(5) then 
            -- For blaster, only fire if weapon_timer == 0
            -- For laser, fire as long as laser is equipped and timer > 0
                    if self.weapon == "blaster" and self.weapon_timer <= 0 then
                        self.fire_cooldown = 12
                        self:shoot()
                    elseif self.weapon == "laser" and self.laser_timer > 0 then
                        self:shoot()
                    end
                end
            end 
        end
	end,
    
    -- draw bullets
    shoot = function(self)
        if self.weapon == "blaster" then
            sfx(0, 3)
            -- left gun
            add(projectiles, projectile:new({
                x = self.x-5,
                y = self.y+1 
            }))

            -- right gun
            add(projectiles, projectile:new({
                x = self.x + 5,
                y = self.y+1 
            }))
        elseif self.weapon == "laser" then
            -- only spawn laser if not already spawned
            if self.laser_timer > 0 and btn(5) and self.hit_effect_timer <= 0 and self.invuln_timer <= 0 then
                if #gameplay.laser_beams == 0 then
                    sfx(16, 3)
                    add(gameplay.laser_beams, laser_beam:new({ offset_x = 1 }))
                    add(gameplay.laser_beams, laser_beam:new({ offset_x = 5 }))
                end
            end
        end
        
    end,
    

	draw = function(self)
        
        
        if self.menu == true then 
            outline_spr(0, self.x, self.y, 1, 1, false, false, 2)
        end
        if self.menu == false then  
            
            if self.rocket_count > 0 and not self.rocket_fired then
                print("press [  ]", 9, 97, 7)
                spr(3, 37, 95)
            end
            if self.shield == true then 
                local r = 9 + sin(time() * 1)
                circ(self.x + 3, self.y + 5, r, 2) -- purple glow
                circ(self.x + 3, self.y + 5, r-1, 13) -- purple glow
            end
            
            if btn(2) then
                circfill(self.x + 3, self.y + 9, 2, 12)
                circfill(self.x + 3, self.y + 7, 2, 7)
                circfill(self.x + 3, self.y + 9, 1, 7)
                circfill(self.x + 3, self.y + 12, 1, 12)
                circfill(self.x + 3, self.y + 10, 1, 7)
            end
            for p in all(thruster_particles) do
                p:draw()
            end 
            -- red hit effect 
            if self.hit_effect_timer > 0 then
                pal(6, 8)
                pal(7, 8)
                pal(12,8)
                pal(13, 8)
                pal(9, 8)
                pal(1, 8)
                outline_spr(self.sprite, self.x, self.y, 1, 1, false, false, 2)
                pal()
            else
                outline_spr(self.sprite, self.x, self.y, 1, 1, false, false, 2)
                end
            end
            
            -- reset background palette
            pal(0,129,1)

            
            
            local hearts_x = 120
            local hearts_y = 120
            local heart_spacing = -7
            local total_hearts = 10

            -- calculate how many full hearts to show
            local full_hearts = flr(self.health / 10)

            for i = 0, total_hearts - 1 do
                local x = hearts_x + i * heart_spacing
                if i < full_hearts then
                    spr(1, x, hearts_y) -- full shield
                else
                    spr(2, x, hearts_y) -- broken shield
                end
            end
            
            --TODO move rockets and prompt to the left side after fixing score
            local rockets_x = 5
            local rockets_y = 110

            -- how many rockets the player has
            local full_rockets = self.rocket_count

            spr(14, rockets_x, rockets_y) -- slot with rocket
            print("x", rockets_x + 9, rockets_y + 2, 7)
            print(self.rocket_count, rockets_x + 13, rockets_y + 2, 7)


            local bar_x = 7
            local bar_y = 120
            local bar_max_w = 43
            local bar_h = 5
                
            if self.laser_timer > 0 then
                -- calculate width based on remaining laser_timer
                local bar_w = flr((self.laser_timer / self.max_laser_timer) * bar_max_w)
                -- foreground (red bar showing laser left)
                rectfill(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, 8) -- red
            end
            spr(16, bar_x-2, bar_y-1)
            spr(16, bar_x + bar_max_w-5, bar_y-1,  1, 1, true)
        end
        
}