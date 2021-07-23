pico-8 cartridge // http://www.pico-8.com
version 32
__lua__


left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

--Game Constants
xmin = 8
xmax = 112
ymax = 16
taglines = {"face the cruelty of gravity", "neither hope nor despair", "relax as you climb effortlessly"}

function _init()

    cartdata("undeemiss_neoworld")
    highscores = {}
    for i=0,2 do
        highscores[i] = dget(i)
    end

    initmenu()
end

function initmenu()
    menu = {hovering=1}
    menu.open = function()
        inmenu = true
        menu.hovering = 1
    end
    menu.draw = function()
        printc("select a gamemode", 64, 9, white)
        for i=0,2 do
            logodraw(i, 64, 104 - 40*i, i != menu.hovering)
        end
    end
    menu.update = function()
        if btnp(fire1) then
            if menu.hovering == 0 then
                inithell()
            elseif menu.hovering == 1 then
                initcity()
            elseif menu.hovering == 2 then
                initheaven()
            end
        elseif btnp(down) then
            menu.hovering = (menu.hovering - 1) % 3
        elseif btnp(up) then
            menu.hovering = (menu.hovering + 1) % 3
        end
    end
    menu.open()
end

function initneo() --Generic initialization code for all three modes
    score = 0
    maxscore = 0
    plummeting = 5

    plr = initplr()
    cam = initcam()
    bgsigns = {}
    for i=1,bgsigncount do
        add(bgsigns, initbgsign(signtype))
    end

    inmenu = false
end

function inithell() --Initializes the neohell gamemode
    bgsigncount = 0

    initneo()

    gamename = "neohell"
    gm = 0
    coyotemax = 0
    bgcolor = dark_purple

    plr.sprite=000
end

function initcity() --Initializes the neocity gamemode
    bgsigncount = 6
    signtype = 0
    mlist = {{"short", 1}, {"long text", 3}} --Text, number of mid-sections to use
    spallist = {{black, green, dark_gray, green}, {dark_purple, pink, dark_gray, pink}} --Main color, light color, [edge color], [text color]

    initneo()

    gamename = "neocity"
    gm = 1
    coyotemax = 2
    bgcolor = blue

    plr.sprite=001
    plr.fire = true
    plr.eyes = true
    plr.eyecolor = black
end

function initheaven() --Initializes the neocity gamemode
    bgsigncount = 3
    signtype = 1
    mlist = {{"soar", 1}, {"fly", 1}, {"leap", 1}, {"win", 1}, {"rise", 1}} --Text, number of mid-sections to use
    spallist = {{black, green, dark_gray, green}, {dark_purple, pink, dark_gray, pink}} --Main color, light color, [edge color], [text color]

    initneo()

    gamename = "neoheaven"
    gm = 2
    coyotemax = 4
    bgcolor = dark_blue

    plr.sprite=003
    plr.eyes = true
    plr.eyecolor = pink
end

function _update()
    if inmenu then
        menu.update()
    else
        input()
        plr.update()
        for bgsign in all(bgsigns) do
            bgsign:update()
        end
        maxscore = max(score, maxscore)
        if plummeting > 0 then
            if maxscore > score then
                plummeting -= 1
            else
                plummeting = 5
            end
        end
        cam:chase(plr, 0, -32768.0, 0, -88)
    end
end

function _draw()
    cls()
    if inmenu then
        menu.draw()
    else
        --BG Rendering
        rectfill(0,0,127,127,bgcolor)
        for bgsign in all(bgsigns) do
            bgsign:draw()
        end
    
        --Level Rendering
        for i=144,-24,-24 do
            map(16*gm, 0, 0, i-cam.y%24, 17, 3)
        end
        map(16*gm, 3, 0, 24-cam.y, 17, 4)
    
        plr.draw()
    
        --UI Rendering
        rectfill(0,120,128,128, black)
        if (plummeting == 0) scorecolor = red else scorecolor = white
        print("score:"..maxscore, 1, 122, scorecolor)
        printr(gamename, 128, 122, scorecolor)
    end
end

