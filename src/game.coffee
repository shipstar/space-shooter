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

  clearCanvas = ->
    context.clearRect(0, 0, canvas.width(), canvas.height())

  drawShip = (ship) ->
    canvas.get(0).getContext("2d").fillRect(ship.x, ship.y, ship.width, ship.height)
    canvas.get(0).getContext("2d").fillRect(ship.x + ship.width / 2 - 1, ship.y - 4, 2, 4)

  updateBullets = ->
    for bullet in bullets
      bullet.y += bullet.velocity
    bullets = (bullet for bullet in bullets when bullet.y > 0)

  drawBullets = (bullets) ->
    for bullet in bullets
      canvas.get(0).getContext("2d").fillRect(bullet.x, bullet.y, bullet.width, bullet.height)

  init = ->
    canvas = $("#canvas")
    context = canvas.get(0).getContext("2d")
    ship = { width: 20, height: 20, x: canvas.width() / 2, y: canvas.height() - 50, movementInterval: 10 }
    setInterval(gameLoop, 17)

  gameLoop = ->
    updateBullets()
    clearCanvas()
    drawShip(ship)
    drawBullets(bullets)
    if movingLeft
      ship.x -= ship.movementInterval if ship.x > 0
    if movingRight
      ship.x += ship.movementInterval if (ship.x + ship.width) < canvas.width()
    if firing
      bullets.push { width: 2, height: 2, x: ship.x + ship.width / 2, y: ship.y - 1, velocity: -15 } unless bullets.length > 4

  movingLeft = false
  movingRight = false
  firing = false

  updateShipDown = (event) ->
    if event.which == $.ui.keyCode.LEFT
      movingLeft = true
    if event.which == $.ui.keyCode.RIGHT
      movingRight = true
    if event.which == $.ui.keyCode.SPACE
      firing = true

  updateShipUp = (event) ->
    if event.which == $.ui.keyCode.LEFT
      movingLeft = false
    if event.which == $.ui.keyCode.RIGHT
      movingRight = false
    if event.which == $.ui.keyCode.SPACE
      firing = false

  $(document).keydown(updateShipDown)
  $(document).keyup(updateShipUp)

  init()
