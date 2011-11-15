class Ship
  constructor: (@canvas) ->
    @sprite = new Image()
    @sprite.src = "assets/galaga_ship.png"
    @lives = 3
    this.init()

  init: =>
    @width = 40
    @height = 40
    @x = @canvas.width() / 2
    @y = @canvas.height() - 50
    @movementInterval = 10
    @firing = false
    @firingSuperbomb = false
    @movingLeft = false
    @movingRight = false
    @respawning = false
    @invincible = false
    @opacity = 1
    @shield = 100
    @superbombs = 1

  isAlive: =>
    !(@expired || @respawning)

  respawn: =>
    this.init()
    @respawning = false
    @invincible = true

    @opacity = 0.2
    @opacityInterval = setInterval this.increaseOpacity, 300

  # TODO: Ties visual artifact to logical artifact. Is this acceptable?
  increaseOpacity: =>
    @opacity += 0.08
    if @opacity >= 1
      @opacity = 1
      @invincible = false
      clearInterval @opacityInterval
      @opacityInterval = null

  update: =>
    if this.isAlive()
      if @movingLeft
        @x -= @movementInterval if @x > 0
      if @movingRight
        @x += @movementInterval if (@x + @width) < @canvas.width()
      if @firing
        myBullets = (bullet for bullet in bullets when !bullet.expired && bullet.owner == this)
        if myBullets.length <= 4
          bullets.push { width: 2, height: 2, x: @x + @width / 2, y: @y - 1, velocity: -8, owner: this }
      if @firingSuperbomb
        @firingSuperbomb = false
        if @superbombs > 0
          bullets.push { superbomb: true, width: 60, height: 30, x: @x - 10 , y: @y - 30, velocity: -12, owner: this}
          @superbombs -= 1
    else if @expired
      @lives -= 1
      @expired = false
      @respawning = true
      setTimeout this.respawn, 3000

  draw: =>
    if this.isAlive()
      context.globalAlpha = @opacity
      context.drawImage(
        @sprite, @x, @y, @width, @height
      )
      if @shield > 0
        # outer circle
        context.globalAlpha = 1
        context.lineWidth = @shield/25
        context.beginPath()
        context.strokeStyle = "#aaaaff"
        context.arc(@x+@width/2, @y+@height/2, @width/2 + 5, 0, 2 * Math.PI, true)
        context.closePath()
        context.stroke()

      context.globalAlpha = 1

  handleKeys: (options) => =>
    switch event.which
      when $.ui.keyCode.LEFT
        @movingLeft = options.down
      when $.ui.keyCode.RIGHT
        @movingRight = options.down
      when $.ui.keyCode.SPACE
        @firing = options.down
      when 90 # z
        @firingSuperbomb = true
      when 75 # k
        if debug_mode
          console.log('manually killing ship')
          @expired = true