function logodraw(id, x, y, silhouette) --id: 0=hell, 1=city, 2=heaven; silhouette: false=filled, true=empty
    local lpal, lseq, offset, textclr
    if id==0 then
        lpal = {red, brown, orange}
        lseq = {54, 50, 55, 51, 50, 53, 53}
    elseif id==1 then
        lpal = {light_gray, dark_gray, white}
        lseq = {54, 50, 55, 49, 52, 56, 58}
    elseif id==2 then
        lpal = {indigo, dark_purple, light_gray}
        lseq = {54, 50, 55, 51, 50, 48, 57, 50, 54}
    end
    offset = (7*count(lseq)+1)/2

    if silhouette then
        palt(1, true)
        pal(2, light_gray)
        palt(3, true)
        textclr = light_gray
    else
        for i=1,3 do
            pal(i, lpal[i])
        end
        textclr = lpal[2]
    end

    for i=1,count(lseq) do
        spr(lseq[i], x - offset + (7*(i-1)), y)
    end
    printc(taglines[id+1], x, y+9, textclr)
    printc("hi-score:"..highscores[id], x, y+15, textclr)

    pal()
end

function initplr()
    plr={
		x=8,y=16,dx=0,dy=0,
		sprite, 
        fire=false, firesprite=002,
        eyes=false, eyecolor,
        dir=1, --0=left, 1=right
		w=8,h=8,
        coyoteframes=0
	}
    plr.draw = function()
        if plr.fire and (plr.coyoteframes != coyotemax and plr.dy < coyotemax) then
            spr(plr.firesprite, plr.x, plr.y + flr(1.5 - sgn(plr.dy)) - cam.y)
        end
        spr(plr.sprite, plr.x, plr.y - cam.y)
        if plr.eyes then
            pset(plr.x+2+plr.dir, plr.y+1 - cam.y, plr.eyecolor)
            pset(plr.x+4+plr.dir, plr.y+1 - cam.y, plr.eyecolor)
        end
        pal()
    end
    plr.update = function()
        if plummeting==0 then
            if plr.x >= 64 and plr.x < 88 then
                plr.dx += 2
            elseif plr.x >= 40 and plr.x<64 then
                plr.dx -= 2
            end
        end
        if plr.coyoteframes > 0 then
            plr.coyoteframes -= 1
        end
        plr.dy += 1
        plr.dx = min(max(plr.dx,-3),3)
        plr.dy = max(plr.dy,-8)
        local rx = plr.dx
        local ry = plr.dy

        if rx>0 then
            plr.dir = 1
        elseif rx<0 then
            plr.dir = 0
        end

        local idx = rx
        local dist
        while rx!=0 or ry!=0 do
            dist=0
            if rx > 0 then
                if plr.x % 8 == 0 then
                    if plr.x >= xmax or mapcollide(plr, right, 0) then
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
        if plummeting == 0 and plr.y==ymax then
            if maxscore > highscores[gm] then
                dset(gm, maxscore)
                highscores[gm] = maxscore
            end
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

function initbgsign(signmode) --0=Neon Sign, 1=Cloud
    bgsign = {
        x=rnd(128)-16, y=rnd(140)-18, dx= rnd(0.15)-0.075,
        cornersprite = 016 + signmode*3,
        mode = signmode
    }

    bgsign.rmid = function(self)
        local mid = flr(rnd(count(mlist))+1)
        self.msg=mlist[mid][1]
        self.w=mlist[mid][2]
    end

    bgsign.rpal = function(self)
        if self.mode==0 then
            self.t=flr(rnd(30))
            local pid = flr(rnd(count(spallist))+1)
            self.mcolor = spallist[pid][1]
            self.lcolor = spallist[pid][2]
            self.bcolor = spallist[pid][3] or dark_gray
            self.tcolor = spallist[pid][4] or black
        end
    end

    bgsign.draw = function(self)
        if self.mode == 0 then
            pal(light_gray, self.mcolor)
            pal(dark_blue, self.mcolor)
            pal(dark_purple, self.mcolor)
            pal(dark_green, self.mcolor)
            pal(brown, self.mcolor)
            pal(self.t\10+1, self.lcolor)
            pal(dark_gray, self.bcolor)
        end

        spr(self.cornersprite, self.x, self.y - cam.y/16, 1, 2)
        for i=1,self.w do
            spr(self.cornersprite+1, self.x + 8*i, self.y - cam.y/16, 1, 2)
        end
        spr(self.cornersprite+2, self.x + 8*(self.w + 1), self.y - cam.y/16, 1, 2)

        pal()
        printc(self.msg, self.x + 4*(2+self.w), self.y + 5 - cam.y/16, self.tcolor)
    end

    bgsign.update = function(self)
        if mode == 0 and self.t<39 then
            self.t+=1
        else
            self.t=0
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
        self:rpal()
    end

    bgsign:rmid()
    bgsign:rpal()
    return bgsign
end

