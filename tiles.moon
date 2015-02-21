
{graphics: g} = love

class TileGenerator extends Box
  w: 16
  h: 16

  x: 0
  y: 0

  new: (@seed) =>
    @render!

  draw: =>
    @outline!
    g.draw @canvas, @x, @y if @canvas

  render: =>
    unless @canvas
      @canvas = g.newCanvas @w, @h
      @canvas\setFilter "nearest", "nearest"

      g.setCanvas @canvas
      @render_tile!
      g.setCanvas!

  render_tile: =>

  update: (dt) =>
    true

class GrassGenerator extends TileGenerator
  render_tile: =>
    @rng = love.math.newRandomGenerator @seed + 777
    Box.draw @, C.grass

    for color in *{C.grass_dark, C.grass_light}
      for i=1,20
        x = @rng\random 0, 15
        y = @rng\random 0, 15
        w = @rng\random 1, 2
        h = @rng\random 2, 4
        Box(x,y,w,h)\draw color


class DirtGenerator extends TileGenerator
  render_tile: =>
    @rng = love.math.newRandomGenerator @seed
    Box.draw @, C.dirt

    COLOR\push C.dirt_dark

    g.setPointSize 1
    for i=1,3
      x = @rng\random 0, 15
      y = @rng\random 0, 15
      g.point x,y

    g.setPointSize 2
    for i=1,3
      x = @rng\random 0, 15
      y = @rng\random 0, 15
      g.point x,y


    g.setPointSize 3
    for i=1,3
      x = @rng\random 0, 15
      y = @rng\random 0, 15
      g.point x,y

    COLOR\pop!


class WoodGenerator extends TileGenerator
  render_tile: =>
    @rng = love.math.newRandomGenerator @seed
    Box.draw @, C.wood

    for color in *{C.wood_dark, C.wood_light}
      for i=1,3
        y = @rng\random 0, 15
        Box(0,y,16,2)\draw color

class FloorGenerator extends TileGenerator
  render_tile: =>
    @rng = love.math.newRandomGenerator @seed
    Box.draw @, C.floor

    g.setPointSize 2

    COLOR\push C.floor_light

    ox = @rng\random 1,4
    oy = @rng\random 1,4
    dt = @rng\random 3,5

    g.push!
    g.translate ox, oy


    g.translate @w/2, @h/2
    g.rotate @rng\random!
    g.translate -@w/2, -@h/2

    for y=0,4
      for x=0,4
        g.point x*dt, y*dt

    g.pop!

    COLOR\pop!


class RoofGenerator extends TileGenerator


class TopGenerator extends TileGenerator
  render_tile: =>
    @rng = love.math.newRandomGenerator @seed + 263
    Box.draw @, C.top

    COLOR\push C.top_light
    g.rectangle "line", 0,0, @w, @h
    COLOR\pop!


class TileSheet
  w: 7

  new: =>
    {:w, :h} = TileGenerator

    rows = {
      [GrassGenerator i for i=2,1+@w]
      [DirtGenerator i for i=2,1+@w]
      [WoodGenerator i for i=2,1+@w]
      [FloorGenerator i for i=2,1+@w]
      [TopGenerator i for i=2,1+@w]
    }

    @h = #rows
    @canvas = g.newCanvas w * @w, h * @h
    @canvas\setFilter "nearest", "nearest"

    g.setCanvas @canvas
    for y, row in ipairs rows
      for x, gen in ipairs row
        g.draw gen.canvas, (x - 1) * w, (y - 1) * h

    g.setCanvas!

  spriter: =>
    Spriter Image\from_tex(@canvas),
      TileGenerator.w, TileGenerator.h

{ :TileGenerator, :GrassGenerator, :DirtGenerator,
  :WoodGenerator, :TileSheet }
