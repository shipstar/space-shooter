class Target
  constructor: (@canvas) ->
    @sprite = new Image()
    @sprite.src = "assets/alien-" + (parseInt((Math.random() * 3).toFixed(0)) + 1) + ".png"
    this.init()

  init: =>
    targetWidth = 30
    targetX = Math.random() * (canvas.width() - targetWidth)
    targetSpeed = Math.random() * 4

    @width = targetWidth
    @height = 30
    @x = targetX
    @y = 30
    @velocity = if targetX < canvas.width()/2 then targetSpeed else -targetSpeed
    @rotationFrame = 0
    @rotationFactor = parseInt(Math.random()*10.toFixed(0)) + 1

  update: =>
    @x += @velocity
    @rotationFrame += @rotationFactor
    @rotationFactor *= -1 if Math.abs(@rotationFrame) > 64
    @velocity *= -1 if @x < 0 || @x + @width > canvas.width()

    if @expired
      score += 100
    if Math.random() < (0.01 * level)
      bullets.push {
        width: 4,
        height: 4,
        x: @x + @width / 2 - 2,
        y: @y + @height + 1,
        velocity: 4,
        owner: this
      }

  draw: =>
    context.save()
    context.translate(@x + @width/2, @y + @height/2)
    context.rotate((Math.PI/16) * @rotationFrame/64)
    context.translate(-(@x + @width/2), -(@y + @height/2))
    context.drawImage(@sprite, @x, @y, @width, @height)
    context.restore()