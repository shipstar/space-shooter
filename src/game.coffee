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
  
  updateBullets = (bullets) ->
    for bullet in bullets
      bullet.y += bullet.velocity
    
    bullets = (bullet for bullet in bullets when bullet.y > 0)

  drawBullets = (bullets) ->
    for bullet in bullets
      canvas.get(0).getContext("2d").fillRect(bullet.x, bullet.y, bullet.width, bullet.height)

  init = ->
    canvas = $("#canvas")
    context = canvas.get(0).getContext("2d")
    ship = { width: 20, height: 20, x: canvas.width() / 2, y: 550, movementInterval: 10 }
    setInterval(gameLoop, 17)
  
  gameLoop = ->
    updateBullets(bullets)
    clearCanvas()
    drawShip(ship)
    drawBullets(bullets)

  updateShip = (event) ->
    if event.which == $.ui.keyCode.LEFT
      ship.x -= ship.movementInterval
    else if event.which == $.ui.keyCode.RIGHT
      ship.x += ship.movementInterval
    else if event.which == $.ui.keyCode.SPACE
      bullets.push { width: 2, height: 2, x: ship.x + ship.width / 2, y: ship.y - 1, velocity: -15 }

  $(document).keydown(updateShip)

  init()