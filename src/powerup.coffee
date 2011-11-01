class Powerup
  @spawn: (canvas, type) ->
    color = if type == 'shield'
      "#aaaaff"
    else if type == 'superbomb'
      "#ffaaaa"

    new Powerup(canvas, type, color)

  constructor: (@canvas, @type, @color) ->
    powerupSize = 10
    @width = powerupSize
    @height = powerupSize
    @x = Math.random() * (canvas.width() - powerupSize)
    @y = 30
    @velocity = 2

  draw: () =>
    context.save()
    context.fillStyle = @color
    context.fillRect(@x, @y, @width, @height)
    context.restore()