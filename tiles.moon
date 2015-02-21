
{graphics: g} = love


class TileSheet

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

{ :TileGenerator, :GrassGenerator, :DirtGenerator,
  :WoodGenerator }
