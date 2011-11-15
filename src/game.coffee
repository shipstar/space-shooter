canvas = null
context = null
ship = null
bullets = []
targets = []
powerups = []
particleSystems = []
score = 0
level = 1
paused = false
millisecondsPerFrame = 17
MAX_TARGETS = 30
debug_mode = true

startTime = new Date().getTime()
numFrames = 0

backgroundImage
bgY = 0
bgY2 = -600
bgSpeed = 1
backgroundImage = new Image();
backgroundImage.src = 'assets/background.jpg';

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
      if event.which == 107 && debug_mode # k
        console.log('manually killing ship')
        ship.expired = true
      if event.which == 109 # m
        console.log("spawning particle system")
    )
    setInterval(gameLoop, millisecondsPerFrame)

  gameLoop = ->
    unless paused
      calcFPS()

      # game logic
      updateLevel()
      updateBullets()
      updateTargets()
      updatePowerups()
      updateParticleSystems()
      ship.update()

      # create new entities
      spawnTarget()
      spawnPowerup()

      # drawing loop
      clearCanvas()
      drawScrollingBackground()
      ship.draw()
      drawBullets(bullets)
      drawParticleSystems(particleSystems)
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

          particles = []
          ttl = 200 * Math.random() + 200
          for i in [0..9]
            for j in [0..9]
              particles.push(
                velocity: { x: Math.random() * 2 - 1, y: Math.random() * 2 - 2 },
                position: { x: target.x + i * 3, y: target.y + j * 3 },
                width: 3,
                height: 3,
                timeToLive: ttl,
                originalTimeToLive: ttl,
                expired: false,
              )
          particleSystems.push(
            expired: false,
            particles: particles,
          )
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

  updateParticleSystems = ->
    for particleSystem in particleSystems
      particleSystemCompletelyDead = true
      for particle in particleSystem.particles
        unless particle.expired
          particle.timeToLive -= millisecondsPerFrame
          if particle.timeToLive <= 0
            particle.expired = true
          else
            particleSystemCompletelyDead = false
            particle.position.x += particle.velocity.x
            particle.position.y += particle.velocity.y
      if particleSystemCompletelyDead
        particleSystem.expired = true
    particleSystems = (particleSystem for particleSystem in particleSystems when !particleSystem.expired)

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
    powerup.draw() for powerup in powerups

  drawParticleSystems = (particleSystems) ->
    for particleSystem in particleSystems
      for particle in particleSystem.particles
        unless particle.expired
          context.globalAlpha = particle.timeToLive / particle.originalTimeToLive
          context.fillStyle = "#993333"
          context.fillRect(particle.position.x, particle.position.y, particle.width, particle.height)
          context.fillStyle = "#000000"
          context.globalAlpha = 1.0

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

  drawScrollingBackground = ->
    context.drawImage(backgroundImage,0,bgY)
    context.drawImage(backgroundImage,0,bgY2)
    if bgY > 600
      bgY = -600 + bgSpeed
    if bgY2 > 600
      bgY2 = -600 + bgSpeed
    bgY += bgSpeed
    bgY2 += bgSpeed

  init()
