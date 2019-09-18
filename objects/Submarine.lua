Submarine = Entity:extend()
local sub_body
local sub_wings
local sub_tower

function Submarine:new(area, x, y)
    Submarine.super.new(self, area, x, y)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 200
    self.reversev = 100
    self.a = 200
    self.w = 12
    self.lasty = 0

    -- self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider = self.area.world:newRectangleCollider(self.x - 16, self.y - 4, 32, 8)
    self.collider:setObject(self)
    self.collider:setAngularDamping(1)
    self.collider:setLinearDamping(0.1)
    self.collider:setCollisionClass("Sub")

    sub_body = love.graphics.newImage("img/sub-body.png")
    sub_wings = love.graphics.newImage("img/sub-wings.png")
    sub_tower = love.graphics.newImage("img/sub-tower.png")

    self.timer:after(
        0.4,
        function(f)
            xv, yv = self.collider:getLinearVelocity()

            if (love.math.random() * math.max(self.direction, 0) < 0.2 and Vector.len(xv, yv) > 10) then
                xv, yv = self.collider:getLinearVelocity()

                self.area:addEntity(
                    Bubble(self.area, self.x - math.cos(self.r) * self.w, self.y - math.sin(self.r) * self.w, xv)
                )
            end
            self.timer:after(0.1, f)
        end
    )
end

function Submarine:update(dt)
    Submarine.super.update(self, dt)
    camera:follow(self.x, self.y)

    self.r = self.collider:getAngle()

    if input:down("go right") then
        --self.r = self.r + self.rv * dt
        self.collider:applyTorque(15000 * dt)
    end

    if input:down("go left") then
        --self.r = self.r - self.rv * dt
        self.collider:applyTorque(-15000 * dt)
    end

    if input:down("turbo") then
        --self.r = self.r - self.rv * dt
        if (self.y < 0) then
            self.collider:applyForce(0, 500)
        end
    end

    if input:down("go down") then
        self.collider:applyForce(-self.reversev * math.cos(self.r), -self.reversev * math.sin(self.r))
    end

    if input:down("go up") then
        self.collider:applyForce(self.v * math.cos(self.r), self.v * math.sin(self.r))
    end

    local x, y = Vector.normalize(self.collider:getLinearVelocity())
    self.direction = Vector.dot(x, y, math.cos(self.r), math.sin(self.r))

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    if (self.lasty < 0 and self.y >= 0) then
        local vx, vy = self.collider:getLinearVelocity()

        local angle = self.collider:getAngle()

        local splash = math.abs(Vector.dot(math.cos(angle), math.sin(angle), 0, 1))

        self.collider:setLinearVelocity(vx, vy * splash)
    end

    self.lasty = self.y

    if (self.y < 0) then
        self.collider:applyForce(0, 30000 * dt)
    elseif (self.y > 0) then
        self.collider:applyForce(0, -100 * dt)
    end

    if (self.y > 1000) then
        self.collider:applyForce(0, -10000 * dt)
    end
end

function Submarine:draw()
    -- for k, v in pairs(image) do
    --     print(k, v)
    -- end

    love.graphics.draw(sub_body, self.x, self.y, self.r, 1, 1, sub_body:getWidth() / 2, sub_body:getHeight() / 2)
    love.graphics.draw(
        sub_wings,
        self.x,
        self.y,
        self.r,
        1,
        math.sin(self.r),
        sub_wings:getWidth() / 2,
        sub_wings:getHeight() / 2
    )
    love.graphics.draw(
        sub_tower,
        self.x,
        self.y,
        self.r,
        1,
        math.cos(self.r),
        sub_tower:getWidth() / 2,
        sub_tower:getHeight() / 2
    )

    --love.graphics.circle("line", self.x, self.y, self.w)
    --love.graphics.line(self.x, self.y, self.x + 2 * self.w * math.cos(self.r), self.y + 2 * self.w * math.sin(self.r))

    -- love.graphics.print("x:" .. math.round(self.x, 0.1), self.x, self.y + 30)
    -- love.graphics.print("y:" .. math.round(self.y, 0.1), self.x, self.y + 44)
end
