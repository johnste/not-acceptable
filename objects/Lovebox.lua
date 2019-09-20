Lovebox = Entity:extend()
local boximg

function Lovebox:new(area, x, y)
    Lovebox.super.new(self, area, x, y)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100
    self.w = 12

    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
    body:setObject(self)
    body:setMass(0.1)
    body:setAngularDamping(1)
    body:setLinearDamping(0.4)

    self.collider = body

    boximg = love.graphics.newImage("img/lovebox.png")
    self.explosion_underwater = love.audio.newSource("sfx/underwater-explosion.wav", "static")

    self.timer:after(
        0.4,
        function(f)
            xv, yv = self.collider:getLinearVelocity()

            if (love.math.random() > 0.3 and self.alive == false) then
                xv, yv = self.collider:getLinearVelocity()

                if (love.math.random() > 0.5) then
                    self.area:addEntity(
                        Bubble(self.area, self.x + math.cos(self.r) * self.w / 2, self.y - math.sin(self.r) * 24, xv)
                    )
                else
                    self.area:addEntity(Bubble(self.area, self.x - math.cos(self.r) * self.w / 2, self.y, xv))
                end
            end
            self.timer:after(0.2, f)
        end
    )
end

function Lovebox:update(dt)
    Lovebox.super.update(self, dt)

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    --self.collider:applyForce(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.r = self.collider:getAngle()

    if (self.y > 70) then
        if not self.exploding then
            self.exploding = true
            self.timer:after(
                2 + love.math.random() * 5,
                function()
                    self.reallyexploding = true
                    camera:shake(8, 1, 60)
                    self.area:addEntity(Fish(self.area, self.x, self.y))
                    self.area:addEntity(Fish(self.area, self.x, self.y + love.math.random() * 5))
                    self.area:addEntity(Fish(self.area, self.x, self.y + love.math.random() - 5))
                    self.area:addEntity(Fish(self.area, self.x, self.y + love.math.random() - 5))
                    self.area:addEntity(Fish(self.area, self.x, self.y + love.math.random() * 5))
                    self.explosion_underwater:play()

                    self.timer:after(
                        0.15,
                        function()
                            self.dead = true
                        end
                    )
                end
            )
        end
    end

    if (self.y > 35) then
        self.alive = false
    --self.explosion_underwater:play()
    end

    if (self.y < 0) then
        self.collider:applyForce(0, 1000 * dt)
    elseif (self.y > 0) then
        self.collider:applyForce(0, 100 * dt)
    end

    if (self.x < -2000 and self.alive) then
        self.alive = false
        camera:shake(9, 0.2, 42)
    end

    -- if self.collider:enter("Sub") then
    --     self.collider:applyLinearImpulse(0, 100)
    --     camera:shake(8, 0.7, 30)
    --     self.explosion:play()

    -- end
end

function Lovebox:draw()
    love.graphics.draw(boximg, self.x, self.y, self.r, 1, 1, boximg:getWidth() / 2, boximg:getHeight() / 2)

    if self.reallyexploding then
        love.graphics.circle("fill", self.x, self.y, 25)
    end
end
