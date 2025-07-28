rocket = {
    x = 0,
    y = 0,
    spd = -3,
    w = 5,
    h = 4,
    life = 30,
    state = "alive",

    new = function(self, tbl)
        tbl = tbl or {}
        setmetatable(tbl, {__index = self})
        tbl.exps={}
        tbl.expclrs={5, 9, 10, 7}
        return tbl
    end,
    
    destroy = function(self)
        if self.state == "alive" then
            self.spd = 3
            self.state = "hit"
            self.explosion_x = self.x
            self.explosion_y = self.y
            self:spawn_explosion(self.explosion_x, self.explosion_y)
        end
    end,
    
    update = function(self)
        if self.life > 0 and self.state == "alive" then
            self.life -= 1
        elseif self.life <= 15 then
            self:destroy()
        elseif self.life <= 0 then -- TODO fix explosion collisions with rockets
            del(rocket, self)
        end
        for p in all(self.exps) do
            p.x+=p.spdx
            p.y+=p.spdy
            p.scale-=.1
            p.l-=.1
            p.c=flr(p.l)
            if p.l <= 1 then del(self.exps, p) end
            for enemy in all(enemies) do
                if check_collision(p, enemy) and enemy.state=="alive" then
                    enemy_hit(enemy, explosion, 10)
                    if enemy.health <= 0 then
                        enemy.state = "hit"
                        enemy.explosion_timer = 5
                        popup_timer = game_start_timer
                        player.score += 100
                    end
                end
            end
        end
        self.y += self.spd
    end,
    spawn_explosion = function(self, x, y)
        sfx(5, 3)
        for i=0,15 do 
            add(self.exps, {
                x=x-20, -- makes the collision check offset for circle
                y=y-20,
                spdx = 1 - rnd(2),
                spdy= 3,
                scale = 20,
                l=5,
                w=40,
                h=40
            })
        end
        
    end,
    draw = function(self)
	    if self.life > 0 and self.state == "alive" then
            spr(10, self.x, self.y)
        end
        for p in all(self.exps) do
            circfill(p.x+20, p.y+20, p.scale, self.expclrs[p.c]) -- draw +20 because collision checks from 0,0 but we want to draw at origin of explosion
        end  
    end

}