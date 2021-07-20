pico-8 cartridge // http://www.pico-8.com
version 32
__lua__


left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

enabledebug = true

function _init()
    score = 0
    maxscore = 0
    plummeting = 5
    xmin = 8
    xmax = 112
    ymax = 16
    plr = initplr()
    cam = initcam()
    debuginit()
    plr.x = 8
    plr.y = 16
end

function _update()
    input()
    plr.update()
    maxscore = max(score, maxscore)
    if (maxscore-1 > score) plummeting -= 1 else plummeting = 5
    cam:chase(plr, 0, -32768.0, 0, -88)
end

function _draw()
    cls()

    --Environment Drawing
    rectfill(0,0,127,127,dark_blue)
    for i=144,-24,-24 do
        map(0, 0, 0, i-cam.y%24, 17, 3)
    end
    map(0, 3, 0, 24-cam.y, 17, 4)

    plr.draw()

    --UI Drawing
    rectfill(0,120,128,128, black)
    if (plummeting < 0) scorecolor = red else scorecolor = white
    print("score:"..maxscore, 1, 122, scorecolor)
    debugdraw()
end

function initplr()
    plr={
		x=0,y=0,dx=0,dy=0,
		sprite=001,
        eyesprite=002,
        dir=true, --false=left, true=right
		w=8,h=8,
        coyoteframes=100
	}
    plr.draw = function()
        spr(plr.sprite, plr.x, plr.y - cam.y)
        spr(plr.eyesprite, plr.x, plr.y - cam.y, 1, 1, plr.dir)
    end
    plr.update = function()
        if plummeting<0 then
            if plr.x >= 64 and plr.x < 88 then
                plr.dx += 2
            elseif plr.x >= 40 and plr.x<64 then
                plr.dx -= 2
            end
        end
        plr.dy += 1
        plr.dx = min(max(plr.dx,-3),3)
        plr.dy = max(plr.dy,-8)
        local rx = plr.dx
        local ry = plr.dy

        if rx>0 then
            plr.dir = true
        elseif rx<0 then
            plr.dir = false
        end

        local idx = rx
        local dist
        while rx!=0 or ry!=0 do
            dist=0
            if rx > 0 then
                if plr.x % 8 == 0 then
                    if mapcollide(plr, right, 0) or plr.x >= xmax then
                        plr.dx=0
                        rx=0
                        dist=0
                    else
                        dist = min(8,rx)
                    end
                else
                    dist = min(rx, 8 - (plr.x % 8))
                end
            elseif rx < 0 then
                if plr.x % 8 == 0 then
                    if mapcollide(plr, left, 0) or plr.x <= xmin then
                        plr.dx=0
                        rx=0
                        dist=0
                    else
                        dist = max(-8,rx)
                    end
                else
                    dist = max(rx, 0 - (plr.x % 8))
                end
            end
            assert((sgn(rx) == sgn(rx-dist)) or rx-dist==0)
            rx -= dist
            plr.x += dist

            dist=0
            if ry > 0 then
                if plr.y % 8 == 0 then
                    if mapcollide(plr, down, 0) or plr.y >= ymax then
                        plr.dy=0
                        ry=0
                        dist=0
                        plr.coyoteframes = -1
                    else
                        dist = min(8,ry)
                    end
                else
                    dist = min(ry, 8 - (plr.y % 8))
                end
            elseif ry < 0 then
                if plr.y % 8 == 0 then
                    if mapcollide(plr, up, 0) then
                        plr.dy=0
                        ry=0
                        dist=0
                    else
                        if idx>0 and plr.x % 8 == 0 and not mapcollide(plr,right,0) then --Special case for getting into 1 block gaps
                            plr.x += 1
                        elseif idx<0 and plr.x % 8 == 0 and not mapcollide(plr,left,0) then
                            plr.x -= 1
                        else
                            dist = max(-8,ry)
                        end
                    end
                else
                    dist = max(ry, 0 - (plr.y % 8))
                end
            end
            ry -= dist
            plr.y += dist
        end
        plr.coyoteframes += 1
        plr.x = min(max(plr.x,xmin),xmax)
        plr.y = min(plr.y,ymax)
        debugval("plr.dy", plr.dy)

        score = (16 - plr.y)\24
        if plr.y==ymax then
            plummeting = 5
            maxscore = 0
        end
    end
	return plr