function input()
    if btnp(fire2) and maxscore==0 then
        menu.open()
    else
        if btnp(fire1) and (plr.coyoteframes > 0 or plr.y==16 or mapcollide(plr, down, 0)) then
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
            if (fget(mget(i+gm*16,j%3), flag)) then
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

__gfx__
aaaaaaaa004444000000000000222200000000000000000000000000000000004955455444555554444444544455455499944949449944940000000000000000
a7799779004444000000000000222200000000000000000000000000000000004484884444888884498888894444444448884484484448490000000000000000
a7199179074444700000000000222200000000000000000000000000000000004484858944558589448585844944444498554858484448440000000000000000
977aa7797663376600000000000ee000000000000000000000000000000000004458848449495484948454844444888948844888489448450000000000000000
97744779764334660000000006777760000000000000000000000000000000004445545444444454445449548888988898544858484448450000000000000000
99999994766337668780087876667667000000000000000000000000000000004988888444888884498888849888844448444848488848880000000000000000
99111194555115559890098906766665000000000000000000000000000000004485555944558584445585844449444445444545455545550000000000000000
44444444000110000900009000565500000000000000000000000000000000009488888449445489498858894444449445454554555455450000000000000000
00000000000000000000000000000000000000000000000000000000000000006ccc6cc66ccc6cc6555555557777677767676767000000000000000000000000
05555555555555555555555000067767000007777676000000000000000000006cdd6cd66cdd6cd655aaaa557666666666666666000000000000000000000000
51234123412341234123412507767666767677666666700000000000000000006666666666666666555555556655565565655666000000000000000000000000
546666666666666666666635076766766667666766676700000000000000000067c677c6b3bb3bb3b3bb3bb37656666666666666000000000000000000000000
53666666666666666666664577666666666666666666666000000000000000006cc6ccc63b3bbb3b3b3bbb3b6666666666666765000000000000000000000000
52666666666666666666661566666667666666666666676000000000000000006cd6cdd634444343344443437667676767677766000000000000000000000000
51666666666666666666662576766666666766666666666000000000000000006666666644344434443444346666666666666665000000000000000000000000
5466666666666666666666357666676666666666676666650000000000000000677c67c644444444444444447656565655565555000000000000000000000000
5366666666666666666666456666666666666666666665660000000000000000722e2227372e227b3b3bb33b0b3bb33b3b3bb330000000000000000000000000
526666666666666666666615666666666666666666666665000000000000000072e22227bb7777bbbb33bbbbbb33bbbbbb33bbbb000000000000000000000000
516666666666666666666625766666666656666656666650000000000000000072e22227b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3000000000000000000000000
5466666666666666666666350656666666666566666665000000000000000000722e22273b3bbb3b3b3bbb3b3b3bbb3b3b3bbb3b000000000000000000000000
53666666666666666666664506666656666666666656600000000000000000007222e22734444343344443433444434334444343000000000000000000000000
521432143214321432143215006656665565556566665000000000000000000072222e2744344434443444344434443444344434000000000000000000000000
055555555555555555555550000666650000000055650000000000000000000072222e2744444444444444444444444444444445000000000000000000000000
00000000000000000000000000006550000000000000000000000000000000007222e22744444444444444440545445545545550000000000000000000000000
00222200002222000222222002200220022222200220000002200220002222000222222002200220022002200000000000000000000000000000000000000000
02313120023131202331331223322312233133122332000023322312023131202331331223322312233223120000000000000000000000000000000000000000
23122112231111122311111223122112231111122312000023112112231111122311111223122312231221120000000000000000000000000000000000000000
23122312231221122111222021111112022112202112000021111112231221120221122021122112021111200000000000000000000000000000000000000000
21113112211222222311112023111112022312202312222023111112211223120023120002122320002312000000000000000000000000000000000000000000
23111112231133122111222021122112231111122111111221121112231131120023120002113120002312000000000000000000000000000000000000000000
21122112021111202311111223122112231111122311111223122112021111200021120000211200002112000000000000000000000000000000000000000000
02200220002222000222222002200220022222200222222002200220002222000002200000022000000220000000000000000000000000000000000000000000
__gff__
0000000000000000000000000101000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
080000000000000c0d00000000000008180000000000001b1c00000000000018280000000000002b2c000000000000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0900000000000000000000000000000918000000000000000000000000000018280000000000000000000000000000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a18000000000000000000000000000018280000000000000000000000000000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b191a1a1a1a1a1a1a1a1a1a1a1a1a1a19292a2a2a2a2a2a2a2a2a2a2a2a2a2a290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
