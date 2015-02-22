{graphics: g} = love

class WaterParticle extends PixelParticle
  life: 0.4
  new: (...) =>
    super ...
    color = C.water

    color = pick_one C.water, C.water_light
    @r,@g,@b = unpack color
    @size = pick_one 2,3,4,5

    @vel = Vec2d 0, 20
    @accel = Vec2d 0, 40

  draw: =>
    g.push!

    g.translate @x, @y
    s = @fade_in!
    g.scale s, s
    g.translate -@x, -@y

    super!
    g.pop!


class WaterEmitter extends Emitter
  count: 20
  duration: 0.4
  new: (@box, ...) =>
    super ...

  make_particle: =>
    x = @box.x + love.math.random! * @box.w
    y = @box.y + love.math.random! * @box.h
    WaterParticle x, y - @box.h

  draw: (...) =>
    g.rectangle "line", @box\unpack!

    super ...



{ :WaterEmitter }
