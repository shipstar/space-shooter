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