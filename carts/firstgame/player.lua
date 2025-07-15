player = {
	x = 58,
	y = 83,
	spd = 3,
    fire_cooldown = 0,
    score = 0,
    health = 50,
    alive = true,
    w = 8,
    h = 8,
    menu = false,
    is_thrusting = false,
    shield = false,
    invuln_timer = 0,
    weapon = "blaster",
    weapon_timer = 0,
    rocket_count = 0,
    max_rockets = 5,

	new = function(self, tbl)
		tbl = tbl or {}
		setmetatable(tbl, { __index = self })
		return tbl
	end,
    
	update = function(self)
        if self.menu == false then
            if self.invuln_timer > 0 then
                self.invuln_timer -= 1
            end
            -- movement
            if btn(1) then self.x += self.spd end -- right
            if btn(0) then self.x -= self.spd end -- left
            if btn(3) then self.y += self.spd end -- down
            if btn(2) then self.y -= self.spd end -- up
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
            if self.health <= 30 then
                add(thruster_particles, thruster_particle:new({
                    x = self.x + 7,
                    y = self.y + 3,
                    dx = rnd(2),
                    dy = rnd() + 0.5,
                    size = flr(rnd((1))) + 1 + 10/self.health,
                    life = 5,
                    smoke = true
                }))
                add(thruster_particles, thruster_particle:new({
                    x = self.x,
                    y = self.y + 3,
                    dx = -rnd(2),
                    dy = rnd() + 0.5,
                    size = flr(rnd((1))) + 1 + 10/self.health,
                    life = 5,
                    smoke = true
                }))    
            end

            --shooting logic 
            if self.fire_cooldown > 0 then
                self.fire_cooldown -=1
            end
            
            -- cleanup laser beams if released or time ran out
            if self.weapon == "laser" then
                if not btn(5) or self.weapon_timer <= 0 then
                    gameplay.laser_beams = {}
                    sfx(16, -2)
                end
            end
            if self.health == 0 then
                self.alive = false
                game_state = "game_over"
            end
            --rockets
            if self.weapon == "blaster" and self.rocket_count > 0 and btn(4) and self.weapon_timer <= 0 and not btn(5) then 
                -- special abilities placeholder
                add(gameplay.rockets, rocket:new({
                    x = self.x+1,
                    y = self.y+1,
                }))
                self.weapon_timer = 20
                self.rocket_count -= 1
            end
            if self.weapon_timer <= 0 then
                self.weapon = "blaster"
            end
            -- blasters and lasers
            if self.fire_cooldown == 0 then
                if btn(5) then 
            -- For blaster, only fire if weapon_timer == 0
            -- For laser, fire as long as laser is equipped and timer > 0
                    if self.weapon == "blaster" and self.weapon_timer <= 0 then
                        self.fire_cooldown = 6
                        self:shoot()
                    elseif self.weapon == "laser" and self.weapon_timer > 0 then
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
                x = self.x + 1,
                y = self.y + 1
            }))

            -- right gun
            add(projectiles, projectile:new({
                x = self.x + 5,
                y = self.y + 1
            }))
        elseif self.weapon == "laser" then
            -- only spawn laser if not already spawned
            if #gameplay.laser_beams == 0 and self.weapon_timer > 0 and btn(5) then
                sfx(0, 17)
                sfx(0, 3)
                sfx(16, 3)
                add(gameplay.laser_beams, laser_beam:new({ offset_x = 1 }))
                add(gameplay.laser_beams, laser_beam:new({ offset_x = 5 }))
            end
        end
        
    end,


	draw = function(self)
        if self.menu == true then 
		    spr(0, self.x, self.y)
        end
        if self.menu == false then  
           
            for p in all(thruster_particles) do
                p:draw()
            end 
            if btn(2) then
                circfill(self.x + 3, self.y + 9, 2, 12)
                circfill(self.x + 3, self.y + 7, 2, 7)
                circfill(self.x + 3, self.y + 9, 1, 7)
                circfill(self.x + 3, self.y + 12, 1, 12)
                circfill(self.x + 3, self.y + 10, 1, 7)
            end
            if self.invuln_timer > 0 and not self.shield then
                pal(6, 8)
                pal(7, 8)
                pal(12,8)
                pal(13, 8)
                pal(5, 8)
                pal(9, 8)
                pal(1, 8)
                spr(0, self.x, self.y)
                pal()
            else
                spr(0, self.x, self.y)
            end

            
            pal(0,129,1)
            
            if self.shield == true then 
                local r = 9 + sin(time() * 1) * 1
                circ(self.x + 3, self.y + 4, r, 2) -- purple glow
                circ(self.x + 3, self.y + 4, r-1, 13) -- purple glow
            end
            local bar_x = 120
            local bar_y = 117
            local bar_h = 4
            local bar_w = -50 -- full width when health is max (50 in your case)

            local hearts_x = 115
            local hearts_y = 115
            local heart_spacing = -10
            local total_hearts = 5

            -- calculate how many full hearts to show
            local full_hearts = flr(self.health / 10)

            for i = 0, total_hearts - 1 do
                local x = hearts_x + i * heart_spacing
                if i < full_hearts then
                    spr(1, x, hearts_y) -- full heart
                else
                    spr(2, x, hearts_y) -- empty heart
                end
            end

            local rockets_x = 115
            local rockets_y = 105
            local rocket_spacing = -10
            local total_slots = 5

            -- calculate how many full hearts to show
            local full_rockets = self.rocket_count

            for i = 0, total_slots - 1 do
                local x = rockets_x + i * rocket_spacing
                if i < full_rockets then
                    spr(14, x, rockets_y) -- empty slot
                else
                    spr(15, x, rockets_y) -- slot with rocket
                end
            end

            -- fixed score box
            local x = 10      -- fixed bottom-right position
            local y = 117
            local box_w = 27   -- fixed width
            local box_h = 8     -- height

            -- draw label
            print("score:", x , y , 8) -- white
            
            -- draw score right-aligned
            local score_txt = self.score
            local score_w = (self.score /1000) + 24 -- moves score when it goes up by a multiple of 10
            print(score_txt, x + score_w, y, 8)
        end
        
	end
}