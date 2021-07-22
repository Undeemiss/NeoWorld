pico-8 cartridge // http://www.pico-8.com
version 32
__lua__


left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

debug = true

--Game Constants
coyotemax = 2
bgsigncount = 6
mlist = {{"soar", 1}, {"fly", 1}, {"leap", 1}, {"win", 1}, {"rise", 1}} --Text, number of mid-sections to use
spallist = {{black, green, dark_gray, green}, {dark_purple, pink, dark_gray, pink}} --Main color, light color, [edge color], [text color]
xmin = 8
xmax = 112
ymax = 16

function _init()
    debuginit()
    score = 0
    maxscore = 0
    plummeting = 5
    plr = initplr()
    cam = initcam()

    bgsigns = {}
    for i=1,bgsigncount do
        add(bgsigns, initbgsign())
    end
    plr.x = 8
    plr.y = 16
end

function _update()
    input()
    plr.update()
    for bgsign in all(bgsigns) do
        bgsign:update()
    end
    maxscore = max(score, maxscore)
    if (maxscore > score) plummeting -= 1 else plummeting = 5
    cam:chase(plr, 0, -32768.0, 0, -88)
end

function _draw()
    cls()

    --BG Rendering
    rectfill(0,0,127,127,blue)
    for bgsign in all(bgsigns) do
        bgsign:draw()
    end

    --Level Rendering
    for i=144,-24,-24 do
        map(0, 0, 0, i-cam.y%24, 17, 3)
    end
    map(0, 3, 0, 24-cam.y, 17, 4)

    plr.draw()

    --UI Rendering
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
        coyoteframes=0
	}
    plr.draw = function()
        palt(dark_purple, true)
        if plr.coyoteframes != coyotemax and plr.dy < coyotemax then
            spr(plr.eyesprite, plr.x, plr.y + 1.5 - sgn(plr.dy) - cam.y)
        end
        spr(plr.sprite, plr.x, plr.y - cam.y)
        palt(black, false)
        spr(plr.eyesprite, plr.x, plr.y - cam.y, 1, 0.5, plr.dir)
        pal()
    end
    plr.update = function()
        if plummeting<0 then
            if plr.x >= 64 and plr.x < 88 then
                plr.dx += 2
            elseif plr.x >= 40 and plr.x<64 then
                plr.dx -= 2
            end
        end
        if plr.coyoteframes > 0 then
            plr.coyoteframes += 1
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
                    if plr.y >= ymax or mapcollide(plr, down, 0) then
                        plr.dy=0
                        ry=0
                        dist=0
                        plr.coyoteframes = coyotemax
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
        plr.x = min(max(plr.x,xmin),xmax)
        plr.y = min(plr.y,ymax)
        score = (20 - plr.y)\24
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

function initbgsign()
    bgsign = {
        x=rnd(128)-16, y=rnd(140)-18, dx= rnd(0.15)-0.075,
        cornersprite=016
    }

    bgsign.rmid = function(self)
        local mid = flr(rnd(count(mlist))+1)
        self.msg=mlist[mid][1]
        self.w=mlist[mid][2]
    end

    bgsign.rpal = function(self)
        t=flr(rnd(30))
        local pid = flr(rnd(count(spallist))+1)
        self.mcolor = spallist[pid][1]
        self.lcolor = spallist[pid][2]
        self.bcolor = spallist[pid][3] or dark_gray
        self.tcolor = spallist[pid][4] or black
    end

    bgsign.draw = function(self)
        pal(light_gray, self.mcolor)
        pal(dark_blue, self.mcolor)
        pal(dark_purple, self.mcolor)
        pal(dark_green, self.mcolor)
        pal(t\10+1, self.lcolor)
        pal(dark_gray, self.bcolor)

        spr(self.cornersprite, self.x, self.y - cam.y/16, 1, 2)
        for i=1,self.w do
            spr(self.cornersprite+1, self.x + 8*i, self.y - cam.y/16, 1, 2)
        end
        spr(self.cornersprite+2, self.x + 8*(self.w + 1), self.y - cam.y/16, 1, 2)

        pal()
        printc(self.msg, self.x + 4*(2+self.w), self.y + 5 - cam.y/16, self.tcolor)
    end

    bgsign.update = function(self)
        if t<29 then
            t+=1
        else
            t=0
        end
        if self.x > xmax+8 or self.x < xmin-8*(2+self.w) or self.y - cam.y/16 < -18 or self.y - cam.y/16 > 122 then
            self:respawn()
        end
        self.x += self.dx
    end

    bgsign.respawn = function(self, low)
        if rnd() > 0.5 then
            self.x = xmin-8*(2+self.w)
            self.dx = rnd(0.075)
        else
            self.x = xmax+8
            self.dx = -rnd(0.075)
        end
        self.y = rnd(32) + cam.y/16
    end

    bgsign:rmid()
    bgsign:rpal()
    return bgsign
end

function input()
    if btn(fire1) and (plr.coyoteframes > 0 or plr.y==16 or mapcollide(plr, down, 0)) then
        plr.coyoteframes = 0
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

    debugbox(x1,y1)
    debugbox(x2,y2)

    y1 = y1%3
    y2 = y2%3
    
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

function printc(text, x, y, color) --Identical to print(text, x, y, color), but horizontally centered on x rather than left-aligned and without a return value.
    local w = print(text, 0, 128)
    print(text, x-w/2, y, color)
end

function printr(text, x, y, color) --Identical to print(text, x, y, color), but horizontally right-aligned on x rather than left-aligned and without a return value.
    local w = print(text, 0, 128)
    print(text, x-w, y, color)
end

function debuginit()
	debugboxlist = {}
	debugpointlist = {}
    debugtextlist = {}
	function debugbox(x,y,c)
        if debug then
		    c = c or yellow
		    add(debugboxlist,{x*8,y*8,c})
        end
	end
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
0000000000444400222222226ccc6cc66ccc6cc65555555577776777676767670000000000000000000000000000000000000000000000000000000000000000
0000000000444400220202226cdd6cd66cdd6cd655aaaa5576666666666666660000000000000000000000000000000000000000000000000000000000000000
00700700074444702222222266666666666666665555555566555655656556660000000000000000000000000000000000000000000000000000000000000000
00077000766337662222222267c677c6b3bb3bb3b3bb3bb376566666666666660000000000000000000000000000000000000000000000000000000000000000
0007700076433466222222226cc6ccc63b3bbb3b3b3bbb3b66666666666667650000000000000000000000000000000000000000000000000000000000000000
0070070076633766878228786cd6cdd6344443433444434376676767676777660000000000000000000000000000000000000000000000000000000000000000
00000000555115559892298966666666443444344434443466666666666666650000000000000000000000000000000000000000000000000000000000000000
000000000001100029222292677c67c6444444444444444476565656555655550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56231231231231231231236500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
51666666666666666666661500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53666666666666666666662500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52666666666666666666663500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
51666666666666666666661500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53666666666666666666662500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52666666666666666666663500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
51666666666666666666661500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53666666666666666666662500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52666666666666666666663500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
51666666666666666666661500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56321321321321321321326500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0300000000000006070000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0405050505050505050505050505050400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
