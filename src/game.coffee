Array::remove = (value) ->
    i = 0
    while i < @length
        if @[i] == value
            @splice i, 1
        else
            ++i
    return @

$ ->
  canvas = null
  context = null
  ship = null
  bullets = []
  targets = []
  score = 0
  lives = 3

  init = ->
    canvas = $("#canvas")
    context = canvas.get(0).getContext("2d")
    respawn(invincible: false)
    setInterval(gameLoop, 17)
  
  respawn = (options) ->
    ship = {
      width: 20,
      height: 20,
      x: canvas.width() / 2,
      y: canvas.height() - 50,
      movementInterval: 10,
      firing: false,
      movingLeft: false,
      movingRight: false,
      respawning: false,
      opacity: 1,
      invincible: options.invincible || false,
    }

    if ship.invincible
      setTimeout (-> ship.invincible = false), 3000
      ship.opacity = 0.2
      ship.opacityInterval = setInterval increaseOpacity, 300
  
  increaseOpacity = ->
    ship.opacity += 0.08
    if ship.opacity >= 1
      ship.opacity = 1
      clearInterval ship.opacityInterval
      ship.opacityInterval = null

  gameLoop = ->
    # game logic
    updateBullets()
    updateTargets()
    updateShip(ship)
    generateTarget()

    # drawing loop
    clearCanvas()
    drawShip(ship)
    drawBullets(bullets)
    drawTargets(targets)
    drawStats()

  updateShip = (ship) ->
    if ship.expired
      lives -= 1
      ship.expired = false
      ship.respawning = true
      setTimeout (-> respawn(invincible: true)), 3000
    else if ship.respawning
      # do nothing
    else
      if ship.movingLeft
        ship.x -= ship.movementInterval if ship.x > 0
      if ship.movingRight
        ship.x += ship.movementInterval if (ship.x + ship.width) < canvas.width()
      if ship.firing
        myBullets = (bullet for bullet in bullets when !bullet.expired && bullet.owner == ship)
        if myBullets.length <= 4
          bullets.push { width: 2, height: 2, x: ship.x + ship.width / 2, y: ship.y - 1, velocity: -8, owner: ship }
  
  isAlive = (ship) ->
    !(ship.expired || ship.respawning)

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
        if bullet.y < ship.y + ship.height && bullet.y > ship.y && bullet.x < ship.x + ship.width && bullet.x > ship.x && isAlive(ship)
          ship.expired = true unless ship.invincible
          bullet.expired = true
    bullets = (bullet for bullet in bullets when !bullet.expired)

  generateTarget = ->
    if Math.random() < 0.01
      targetWidth = 30
      targets.push { width: targetWidth, height: 30, x: Math.random() * (canvas.width() - targetWidth), y: 30 }

  clearCanvas = ->
    context.clearRect(0, 0, canvas.width(), canvas.height())

  drawShip = (ship) ->
    if isAlive(ship)
      context = canvas.get(0).getContext("2d")
      context.globalAlpha = ship.opacity

      context.fillRect(ship.x, ship.y, ship.width, ship.height)
      context.fillRect(ship.x + ship.width / 2 - 1, ship.y - 4, 2, 4)

      context.globalAlpha = 1
    

  drawBullets = (bullets) ->
    for bullet in bullets
      canvas.get(0).getContext("2d").fillRect(bullet.x, bullet.y, bullet.width, bullet.height)

  drawTargets = (targets) ->
    for target in targets
      canvas.get(0).getContext("2d").fillRect(target.x, target.y, target.width, target.height)

  drawStats = ->
    $('#score').text(score)
    $('#lives').text(lives)

  handleKeys = (options) -> ->
    if event.which == $.ui.keyCode.LEFT
      ship.movingLeft = options.down
    if event.which == $.ui.keyCode.RIGHT
      ship.movingRight = options.down
    if event.which == $.ui.keyCode.SPACE
      ship.firing = options.down

  $(document).keydown(handleKeys(down: true))
  $(document).keyup(handleKeys(down: false))


  init()