end	

function initcam()
    cam = {
        x=0, y=0, dx=0, dy=0
    }
    cam.chase = function(this, obj, x1, y1, x2, y2)
        cam.x += round((obj.x-cam.x-63.5)/8)
        if (obj.y-cam.y-63.5 > 0) cam.y += abs(round((obj.y-cam.y-63.5)/8))^1.3 else cam.y += round((obj.y-cam.y-63.5)/8)
        cam.x = min(max(cam.x,x1),x2)
        cam.y = min(max(cam.y,y1),y2)
    end
    return cam
end

function input()
    if btn(fire1) and (plr.coyoteframes < 3 or plr.y==16 or mapcollide(plr, down, 0)) then
        plr.coyoteframes = 100
        plr.dy = -8
    end
    if btn(left) and not btn(right) then
        plr.dx-=1
    elseif btn(right) and not btn(left) then
        plr.dx+=1
    elseif plr.dx > 0 then
        plr.dx = max(plr.dx-1,0)
    elseif plr.dx < -0.5 then
        plr.dx = min(plr.dx+1,0)
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
    if (y1<0) y1 = y1%3
    if (y2<0) y2 = y2%3
    
    for i=x1,x2 do
        for j=y1,y2 do
            if (fget(mget(i,j), flag)) then
                return true
            end
        end
    end
    return false
end

function round(x)
    if x>=0 then
        return flr(x)
    else
        return ceil(x)
    end
end

function debuginit()
	debug = false
	debugboxlist = {}
	debugpointlist = {}
    debugtextlist = {}
	
	--toggles debug information
	function toggledebug()
		if enabledebug and not debug then
			debug=true
		else
			debug=false
		end
	end
	
	--adds a 1 sprite box to be
	--shown when debug info is on
	function debugbox(x,y,c)
        if debug then
		    c = c or yellow
		    add(debugboxlist,{x*8,y*8,c})
        end
	end
	
	--adds a point to be shown
	--when debug info is on
	function debugpoint(x,y,c)
        if debug then
		    c = c or white
		    add(debugpointlist,{x,y,c})
        end
	end
	
    function debugprint(string)
        if (debug) add(debugtextlist, {string, count(debugtextlist)*8})
    end

    function debugval(name, val)
        debugprint(name.." : "..tostring(val))
    end
	
	function debugdraw()
		if debug then
		
		
			for box in all(debugboxlist) do
				rect(box[1]-cam.x,box[2]-cam.y,box[1]-cam.x+7,box[2]-cam.y+7,box[3])
			end
			debugboxlist = {}
			for point in all(debugpointlist) do
				pset(point[1]-cam.x,point[2]-cam.y,point[3])
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
000000000022220000000000722e2227372e227b3b3bb33b0b3bb33b3b3bb3300000000000000000000000000000000000000000000000000000000000000000
000000000022220000e0e00072e22227bb7777bbbb33bbbbbb33bbbbbb33bbbb0000000000000000000000000000000000000000000000000000000000000000
00700700002222000000000072e22227b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb30000000000000000000000000000000000000000000000000000000000000000
00077000000ee00000000000722e22273b3bbb3b3b3bbb3b3b3bbb3b3b3bbb3b0000000000000000000000000000000000000000000000000000000000000000
0007700006777760000000007222e227344443433444434334444343344443430000000000000000000000000000000000000000000000000000000000000000
00700700766676670000000072222e27443444344434443444344434443444340000000000000000000000000000000000000000000000000000000000000000
00000000067666650000000072222e27444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
0000000000565500000000007222e227444444444444444404444444444444400000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0300000000000006070000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0405050505050505050505050505050400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
