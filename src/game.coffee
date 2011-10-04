canvas = null
context = null
ship = null
bullets = []
targets = []
score = 0
level = 1
paused = false

$ ->
  init = ->
    setPaused(false)
    canvas = $("#canvas")
    context = canvas.get(0).getContext("2d")
    ship = new Ship canvas
    $(document).keydown(ship.handleKeys(down: true))
    $(document).keyup(ship.handleKeys(down: false))
    $(document).keypress((event)->
      if event.which == 112
        setPaused(!paused)
    )
    setInterval(gameLoop, 17)
    setInterval(increaseLevel, 30000)

  gameLoop = ->
    unless paused
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

  increaseLevel = ->
    level += 1

  updateTargets = ->
    for target in targets
      target.x += target.velocity
      target.velocity *= -1 if target.x < 0 || target.x + target.width > canvas.width()

      if target.expired
        score += 100
      if Math.random() < (0.01 * level)
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
    if Math.random() < (0.01 * level)
      targetWidth = 30
      targetX = Math.random() * (canvas.width() - targetWidth)
      targetSpeed = Math.random() * 4 + 1

      targets.push {
        width: targetWidth,
        height: 30,
        x: targetX
        y: 30,
        velocity: if targetX < canvas.width()/2 then targetSpeed else -targetSpeed
      }

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
    $('#level').text(level)

  $(window).blur(->
    console.log('it blurred!')
    setPaused(true)
  )

  setPaused = (p) ->
    paused = p
    $('#paused').toggle(paused)

  init()
