

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
    w = 7,
    h = 7,
    is_thrusting = false,
    shield = false,
    invuln_timer = 0,
    weapon = "blaster",
    weapon_timer = 0,
    rocket_timer = 0,
    rocket_count = 0,
    hit_effect_timer = 0,
    rocket_fired = false,
    laser_timer = 0,
    max_laser_timer = 120,
    outline = 2,
    flame = 22,
    radius = 0,
    gun = 29,

	new = function(self, tbl)
		tbl = tbl or {}
		setmetatable(tbl, { __index = self })
		return tbl
	end,
    
	update = function(self)
        self.sprite = 0
        self.spdx = 0 
        self.spdy = 0
        if self.flame >= 26 then
            self.flame = 22
        end
        self.flame += 0.1
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
            laser_beams = {}
        end
        if self.rocket_timer > 0 then
            self.rocket_timer -= 1
        end
        
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
        if self.radius > 0 then
            self.radius -= 1
        else self.radius = 4   
        end
        -- damaged ship
        if self.health <= 50 then
            add(thruster_particles, thruster_particle:new({
                x = self.x + 6,
                y = self.y + 2,
                dx = rnd(1),
                dy = rnd(1),
                size = flr(rnd((1))) + 1 +  10/self.health,
                life = 7,
                smoke = true
            }))
            add(thruster_particles, thruster_particle:new({
                x = self.x+1,
                y = self.y + 2,
                dx = -rnd(1),
                dy = rnd(1),
                size = flr(rnd((1))) + 1 + 10/self.health,
                life = 7,
                smoke = true
            }))    
        end
        if self.health <= 30 and not btn(1) and not btn(0) then
            self.sprite = 21
        end
        self.gun = 28
        if btn(5) then
            self.gun = 30
        end
        --shooting logic 
        if self.fire_cooldown > 0 then
            if not btn(5) then
                if self.fire_cooldown > 5 then
                    self.gun = 29
                else
                    self.gun = 28
                end  
            end
            self.fire_cooldown -= 1  
        end
        
        -- cleanup laser beams if released or time ran out
        if self.weapon == "laser" then
            if not btn(5) or self.laser_timer <= 0 then
                laser_beams = {}
                sfx(16, -2)
            end
        end
        if self.health == 0 then
            self.alive = false 
            game_state = "game_over"
        end
        --rockets
        if self.rocket_count > 0 and btn(4) and self.rocket_timer <= 0 then 
            if self.rocket_fired == false then
                self.rocket_fired = true
            end
            -- fire rocket
            add(rockets, rocket:new({
                x = self.x,
                y = self.y+2,
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
                if #laser_beams == 0 then
                    sfx(16, 3)
                    add(laser_beams, laser_beam:new({ offset_x = 1 }))
                    add(laser_beams, laser_beam:new({ offset_x = 5 }))
                end
            end
        end
    end,
    
	draw = function(self)
        
        
        
        
        -- red hit effect 
        if self.hit_effect_timer > 0 then
            self.outline = 8
        else
            self.outline = 2
        end
        if btn(5) and self.fire_cooldown > 8 then
            circfill(self.x-2, self.y-1, self.radius, 7)
            circfill(self.x+7, self.y-1, self.radius, 7)
        end
        spr(self.flame, self.x, self.y+6)

        spr(self.gun, self.x+8, self.y)
        spr(self.gun, self.x-9, self.y)
        if self.shield == true then 
            local r = 9 + sin(time() * 1)
            circ(self.x + 3, self.y + 5, r, 3) -- purple glow
            circ(self.x + 3, self.y + 5, r-1, 7) -- purple glow
        end
        outline_spr(self.sprite, self.x, self.y, 1, 1, false, false, self.outline)
        -- reset background palette
        pal(0,129,1)
        if btn(2) then
            circfill(self.x + 3, self.y + 9, 2, 12)
            circfill(self.x + 3, self.y + 7, 2, 7)
            circfill(self.x + 3, self.y + 9, 1, 7)
            circfill(self.x + 3, self.y + 12, 1, 12)
            circfill(self.x + 3, self.y + 10, 1, 7)
        end
        
        local hearts_x = 120
        local hearts_y = 120
        local heart_spacing = -7

        -- calculate how many full hearts to show
        local full_hearts = flr(self.health / 10)

        --display player health
        for i = 0, 9 do
            local x = hearts_x + i * heart_spacing
            if i < full_hearts then
                spr(1, x, hearts_y) -- full shield
            else
                spr(2, x, hearts_y) -- broken shield
            end
        end
        
        local rockets_x = 6
        local rockets_y = 110

        spr(10, rockets_x, rockets_y) -- slot with rocket
        print("x"..self.rocket_count, rockets_x + 9, rockets_y + 1, 7)

        local bar_x = 7
        local bar_y = 120
        local max_w = 43
        local bar_h = 5
            
        if self.laser_timer > 0 then
            -- calculate width based on remaining laser_timer
            local bar_w = flr((self.laser_timer / self.max_laser_timer) * max_w)
            -- foreground (red bar showing laser left)
            rectfill(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, 8) -- red
        end
        spr(16, bar_x-2, bar_y-1)
        spr(16, bar_x + max_w-5, bar_y-1, 1, 1, true)
    end,     
}