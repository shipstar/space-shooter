Array::remove = (value) ->
  i = 0
  while i < @length
    if @[i] == value
      @splice i, 1
    else
      ++i
  return @

canvas = null
context = null
ship = null
bullets = []
targets = []
score = 0

class Ship
  constructor: (@canvas) ->
    this.init()

  init: =>
    @width = 20
    @height = 20
    @x = @canvas.width() / 2
    @y = @canvas.height() - 50
    @movementInterval = 10
    @firing = false
    @movingLeft = false
    @movingRight = false
    @respawning = false
    @invincible = false
    @opacity = 1
    @lives = 3

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
    else if @expired
      @lives -= 1
      @expired = false
      @respawning = true
      setTimeout this.respawn, 3000

  draw: =>
    if this.isAlive()
      context.globalAlpha = @opacity
      context.fillRect(@x, @y, @width, @height)
      context.fillRect(@x + @width / 2 - 1, @y - 4, 2, 4)
      context.globalAlpha = 1
    
  handleKeys: (options) => =>
    switch event.which
      when $.ui.keyCode.LEFT
        @movingLeft = options.down
      when $.ui.keyCode.RIGHT
        @movingRight = options.down
      when $.ui.keyCode.SPACE
        @firing = options.down


$ ->
  init = ->
    canvas = $("#canvas")
    context = canvas.get(0).getContext("2d")
    ship = new Ship canvas
    $(document).keydown(ship.handleKeys(down: true))
    $(document).keyup(ship.handleKeys(down: false))
    setInterval(gameLoop, 17)

  gameLoop = ->
    # game logic
    updateBullets()
    updateTargets()
    ship.update()
    generateTarget()

    # drawing loop
    clearCanvas()
    ship.draw()
    drawBullets(bullets)
    drawTargets(targets)
    drawStats()

  updateTargets = ->
    for target in targets
      if target.expired
        score += 100
      if Math.random() < 0.01
        bullets.push { width: 4, height: 4, x: target.x + target.width / 2 - 2, y: target.y + target.height + 1, velocity: 4, owner: target }
    targets = (target for target in targets when !target.expired)

  updateBullets = ->
    for bullet in bullets
      bullet.y += bullet.velocity
      bullet.expired = true if bullet.y <= 0
      for target in targets
        if bullet.y < target.y + target.height && bullet.y > target.y && bullet.x < target.x + target.width && bullet.x > target.x
          target.expired = true
          bullet.expired = true
        if bullet.y < ship.y + ship.height && bullet.y > ship.y && bullet.x < ship.x + ship.width && bullet.x > ship.x && ship.isAlive()
          ship.expired = true unless ship.invincible
          bullet.expired = true
    bullets = (bullet for bullet in bullets when !bullet.expired)

  generateTarget = ->
    if Math.random() < 0.01
      targetWidth = 30
      targets.push { width: targetWidth, height: 30, x: Math.random() * (canvas.width() - targetWidth), y: 30 }

  clearCanvas = ->
    context.clearRect(0, 0, canvas.width(), canvas.height())

  drawBullets = (bullets) ->
    for bullet in bullets
      canvas.get(0).getContext("2d").fillRect(bullet.x, bullet.y, bullet.width, bullet.height)

  drawTargets = (targets) ->
    for target in targets
      canvas.get(0).getContext("2d").fillRect(target.x, target.y, target.width, target.height)

  drawStats = ->
    $('#score').text(score)
    $('#lives').text(ship.lives)

  init()
