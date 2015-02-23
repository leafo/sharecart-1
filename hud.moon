
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
    @setup_time!
    @setup_name!
    @setup_age!

    @day = 0

    @viewport = Viewport scale: GAME_CONFIG.scale

    @clock = Label @\format_time
    @date = Label @\format_date
    @holding = Label @\format_item
    @name = Label @\format_name

    @group = Group {
      Bin 0,0, @viewport.w, @viewport.h, @clock, 1, 1
      Bin 0,0, @viewport.w, @viewport.h, @date, 0, 1
      Bin 0,0, @viewport.w, @viewport.h, @holding, 1, 0
      Bin 0,0, @viewport.w, @viewport.h, @name, 0, 0
    }


    @seq = Sequence ->
      wait 5
      SHARECART.Misc3 = @day % 60000
      SHARECART.MapX = @time % 1000
      SHARECART.MapY = @_age % 1000

      again!


  setup_day: =>
    day = SHARECART.Misc3
    unless day
      day = love.math.random 0, 1023
      SHARECART.Misc3 = day

    @day = day

  setup_time: =>
    time = SHARECART.MapX
    unless time
      time = love.math.random 0, 1023
      SHARECART.MapX = time

    @time = time % @max_time

  setup_name: =>
    name = SHARECART.PlayerName
    unless name
      name = "Farmer"
      SHARECART.PlayerName = name

    @_name = name

  setup_age: =>
    age = SHARECART.MapY
    unless age
      age = love.math.random 18, 36
      SHARECART.MapY = age

    @_age = age

  format_name: =>
    "#{@_name\lower!} - age: #{@_age}"

  format_date: =>
    month = @months[math.floor(@day / @days_per_month) % #@months + 1]
    day = (@day % @days_per_month) + 1

    "#{month} #{day}#{ordinal day}"

  format_item: =>
    return "" unless @game.player
    item = @game.player.holding
    return "" unless item
    "holding: #{item.name}"

  hours_minutes: =>
    t = math.floor @time
    minutes = t % 60
    hours = math.floor t / 60
    hours, minutes

  format_time: =>
    hours, minutes = @hours_minutes!
    minutes = 15 * math.floor minutes / 15

    "#{"%.2d"\format hours}:#{"%.2d"\format minutes}"

  night_progress: =>
    total_minutes = 60 * 24
    minutes = @time % total_minutes
    start = 20 * 60 -- 20th hour
    len = 9 * 60 -- 9 hours

    minutes -= start
    if minutes < 0
      minutes += total_minutes

    return 0 if minutes > len
    minutes / len

  night_darkness: =>
    p = @night_progress!
    if p < 0.1
      lerp 0, 1, p/0.1
    elseif p > 0.9
      lerp 1, 0, (p - 0.9) / 0.1
    else
      1

  update: (dt) =>
    @time += dt * @time_speed
    if @time > @max_time
      @day += 1
      @time -= @max_time

    @group\update dt
    @seq\update dt

  draw: =>
    @viewport\apply!

    COLOR\push 0,0,0, 150
    Box.draw @date
    Box.draw @clock
    Box.draw @holding
    Box.draw @name
    COLOR\pop!

    @group\draw!
    @viewport\pop!

{ :Hud }
