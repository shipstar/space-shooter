(function() {
  var Ship, bullets, canvas, context, level, score, ship, targets;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  canvas = null;
  context = null;
  ship = null;
  bullets = [];
  targets = [];
  score = 0;
  level = 1;
  $(function() {
    var clearCanvas, drawBullets, drawStats, drawTargets, gameLoop, generateTarget, increaseLevel, init, updateBullets, updateTargets;
    init = function() {
      canvas = $("#canvas");
      context = canvas.get(0).getContext("2d");
      ship = new Ship(canvas);
      $(document).keydown(ship.handleKeys({
        down: true
      }));
      $(document).keyup(ship.handleKeys({
        down: false
      }));
      setInterval(gameLoop, 17);
      return setInterval(increaseLevel, 30000);
    };
    gameLoop = function() {
      updateBullets();
      updateTargets();
      ship.update();
      generateTarget();
      clearCanvas();
      ship.draw();
      drawBullets(bullets);
      drawTargets(targets);
      return drawStats();
    };
    increaseLevel = function() {
      return level += 1;
    };
    updateTargets = function() {
      var target, _i, _len;
      for (_i = 0, _len = targets.length; _i < _len; _i++) {
        target = targets[_i];
        if (target.expired) {
          score += 100;
        }
        if (Math.random() < (0.01 * level)) {
          bullets.push({
            width: 4,
            height: 4,
            x: target.x + target.width / 2 - 2,
            y: target.y + target.height + 1,
            velocity: 4,
            owner: target
          });
        }
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
    updateBullets = function() {
      var bullet, target, _i, _j, _len, _len2;
      for (_i = 0, _len = bullets.length; _i < _len; _i++) {
        bullet = bullets[_i];
        bullet.y += bullet.velocity;
        if (bullet.y <= 0) {
          bullet.expired = true;
        }
        for (_j = 0, _len2 = targets.length; _j < _len2; _j++) {
          target = targets[_j];
          if (bullet.y < target.y + target.height && bullet.y > target.y && bullet.x < target.x + target.width && bullet.x > target.x) {
            target.expired = true;
            bullet.expired = true;
          }
          if (bullet.y < ship.y + ship.height && bullet.y > ship.y && bullet.x < ship.x + ship.width && bullet.x > ship.x && ship.isAlive()) {
            if (!ship.invincible) {
              ship.expired = true;
            }
            bullet.expired = true;
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
    generateTarget = function() {
      var targetWidth;
      if (Math.random() < (0.01 * level)) {
        targetWidth = 30;
        return targets.push({
          width: targetWidth,
          height: 30,
          x: Math.random() * (canvas.width() - targetWidth),
          y: 30
        });
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
        _results.push(canvas.get(0).getContext("2d").fillRect(bullet.x, bullet.y, bullet.width, bullet.height));
      }
      return _results;
    };
    drawTargets = function(targets) {
      var target, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = targets.length; _i < _len; _i++) {
        target = targets[_i];
        _results.push(canvas.get(0).getContext("2d").fillRect(target.x, target.y, target.width, target.height));
      }
      return _results;
    };
    drawStats = function() {
      $('#score').text(score);
      $('#lives').text(ship.lives);
      return $('#level').text(level);
    };
    return init();
  });
  Ship = (function() {
    function Ship(canvas) {
      this.canvas = canvas;
      this.handleKeys = __bind(this.handleKeys, this);
      this.draw = __bind(this.draw, this);
      this.update = __bind(this.update, this);
      this.increaseOpacity = __bind(this.increaseOpacity, this);
      this.respawn = __bind(this.respawn, this);
      this.isAlive = __bind(this.isAlive, this);
      this.init = __bind(this.init, this);
      this.lives = 3;
      this.init();
    }
    Ship.prototype.init = function() {
      this.width = 20;
      this.height = 20;
      this.x = this.canvas.width() / 2;
      this.y = this.canvas.height() - 50;
      this.movementInterval = 10;
      this.firing = false;
      this.movingLeft = false;
      this.movingRight = false;
      this.respawning = false;
      this.invincible = false;
      return this.opacity = 1;
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
            return bullets.push({
              width: 2,
              height: 2,
              x: this.x + this.width / 2,
              y: this.y - 1,
              velocity: -8,
              owner: this
            });
          }
        }
      } else if (this.expired) {
        this.lives -= 1;
        this.expired = false;
        this.respawning = true;
        return setTimeout(this.respawn, 3000);
      }
    };
    Ship.prototype.draw = function() {
      if (this.isAlive()) {
        context.globalAlpha = this.opacity;
        context.fillRect(this.x, this.y, this.width, this.height);
        context.fillRect(this.x + this.width / 2 - 1, this.y - 4, 2, 4);
        return context.globalAlpha = 1;
      }
    };
    Ship.prototype.handleKeys = function(options) {
      return __bind(function() {
        switch (event.which) {
          case $.ui.keyCode.LEFT:
            return this.movingLeft = options.down;
          case $.ui.keyCode.RIGHT:
            return this.movingRight = options.down;
          case $.ui.keyCode.SPACE:
            return this.firing = options.down;
        }
      }, this);
    };
    return Ship;
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
}).call(this);
