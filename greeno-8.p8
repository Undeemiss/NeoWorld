pico-8 cartridge // http://www.pico-8.com
version 32
__lua__


left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

function _init()
    debuginit()
    plr = initplr()
    screen = {x=0,y=0,dx=0}
end

function _update()
    input()
    -- plr.x = 5
    -- plr.dx = 1
    plr.update()
end

function _draw()
    slowdowntimer=0
    cls()
    rectfill(0,0,127,127,1)
    map(screen.x\8, screen.y\8, 0-screen.x%8, 0-screen.y%8, 17, 17)
    plr.draw()
    debugprint()
end

function initplr()
    plr={
		x=0,y=0,dx=0,dy=0,
		sprite=001,
		w=8,h=8
	}
    plr.draw = function(this)
        spr(plr.sprite, plr.x - screen.x, plr.y - screen.y)
    end
    plr.update = function(this)
        plr.dy += 1
        plr.dx = min(max(plr.dx,-3),3)
        plr.dy = min(max(plr.dy,-8),8)
        local rx = plr.dx
        local ry = plr.dy
        local dist
        while rx!=0 or ry!=0 do
            dist=0
            if rx > 0 then
                debugtext(plr.x % 8 == 0)
                if plr.x % 8 == 0 then
                    if mapcollide(plr, right, 0) then
                        plr.dx=0
                        rx=0
                        dist=0
                    else
                        dist = min(8,rx)
                    end
                else
                    dist = 8 - (plr.x % 8)
                end
            elseif rx < 0 then
                if plr.x % 8 == 0 then
                    if mapcollide(plr, left, 0) then
                        plr.dx=0
                        rx=0
                        dist=0
                    else
                        dist = max(-8,rx)
                    end
                else
                    dist = 0 - (plr.x % 8)
                end
            else
                dist = 0
            end
            rx -= dist
            plr.x += dist

            dist=0
            if ry > 0 then
                if plr.y % 8 == 0 then
                    if mapcollide(plr, down, 0) then
                        plr.dy=0
                        ry=0
                        dist=0
                    else
                        dist = min(8,ry)
                    end
                else
                    dist = 8 - (plr.y % 8)
                end
            elseif ry < 0 then
                if plr.y % 8 == 0 then
                    if mapcollide(plr, up, 0) then
                        plr.dy=0
                        ry=0
                        dist=0
                    else
                        dist = max(-8,ry)
                    end
                else
                    dist = 0 - (plr.y % 8)
                end
            else
                dist = 0
            end
            ry -= dist
            plr.y += dist
        end
    end
	return plr
end	

function input()
    if btn(up) and mapcollide(plr, down, 0) then
        plr.dy =- 8
    elseif btn(down) then
        plr.dy+=1
    end
    if btn(left) then
        plr.dx-=1
    elseif btn(right) then
        plr.dx+=1
    elseif plr.dx > 0.5 then
        plr.dx -= 0.5
    elseif plr.dx < -0.5 then
        plr.dx += 0.5
    else
        plr.dx=0
    end

    if (btnp(fire2)) toggledebug()

end

function mapcollide(obj, dir, flag)
    local x = obj.x
    local y = obj.y
    local w = obj.w
    local h = obj.h

    local x1,y1,x2,y2

    if dir==left then
        x1 = x-1
        y1 = y
        x2 = x-1
        y2 = y+h-1
    elseif dir==right then
        x1 = x+w
        y1 = y
        x2 = x+w
        y2 = y+h-1
    elseif dir==up then
        x1 = x
        y1 = y-1
        x2 = x+w-1
        y2 = y-1
    elseif dir==down then
        x1 = x
        y1 = y+h
        x2 = x+w-1
        y2 = y+h
    end
    
    x1\=8
    y1\=8
    x2\=8
    y2\=8
    
    for i=x1,x2 do
        for j=y1,y2 do
            if (fget(mget(i,j), flag)) then
                debugbox(i,j,green)
                return true
            else
                debugbox(i,j,red)
            end
        end
    end
    return false
end

function debuginit()
	debug = false
	debugboxlist = {}
	debugpointlist = {}
    debugtextlist = {}
	
	
	--toggles debug information
	function toggledebug()
		if debug then
			debug=false
		else
			debug=true
		end
	end
	
	
	--adds a 1 sprite box to be
	--shown when debug info is on
	function debugbox(x,y,c)
        if debug then
		    c = c or 7
		    add(debugboxlist,{x*8,y*8,c})
        end
	end
	
	
	--adds a point to be shown
	--when debug info is on
	function debugpoint(x,y,c)
        if debug then
		    c = c or 8
		    add(debugpointlist,{x,y,c})
        end
	end
	
    function debugtext(string)
        if (debug) add(debugtextlist, {string, count(debugtextlist)*8})
    end


	
	function debugprint()
		if debug then
		
		
			for box in all(debugboxlist) do
				rect(box[1]-screen.x,box[2]-screen.y,box[1]-screen.x+7,box[2]-screen.y+7,box[3])
			end
			debugboxlist = {}
			for point in all(debugpointlist) do
				pset(point[1]-screen.x,point[2]-screen.y,8)
			end
			debugpointlist = {}
            
            for line in all(debugtextlist) do
                print(line[1], 0, line[2], white)
            end
            debugtextlist = {}
		end
	end
end

__gfx__
00000000bbbbbbbb9999999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b33333339444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700b33333339444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000333bb3334449944400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000333553334445544400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700333333354444444500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333354444444500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020200000000000002020202000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000200000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000200000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002020202020000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000200000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000200000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
