canvas = null
context = null
ship = null
bullets = []
targets = []
powerups = []
score = 0
level = 1
paused = false
MAX_TARGETS = 30

startTime = new Date().getTime()
numFrames = 0

$ ->
  init = ->
    setPaused(false)
    canvas = $("canvas#game")
    context = canvas.get(0).getContext("2d")
    ship = new Ship canvas
    $(document).keydown(ship.handleKeys(down: true))
    $(document).keyup(ship.handleKeys(down: false))
    $(document).keypress((event)->
      if event.which == 112
        setPaused(!paused)
      else if event.which == 100
        $('#stats').toggle()
    )
    setInterval(gameLoop, 17)

  gameLoop = ->
    unless paused
      calcFPS()

      # game logic
      updateLevel()
      updateBullets()
      updateTargets()
      updatePowerups()
      ship.update()

      # create new entities
      spawnTarget()
      spawnPowerup()

      # drawing loop
      clearCanvas()
      ship.draw()
      drawBullets(bullets)
      drawTargets(targets)
      drawPowerups(powerups)
      drawStats()

  updateLevel = ->
    if score > (Math.pow(2, level-1) * 1000)
      level += 1

  updateTargets = ->
    for target in targets
      target.x += target.velocity
      target.rotationFrame += target.rotationFactor
      target.rotationFactor *= -1 if Math.abs(target.rotationFrame) > 64
      target.velocity *= -1 if target.x < 0 || target.x + target.width > canvas.width()

      if target.expired
        score += 100
      if Math.random() < (0.01 * level)
        bullets.push { width: 4, height: 4, x: target.x + target.width / 2 - 2, y: target.y + target.height + 1, velocity: 4, owner: target }
      
    targets = (target for target in targets when !target.expired)

  updateBullets = ->
    for bullet in bullets
      bullet.y += bullet.velocity
      bullet.expired = true if bullet.y <= 0 || bullet.y > canvas.height()
      for target in targets
        if rectanglesIntersect bullet, target
          target.expired = true
          bullet.expired = true
      if rectanglesIntersect(bullet, ship) && ship.isAlive()
        bullet.expired = true
        if ship.shield > 0
          ship.shield -= 5
          if ship.shield < 0
            ship.shield = 0
        else
          ship.expired = true unless ship.invincible
    bullets = (bullet for bullet in bullets when !bullet.expired)

  updatePowerups = ->
    for powerup in powerups
      powerup.y += powerup.velocity
      if powerup.y > canvas.height()
        powerup.expired = true
      if rectanglesIntersect(powerup, ship)
        powerup.expired = true
        if powerup.type == 'shield'
          ship.shield = 100

    powerups = (powerup for powerup in powerups when !powerup.expired)


  spawnTarget = ->
    if Math.random() < (0.01 * level) && targets.length < MAX_TARGETS
      targetWidth = 30
      targetX = Math.random() * (canvas.width() - targetWidth)
      targetSpeed = Math.random() * 4
      targetSprite = new Image()
      targetSprite.src = "assets/alien-" + (parseInt((Math.random() * 3).toFixed(0)) + 1) + ".png"

      targets.push {
        width: targetWidth,
        height: 30,
        x: targetX
        y: 30,
        velocity: if targetX < canvas.width()/2 then targetSpeed else -targetSpeed,
        sprite: targetSprite,
        rotationFrame: 0,
        rotationFactor: parseInt(Math.random()*10.toFixed(0)) + 1
      }

  spawnPowerup = ->
    powerupSize = 10
    if Math.random() < 0.01
      powerups.push {
        type: 'shield',
        width: powerupSize,
        height: powerupSize,
        x: Math.random() * (canvas.width() - powerupSize),
        y: 30,
        velocity: 2,
      }

  clearCanvas = ->
    context.clearRect(0, 0, canvas.width(), canvas.height())
  
  drawBullets = (bullets) ->
    for bullet in bullets
      context.fillStyle = "#ffffff"
      context.fillRect(bullet.x, bullet.y, bullet.width, bullet.height)
      context.fillStyle = "#000000"

  drawTargets = (targets) ->
    for target in targets
      context.save()
      context.translate(target.x+target.width/2, target.y+target.height/2)
      context.rotate((Math.PI/16)*target.rotationFrame/64)
      context.translate(-(target.x+target.width/2), -(target.y+target.height/2))
      context.drawImage(target.sprite, target.x, target.y, target.width, target.height)
      context.restore()

  drawPowerups = (powerups) ->
    for powerup in powerups
      context.fillStyle = "#aaaaff"
      context.fillRect(powerup.x, powerup.y, powerup.width, powerup.height)
      context.fillStyle = "#000000"

  drawStats = ->
    $('#score').text(score)
    $('#lives').text(ship.lives)
    $('#level').text(level)
    $('#bullet-count').text(bullets.length)

  $(window).blur ->
    setPaused(true)

  setPaused = (p) ->
    paused = p
    $('#paused').toggle(paused)
    $('#overlay').toggle(paused)
    if paused
      $('#bgm').get(0).pause()
    else
      $('#bgm').get(0).play()
  
  calcFPS = ->
    if numFrames == 30
      endTime = new Date().getTime()
      secondsElapsed = (endTime - startTime) / 1000.0

      $('#fps').text((30/secondsElapsed).toFixed(2))

      numFrames = 0
      startTime = endTime
    else
      numFrames++

  init()
