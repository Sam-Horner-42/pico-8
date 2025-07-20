
function _init() 
    cls()
	game_state = "main_menu"
	menu_colourtimer = 20
	xcolour = 14
	thruster_particles={}
	start_menu()
end

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
	player = player:new({
		x = 58,
		y = 83,
		alive = true,
		health = 50,
		score = 0,
		menu = true,
	})
end

function start_game()
	sfx(-1)
	music(-1)
	game_state = "play"
	gameplay:init()
end


function print_centered(str, y, text_col, zoffset)
    local text_width = #str * 4
    local x = 64 - (text_width / 2)
    -- foreground
	print(str, x, y, text_col)
end

function print_3d_centered(str, y, shadow_col, text_col, zoffset)
    local text_width = #str * 4
    local x = 64 - (text_width / 2)
    -- foreground
	print(str, x, y, text_col)
    -- shadow
    print(str, x + 1, y, shadow_col)
end

function print_3d_centered_parts(parts, y, shadow_offset, shadow_col)
    -- calculate total width
    local total_chars = 0
    for part in all(parts) do
        total_chars += #part.text
    end
    local total_width = total_chars * 4
    local x = 64 - (total_width / 2)

    -- draw each part
    for part in all(parts) do
        -- shadow
        print(part.text, x + shadow_offset, y, shadow_col)
        -- foreground
        print(part.text, x, y, part.col)
        x += #part.text * 4
    end
end

function draw_menu()

	print_3d_centered("goober shooter", 50, 10, 3, -1)
	
	
	
	print_3d_centered_parts({
    {text="press ", col=10},
    {text="x", col=xcolour},
    {text=" to start", col=10}
	}, 60, -1, 3)
	if btnp(5) then --Z
		start_game()
		game_state = "play"
	end
	
end



function draw_game_over()
	print_3d_centered("game over!", 50, 8, 1, -1)
	print_3d_centered_parts({
    {text="press ", col=9},
    {text="x", col=xcolour},
    {text=" to restart", col=9}
	}, 60, -1, 1)
	print_3d_centered("Your Score: " .. player.score, 50, 8, 1, -1)
	if btnp(5) then --Z
		start_game()
	end
end

function _update() --every frame
	if game_state == "main_menu" then
		player:update()
		

		if menu_colourtimer > 0 then
			menu_colourtimer -= 1
		elseif menu_colourtimer <= 0 then
			if xcolour < 15 then
				xcolour += 1
			elseif xcolour >= 15 then
				xcolour = 14
			end 
			menu_colourtimer = 20
		end
	end
	for star in all(stars) do
		star:update() 
	end
	if game_state == "play" then
		gameplay:update()
		for p in all(thruster_particles) do
			p:update()
			if p.life <= 0 then
				del(thruster_particles, p)
			end
		end
	elseif game_state == "game_over" then
		music(-1)
	end
end

function _draw()
	cls() -- clear the screen
	for star in all(stars) do 
		star:draw() --spawn stars
	end
	if game_state == "main_menu" then
		rectfill(32,42,94,72, 7)
		circfill(36,57,15, 7)
		circfill(90,57,15, 7)
		rectfill(28,46,98,68, 2)
		
		draw_menu()
		for p in all(thruster_particles) do
			p:draw()
		end
		player:draw()
		
	elseif game_state == "play" then
		
		gameplay:draw()
		
	elseif game_state == "game_over" then
		-- TODO add a better game over screen/ending
		draw_game_over()
	end
end