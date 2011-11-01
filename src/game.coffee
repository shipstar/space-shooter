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
debug_mode = true

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
      console.log(event.which)
      if event.which == 112 # p
        setPaused(!paused)
      if event.which == 100 # d
        $('#stats').toggle()
      if event.which == 122 # z
        ship.firingSuperbomb = true
      if event.which == 107 && debug_mode
        console.log('manually killing ship')
        ship.expired = true
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

  updateBullets = ->
    for bullet in bullets
      bullet.y += bullet.velocity
      bullet.expired = true if bullet.y <= 0 || bullet.y > canvas.height()
      for target in targets
        if rectanglesIntersect bullet, target
          target.expired = true
          unless bullet.superbomb
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
  
  # updateBullets must run before this or the targets
  # won't get killed for an extra frame. Not the end of
  # the world, but annoying.
  updateTargets = ->
    target.update() for target in targets
    targets = (target for target in targets when !target.expired)

  updatePowerups = ->
    for powerup in powerups
      powerup.y += powerup.velocity
      if powerup.y > canvas.height()
        powerup.expired = true
      if rectanglesIntersect(powerup, ship) && ship.isAlive()
        powerup.expired = true
        if powerup.type == 'shield'
          ship.shield = 100
        if powerup.type == 'superbomb'
          ship.superbombs += 1

    powerups = (powerup for powerup in powerups when !powerup.expired)


  spawnTarget = ->
    if Math.random() < (0.01 * level) && targets.length < MAX_TARGETS
      targets.push(new Target(canvas))

  spawnPowerup = ->
    if Math.random() < 0.01
      powerups.push(Powerup.spawn(canvas, 'shield'))
    if Math.random() < 0.01
      powerups.push(Powerup.spawn(canvas, 'superbomb'))

  clearCanvas = ->
    context.clearRect(0, 0, canvas.width(), canvas.height())

  drawBullets = (bullets) ->
    for bullet in bullets
      context.fillStyle = "#ffffff"
      context.fillRect(bullet.x, bullet.y, bullet.width, bullet.height)
      context.fillStyle = "#000000"

  drawTargets = (targets) ->
    target.draw() for target in targets

  drawPowerups = (powerups) ->
    for powerup in powerups
      context.fillStyle = powerup.color
      context.fillRect(powerup.x, powerup.y, powerup.width, powerup.height)
      context.fillStyle = "#000000"

  drawStats = ->
    $('#score').text(score)
    $('#lives').text(ship.lives)
    $('#level').text(level)
    $('#bullet-count').text(bullets.length)
    $('#superbombs').text(ship.superbombs)

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
