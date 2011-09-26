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

  init = ->
    canvas = $("#canvas")
    context = canvas.get(0).getContext("2d")
    ship = {
      width: 20,
      height: 20,
      x: canvas.width() / 2,
      y: canvas.height() - 50,
      movementInterval: 10,
      firing: false,
      movingLeft: false,
      movingRight: false,
    }
    setInterval(gameLoop, 17)

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
    drawScore()

  updateShip = (ship) ->
    if ship.movingLeft
      ship.x -= ship.movementInterval if ship.x > 0
    if ship.movingRight
      ship.x += ship.movementInterval if (ship.x + ship.width) < canvas.width()
    if ship.firing
      myBullets = (bullet for bullet in bullets when !bullet.expired && bullet.owner == ship)
      if myBullets.length <= 4
        bullets.push { width: 2, height: 2, x: ship.x + ship.width / 2, y: ship.y - 1, velocity: -8, owner: ship }

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
        if bullet.y < ship.y + ship.height && bullet.y > ship.y && bullet.x < ship.x + ship.width && bullet.x > ship.x
          ship.expired = true
    bullets = (bullet for bullet in bullets when !bullet.expired)

  generateTarget = ->
    if Math.random() < 0.01
      targetWidth = 30
      targets.push { width: targetWidth, height: 30, x: Math.random() * (canvas.width() - targetWidth), y: 30 }

  clearCanvas = ->
    context.clearRect(0, 0, canvas.width(), canvas.height())

  drawShip = (ship) ->
    unless ship.expired
      canvas.get(0).getContext("2d").fillRect(ship.x, ship.y, ship.width, ship.height)
      canvas.get(0).getContext("2d").fillRect(ship.x + ship.width / 2 - 1, ship.y - 4, 2, 4)

  drawBullets = (bullets) ->
    for bullet in bullets
      canvas.get(0).getContext("2d").fillRect(bullet.x, bullet.y, bullet.width, bullet.height)

  drawTargets = (targets) ->
    for target in targets
      canvas.get(0).getContext("2d").fillRect(target.x, target.y, target.width, target.height)

  drawScore = ->
    $('#score').text(score)

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
