$ ->
  canvas = null
  context = null
  ship = null

  clearCanvas = ->
    context.clearRect(0, 0, canvas.width(), canvas.height())

  drawShip = (ship) ->
    canvas.get(0).getContext("2d").fillRect(ship.x, ship.y, ship.width, ship.height)
    canvas.get(0).getContext("2d").fillRect(ship.x + ship.width / 2 - 1, ship.y - 4, 2, 4) 

  init = ->
    canvas = $("#canvas")
    context = canvas.get(0).getContext("2d")
    ship = { width: 20, height: 20, x: canvas.width() / 2, y: 550, movementInterval: 10 }
    setInterval(gameLoop, 17)
  
  gameLoop = ->
    clearCanvas()
    drawShip(ship)

  updateShip = (event) ->
    if event.which == $.ui.keyCode.LEFT
      ship.x -= ship.movementInterval
    else if event.which == $.ui.keyCode.RIGHT
      ship.x += ship.movementInterval

  $(document).keydown(updateShip)

  init()

  
  