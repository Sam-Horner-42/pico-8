--stars
-- Dark Blue Background
pal(0,129,1)

star={
    x=64, --xpos
    y=-1, --ypos
    spd=1, --speed
    rad=1, --radius
    clr=1, --colour
    flicker_time=0,
    close = false,

    new=function(self,tbl)
        tbl=tbl or {}
        setmetatable(tbl,{__index=self})
        return tbl
    end,

    update=function(self)
        
        self.y += self.spd --move y value by speed each frame

        if self.y-self.rad > 127 then --return to top of screen
            self.y=-self.rad
        end

        if self.flicker_time <= 0 and rnd() < 0.001 then
            self.flicker_time = 60
        end
        
        if self.flicker_time > 0 then 
            self.flicker_time -= 1
        end
    end,

    draw=function(self)
        local c = self.clr
        local r = self.rad -- base radius
        
        if self.flicker_time > 0 and self.flicker_time < 10 then
            c = 10
            circfill(self.x, self.y, r, c)
        else
            circfill(self.x, self.y, r, c)
        end
    end,
}

far_star=star:new({
    clr=1,
    spd=0.5,
    rad=0.5,
    flicker_chance = 0.002,
})

close_star=star:new({
    clr=13,
    spd=2,
    rad=2,
    flicker_chance = 0.01,
	flicker_time = 8,
    close = true,
})