(function() {
  var MAX_TARGETS, Powerup, Ship, Target, backgroundImage, bgSpeed, bgX, bgX2, bgY, bgY2, bullets, canvas, context, debug_mode, gameOver, level, millisecondsPerFrame, numFrames, particleSystems, paused, powerups, rectanglesIntersect, score, ship, startTime, targets;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  canvas = null;
  context = null;
  ship = null;
  bullets = [];
  targets = [];
  powerups = [];
  particleSystems = [];
  score = 0;
  level = 1;
  paused = false;
  gameOver = false;
  millisecondsPerFrame = 17;
  MAX_TARGETS = 30;
  debug_mode = true;
  startTime = new Date().getTime();
  numFrames = 0;
  backgroundImage = new Image();
  backgroundImage.src = 'assets/background.png';
  bgX = 0;
  bgY = 0;
  bgX2 = 0;
  bgY2 = -backgroundImage.height;
  bgSpeed = 1;
  $(function() {
    var calcFPS, clearCanvas, createParticleSystem, drawBullets, drawParticleSystems, drawPowerups, drawScrollingBackground, drawStats, drawTargets, gameLoop, init, resetBackground, setPaused, spawnPowerup, spawnTarget, updateBullets, updateLevel, updateParticleSystems, updatePowerups, updateTargets;
    init = function() {
      setPaused(false);
      canvas = $("canvas#game");
      context = canvas.get(0).getContext("2d");
      ship = new Ship(canvas);
      $(document).keydown(ship.handleKeys({
        down: true
      }));
      $(document).keyup(ship.handleKeys({
        down: false
      }));
      $(document).keypress(function(event) {
        console.log(event.which);
        if (event.which === 112) {
          setPaused(!paused);
        }
        if (event.which === 100) {
          $('#stats').toggle();
        }
        if (event.which === 109) {
          return console.log("spawning particle system");
        }
      });
      return setInterval(gameLoop, millisecondsPerFrame);
    };
    gameLoop = function() {
      if (!paused) {
        calcFPS();
        updateLevel();
        updateBullets();
        updateTargets();
        updatePowerups();
        updateParticleSystems();
        ship.update();
        spawnTarget();
        spawnPowerup();
        clearCanvas();
        drawScrollingBackground();
        ship.draw();
        drawBullets(bullets);
        drawParticleSystems(particleSystems);
        drawTargets(targets);
        drawPowerups(powerups);
        return drawStats();
      }
    };
    updateLevel = function() {
      if (score > (Math.pow(2, level - 1) * 1000)) {
        return level += 1;
      }
    };
    createParticleSystem = function(systemX, systemY, color, ySpeed) {
      var i, j, particles, ttl;
      particles = [];
      ttl = 200 * Math.random() + 200;
      for (i = 0; i <= 9; i++) {
        for (j = 0; j <= 9; j++) {
          particles.push({
            velocity: {
              x: Math.random() * 2 - 1,
              y: Math.random() * 2 + ySpeed
            },
            position: {
              x: systemX + i * 3,
              y: systemY + j * 3
            },
            width: 3,
            height: 3,
            timeToLive: ttl,
            originalTimeToLive: ttl,
            expired: false
          });
        }
      }
      return particleSystems.push({
        expired: false,
        particles: particles,
        color: color
      });
    };
    updateBullets = function() {
      var bullet, target, _i, _j, _len, _len2;
      for (_i = 0, _len = bullets.length; _i < _len; _i++) {
        bullet = bullets[_i];
        bullet.y += bullet.velocity;
        if (bullet.y <= 0 || bullet.y > canvas.height()) {
          bullet.expired = true;
        }
        for (_j = 0, _len2 = targets.length; _j < _len2; _j++) {
          target = targets[_j];
          if (rectanglesIntersect(bullet, target)) {
            target.expired = true;
            createParticleSystem(target.x, target.y, "#993333", -2);
            if (!bullet.superbomb) {
              bullet.expired = true;
            }
          }
        }
        if (rectanglesIntersect(bullet, ship) && ship.isAlive()) {
          bullet.expired = true;
          if (ship.shield > 0) {
            ship.shield -= 5;
            if (ship.shield < 0) {
              ship.shield = 0;
            }
          } else {
            if (!ship.invincible) {
              ship.expired = true;
              createParticleSystem(ship.x, ship.y, "#FFFFFF", 2);
            }
          }
        }
      }
      return bullets = (function() {
        var _k, _len3, _results;
        _results = [];
        for (_k = 0, _len3 = bullets.length; _k < _len3; _k++) {
          bullet = bullets[_k];
          if (!bullet.expired) {
            _results.push(bullet);
          }
        }
        return _results;
      })();
    };
    updateTargets = function() {
      var target, _i, _len;
      for (_i = 0, _len = targets.length; _i < _len; _i++) {
        target = targets[_i];
        target.update();
      }
      return targets = (function() {
        var _j, _len2, _results;
        _results = [];
        for (_j = 0, _len2 = targets.length; _j < _len2; _j++) {
          target = targets[_j];
          if (!target.expired) {
            _results.push(target);
          }
        }
        return _results;
      })();
    };
    updatePowerups = function() {
      var powerup, _i, _len;
      for (_i = 0, _len = powerups.length; _i < _len; _i++) {
        powerup = powerups[_i];
        powerup.y += powerup.velocity;
        if (powerup.y > canvas.height()) {
          powerup.expired = true;
        }
        if (rectanglesIntersect(powerup, ship) && ship.isAlive()) {
          powerup.expired = true;
          if (powerup.type === 'shield') {
            ship.shield = 100;
          }
          if (powerup.type === 'superbomb') {
            ship.superbombs += 1;
          }
        }
      }
      return powerups = (function() {
        var _j, _len2, _results;
        _results = [];
        for (_j = 0, _len2 = powerups.length; _j < _len2; _j++) {
          powerup = powerups[_j];
          if (!powerup.expired) {
            _results.push(powerup);
          }
        }
        return _results;
      })();
    };
    updateParticleSystems = function() {
      var particle, particleSystem, particleSystemCompletelyDead, _i, _j, _len, _len2, _ref;
      for (_i = 0, _len = particleSystems.length; _i < _len; _i++) {
        particleSystem = particleSystems[_i];
        particleSystemCompletelyDead = true;
        _ref = particleSystem.particles;
        for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
          particle = _ref[_j];
          if (!particle.expired) {
            particle.timeToLive -= millisecondsPerFrame;
            if (particle.timeToLive <= 0) {
              particle.expired = true;
            } else {
              particleSystemCompletelyDead = false;
              particle.position.x += particle.velocity.x;
              particle.position.y += particle.velocity.y;
            }
          }
        }
        if (particleSystemCompletelyDead) {
          particleSystem.expired = true;
        }
      }
      return particleSystems = (function() {
        var _k, _len3, _results;
        _results = [];
        for (_k = 0, _len3 = particleSystems.length; _k < _len3; _k++) {
          particleSystem = particleSystems[_k];
          if (!particleSystem.expired) {
            _results.push(particleSystem);
          }
        }
        return _results;
      })();
    };
    spawnTarget = function() {
      if (Math.random() < (0.01 * level) && targets.length < MAX_TARGETS && !gameOver) {
        return targets.push(new Target(canvas));
      }
    };
    spawnPowerup = function() {
      if (Math.random() < 0.01) {
        powerups.push(Powerup.spawn(canvas, 'shield'));
      }
      if (Math.random() < 0.01) {
        return powerups.push(Powerup.spawn(canvas, 'superbomb'));
      }
    };
    clearCanvas = function() {
      return context.clearRect(0, 0, canvas.width(), canvas.height());
    };
    drawBullets = function(bullets) {
      var bullet, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = bullets.length; _i < _len; _i++) {
        bullet = bullets[_i];
        context.fillStyle = "#ffffff";
        context.fillRect(bullet.x, bullet.y, bullet.width, bullet.height);
        _results.push(context.fillStyle = "#000000");
      }
      return _results;
    };
    drawTargets = function(targets) {
      var target, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = targets.length; _i < _len; _i++) {
        target = targets[_i];
        _results.push(target.draw());
      }
      return _results;
    };
    drawPowerups = function(powerups) {
      var powerup, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = powerups.length; _i < _len; _i++) {
        powerup = powerups[_i];
        _results.push(powerup.draw());
      }
      return _results;
    };
    drawParticleSystems = function(particleSystems) {
      var particle, particleSystem, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = particleSystems.length; _i < _len; _i++) {
        particleSystem = particleSystems[_i];
        _results.push((function() {
          var _j, _len2, _ref, _results2;
          _ref = particleSystem.particles;
          _results2 = [];
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            particle = _ref[_j];
            _results2.push(!particle.expired ? (context.globalAlpha = particle.timeToLive / particle.originalTimeToLive, context.fillStyle = particleSystem.color, context.fillRect(particle.position.x, particle.position.y, particle.width, particle.height), context.fillStyle = "#000000", context.globalAlpha = 1.0) : void 0);
          }
          return _results2;
        })());
      }
      return _results;
    };
    drawStats = function() {
      $('#score').text(score);
      $('#lives').text(ship.lives);
      $('#level').text(level);
      $('#bullet-count').text(bullets.length);
      return $('#superbombs').text(ship.superbombs);
    };
    $(window).blur(function() {
      return setPaused(true);
    });
    setPaused = function(p) {
      paused = p;
      $('#paused').toggle(paused);
      $('#overlay').toggle(paused);
      if (paused) {
        return $('#bgm').get(0).pause();
      } else {
        return $('#bgm').get(0).play();
      }
    };
    calcFPS = function() {
      var endTime, secondsElapsed;
      if (numFrames === 30) {
        endTime = new Date().getTime();
        secondsElapsed = (endTime - startTime) / 1000.0;
        $('#fps').text((30 / secondsElapsed).toFixed(2));
        numFrames = 0;
        return startTime = endTime;
      } else {
        return numFrames++;
      }
    };
    drawScrollingBackground = function() {
      var _ref, _ref2;
      context.drawImage(backgroundImage, bgX, bgY);
      context.drawImage(backgroundImage, bgX2, bgY2);
      if (bgY > backgroundImage.height) {
        _ref = resetBackground(bgX, bgY), bgX = _ref[0], bgY = _ref[1];
      }
      if (bgY2 > backgroundImage.height) {
        _ref2 = resetBackground(bgX2, bgY2), bgX2 = _ref2[0], bgY2 = _ref2[1];
      }
      bgY += bgSpeed;
      return bgY2 += bgSpeed;
    };
    resetBackground = function(x, y) {
      var _i, _ref, _results;
      return [
        (function() {
          _results = [];
          for (var _i = _ref = -backgroundImage.width + canvas.width(); _ref <= 0 ? _i <= 0 : _i >= 0; _ref <= 0 ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this).random(), -backgroundImage.height
      ];
    };
    return init();
  });
  Powerup = (function() {
    Powerup.spawn = function(canvas, type) {
      var color;
      color = type === 'shield' ? "#aaaaff" : type === 'superbomb' ? "#ffaaaa" : void 0;
      return new Powerup(canvas, type, color);
    };
    function Powerup(canvas, type, color) {
      var powerupSize;
      this.canvas = canvas;
      this.type = type;
      this.color = color;
      this.draw = __bind(this.draw, this);
      powerupSize = 10;
      this.width = powerupSize;
      this.height = powerupSize;
      this.x = Math.random() * (canvas.width() - powerupSize);
      this.y = 30;
      this.velocity = 2;
    }
    Powerup.prototype.draw = function() {
      context.save();
      context.fillStyle = this.color;
      context.fillRect(this.x, this.y, this.width, this.height);
      return context.restore();
    };
    return Powerup;
  })();
  Ship = (function() {
    function Ship(canvas) {
      this.canvas = canvas;
      this.handleKeys = __bind(this.handleKeys, this);
      this.draw = __bind(this.draw, this);
      this.update = __bind(this.update, this);
      this.gameOver = __bind(this.gameOver, this);
      this.increaseOpacity = __bind(this.increaseOpacity, this);
      this.respawn = __bind(this.respawn, this);
      this.isAlive = __bind(this.isAlive, this);
      this.init = __bind(this.init, this);
      this.sprite = new Image();
      this.sprite.src = "assets/galaga_ship.png";
      this.lives = 3;
      this.init();
    }
    Ship.prototype.init = function() {
      this.width = 40;
      this.height = 40;
      this.x = this.canvas.width() / 2;
      this.y = this.canvas.height() - 50;
      this.movementInterval = 10;
      this.firing = false;
      this.firingSuperbomb = false;
      this.movingLeft = false;
      this.movingRight = false;
      this.respawning = false;
      this.invincible = false;
      this.opacity = 1;
      this.shield = 100;
      return this.superbombs = 1;
    };
    Ship.prototype.isAlive = function() {
      return !(this.expired || this.respawning);
    };
    Ship.prototype.respawn = function() {
      this.init();
      this.respawning = false;
      this.invincible = true;
      this.opacity = 0.2;
      return this.opacityInterval = setInterval(this.increaseOpacity, 300);
    };
    Ship.prototype.increaseOpacity = function() {
      this.opacity += 0.08;
      if (this.opacity >= 1) {
        this.opacity = 1;
        this.invincible = false;
        clearInterval(this.opacityInterval);
        return this.opacityInterval = null;
      }
    };
    Ship.prototype.gameOver = function() {
      gameOver = true;
      $('#gameover').show();
      return $('#overlay').show();
    };
    Ship.prototype.update = function() {
      var bullet, myBullets;
      if (this.isAlive()) {
        if (this.movingLeft) {
          if (this.x > 0) {
            this.x -= this.movementInterval;
          }
        }
        if (this.movingRight) {
          if ((this.x + this.width) < this.canvas.width()) {
            this.x += this.movementInterval;
          }
        }
        if (this.firing) {
          myBullets = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = bullets.length; _i < _len; _i++) {
              bullet = bullets[_i];
              if (!bullet.expired && bullet.owner === this) {
                _results.push(bullet);
              }
            }
            return _results;
          }).call(this);
          if (myBullets.length <= 4) {
            bullets.push({
              width: 2,
              height: 2,
              x: this.x + this.width / 2,
              y: this.y - 1,
              velocity: -8,
              owner: this
            });
          }
        }
        if (this.firingSuperbomb) {
          this.firingSuperbomb = false;
          if (this.superbombs > 0) {
            bullets.push({
              superbomb: true,
              width: 60,
              height: 30,
              x: this.x - 10,
              y: this.y - 30,
              velocity: -12,
              owner: this
            });
            return this.superbombs -= 1;
          }
        }
      } else if (this.expired && !gameOver) {
        this.lives -= 1;
        if (this.lives < 0) {
          this.gameOver();
        }
        this.expired = false;
        this.respawning = true;
        return setTimeout(this.respawn, 3000);
      }
    };
    Ship.prototype.draw = function() {
      if (this.lives >= 0 && this.isAlive()) {
        context.globalAlpha = this.opacity;
        context.drawImage(this.sprite, this.x, this.y, this.width, this.height);
        if (this.shield > 0) {
          context.globalAlpha = 1;
          context.lineWidth = this.shield / 25;
          context.beginPath();
          context.strokeStyle = "#aaaaff";
          context.arc(this.x + this.width / 2, this.y + this.height / 2, this.width / 2 + 5, 0, 2 * Math.PI, true);
          context.closePath();
          context.stroke();
        }
        return context.globalAlpha = 1;
      }
    };
    Ship.prototype.handleKeys = function(options) {
      return __bind(function(event) {
        switch (event.which) {
          case $.ui.keyCode.LEFT:
            return this.movingLeft = options.down;
          case $.ui.keyCode.RIGHT:
            return this.movingRight = options.down;
          case $.ui.keyCode.SPACE:
            return this.firing = options.down;
          case 90:
            return this.firingSuperbomb = true;
          case 75:
            if (debug_mode) {
              console.log('manually killing ship');
              return this.expired = true;
            }
        }
      }, this);
    };
    return Ship;
  })();
  Target = (function() {
    function Target(canvas) {
      this.canvas = canvas;
      this.draw = __bind(this.draw, this);
      this.update = __bind(this.update, this);
      this.init = __bind(this.init, this);
      this.sprite = new Image();
      this.sprite.src = "assets/alien-" + (parseInt((Math.random() * 3).toFixed(0)) + 1) + ".png";
      this.init();
    }
    Target.prototype.init = function() {
      var targetSpeed, targetWidth, targetX;
      targetWidth = 30;
      targetX = Math.random() * (canvas.width() - targetWidth);
      targetSpeed = Math.random() * 4;
      this.width = targetWidth;
      this.height = 30;
      this.x = targetX;
      this.y = 30;
      this.velocity = targetX < canvas.width() / 2 ? targetSpeed : -targetSpeed;
      this.rotationFrame = 0;
      return this.rotationFactor = parseInt(Math.random() * 10..toFixed(0)) + 1;
    };
    Target.prototype.update = function() {
      this.x += this.velocity;
      this.rotationFrame += this.rotationFactor;
      if (Math.abs(this.rotationFrame) > 64) {
        this.rotationFactor *= -1;
      }
      if (this.x < 0 || this.x + this.width > canvas.width()) {
        this.velocity *= -1;
      }
      if (this.expired) {
        score += 100;
      }
      if (Math.random() < (0.01 * level)) {
        return bullets.push({
          width: 4,
          height: 4,
          x: this.x + this.width / 2 - 2,
          y: this.y + this.height + 1,
          velocity: 4,
          owner: this
        });
      }
    };
    Target.prototype.draw = function() {
      context.save();
      context.translate(this.x + this.width / 2, this.y + this.height / 2);
      context.rotate((Math.PI / 16) * this.rotationFrame / 64);
      context.translate(-(this.x + this.width / 2), -(this.y + this.height / 2));
      context.drawImage(this.sprite, this.x, this.y, this.width, this.height);
      return context.restore();
    };
    return Target;
  })();
  Array.prototype.remove = function(value) {
    var i;
    i = 0;
    while (i < this.length) {
      if (this[i] === value) {
        this.splice(i, 1);
      } else {
        ++i;
      }
    }
    return this;
  };
  Array.prototype.random = function() {
    return this[parseInt(Math.random() * this.length)];
  };
  rectanglesIntersect = function(r1, r2) {
    return r1.x < r2.x + r2.width && r1.x + r1.width > r2.x && r1.y < r2.y + r2.height && r1.y + r1.height > r2.y;
  };
}).call(this);
