player = {
	x = 58,
	y = 83,
	spd = 3,
    fire_cooldown = 0,
    score = 0,
    health = 50,
    alive = true,
    w = 16,
    h = 16,
    menu = true,
    health_bar_colour = 8,
    health_bar_timer = 0,
    is_thrusting = false,

    current_sfx = nil,

	new = function(self, tbl)
		tbl = tbl or {}
		setmetatable(tbl, { __index = self })
		return tbl
	end,

	update = function(self)
        if self.menu == true then
            add(thruster_particles, thruster_particle:new({
                    x = self.x + 4,
                    y = self.y + 7,
                    dx = rnd(0.2) - 0.1,
                    dy = rnd(0.2) + 0.1,
                    clr = flr(rnd(10 - 8 + 1)) + 8,
                    size = 0.5,
                    life = 15
                }))
        else
            if player.health_bar_timer > 0 then 
                player.health_bar_colour = 5
				player.health_bar_timer -= 1
            elseif player.health_bar_timer <= 0 then
                player.health_bar_colour = 8
			end
            -- movement
            if btn(1) then self.x += self.spd end -- right
            if btn(0) then self.x -= self.spd end -- left
            if btn(3) then self.y += self.spd end -- down
            if btn(2) then self.y -= self.spd end -- up
            add(thruster_particles, thruster_particle:new({
                    x = self.x + 4,
                    y = self.y + 6,
                    dx = rnd(1) - 0.5,
                    dy = rnd() + 1,
                    clr = flr(rnd(10 - 8 + 1)) + 8,
                    size = 0.5,
                    life = 4
                }))
            -- forward thrust (up)
            if btn(2) then
                add(thruster_particles, thruster_particle:new({
                    x = self.x + 4,
                    y = self.y + 6,
                    dx = rnd(1) - 0.5,
                    dy = rnd(1),
                    clr = flr(rnd(10 - 8 + 1)) + 8,
                    size = flr(rnd(2 - 1 + 1)),
                    life = 4
                }))
            end
            

            -- damaged ship
            if self.health <= 40 then
                add(thruster_particles, thruster_particle:new({
                    x = self.x + 8,
                    y = self.y + 3,
                    dx = rnd(2),
                    dy = rnd() + 0.5,
                    clr = flr(rnd(6 - 5 + 1)) + 5,
                    size = flr(rnd((2))) + 10/self.health,
                    life = 4
                }))
                add(thruster_particles, thruster_particle:new({
                    x = self.x,
                    y = self.y + 3,
                    dx = -rnd(2),
                    dy = rnd() + 0.5,
                    clr = flr(rnd(6 - 5 + 1)) + 5,
                    size = flr(rnd((2))) + 10/self.health,
                    life = 4
                }))    
            end

            --shooting logic 
            if self.fire_cooldown > 0 then
                self.fire_cooldown -=1
            end
            -- actions
            if self.fire_cooldown == 0 then
                if btn(5) then 
                    self.fire_cooldown = 6
                    self:shoot() -- shoot guns
                end 
            end
            if self.health == 0 then
                self.alive = false
                game_state = "game_over"
            end
            if btn(🅾️) then 
                -- special abilities placeholder
            end 
        end
	end,

    -- draw bullets
    shoot = function(self)
        sfx(0, 3)
        -- left gun
        add(projectiles, projectile:new({
            x = self.x + 1,
            y = self.y + 1
        }))

        -- right gun
        add(projectiles, projectile:new({
            x = self.x + 6,
            y = self.y + 1
        }))
    end,

	draw = function(self)
        --display player, split into 4 parts to display damage later
        
		spr(0, self.x, self.y)
        
        if self.menu == false then  
            for p in all(thruster_particles) do
                p:draw()
            end 
            local bar_x = 120
            local bar_y = 117
            local bar_h = 4
            local bar_w = -50 -- full width when health is max (50 in your case)

            -- calculate current width based on health (assuming max 50)
            local current_w = (self.health / 50) * bar_w

            -- draw the bar
            rectfill(bar_x + 1, bar_y-1, (bar_x) + bar_w -1, (bar_y) + (bar_h + 1), 7) -- white background
            rectfill(bar_x, bar_y, bar_x + current_w, bar_y + bar_h, self.health_bar_colour) -- red-orange
            -- fixed score box
            local score_label = "score:"
            local x = 5      -- fixed bottom-right position
            local y = 115
            local box_w = 50    -- fixed width
            local box_h = 8     -- height

            -- background + border
            rectfill(x, y, x + box_w, y + box_h, 7) -- white background
            rect(x, y, x + box_w, y + box_h, 8)     -- orange border

            -- draw label
            print(score_label, x + 2, y + 2, 0) -- white

            -- draw score right-aligned
            local score_txt = self.score
            local score_w = #tostr(score_txt) * 4
            print(score_txt, x + box_w - score_w - 2, y + 2, 0)
        end
        
	end
}