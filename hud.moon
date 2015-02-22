
import
  VList
  HList
  Bin
  Label
  Group
  from require "lovekit.ui"

ordinal = (num) ->
  num = tonumber(num) % 10
  if num > 10 and num < 20
    return "th"

  switch num
    when 1
      "st"
    when 2
      "nd"
    when 3
      "rd"
    else
      "th"

class Hud
  time_speed: 15
  days_per_month: 31
  months: {"spring", "summer", "fall", "winter"}

  max_time: 60*23

  new: (@game) =>
    @time = 0
    @day = 0

    @viewport = Viewport scale: GAME_CONFIG.scale

    @clock = Label @\format_time
    @date = Label @\format_date

    @group = Group {
      Bin 0,0, @viewport.w, @viewport.h, @clock, 1, 1
      Bin 0,0, @viewport.w, @viewport.h, @date, 0, 1
    }

  format_date: =>
    month = @months[math.floor(@day / @days_per_month) % #@months + 1]
    day = (@day % @days_per_month) + 1

    "#{month} #{day}#{ordinal day}"

  format_time: =>
    t = math.floor @time
    minutes = t % 60
    hours = math.floor t / 60
    minutes = 15 * math.floor minutes / 15

    "#{"%.2d"\format hours}:#{"%.2d"\format minutes}"

  update: (dt) =>
    @time += dt * @time_speed
    if @time > @max_time
      @day += 1
      @time -= @max_time

    @group\update dt

  draw: =>
    @viewport\apply!
    
    COLOR\push 0,0,0, 150
    Box.draw @date
    Box.draw @clock
    COLOR\pop!

    @group\draw!
    @viewport\pop!

{ :Hud }
