(function() {
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
  $(function() {
    var bullets, canvas, clearCanvas, context, drawBullets, drawShip, drawStats, drawTargets, gameLoop, generateTarget, handleKeys, init, lives, score, ship, targets, updateBullets, updateShip, updateTargets;
    canvas = null;
    context = null;
    ship = null;
    bullets = [];
    targets = [];
    score = 0;
    lives = 3;
    init = function() {
      canvas = $("#canvas");
      context = canvas.get(0).getContext("2d");
      ship = {
        width: 20,
        height: 20,
        x: canvas.width() / 2,
        y: canvas.height() - 50,
        movementInterval: 10,
        firing: false,
        movingLeft: false,
        movingRight: false
      };
      return setInterval(gameLoop, 17);
    };
    gameLoop = function() {
      updateBullets();
      updateTargets();
      updateShip(ship);
      generateTarget();
      clearCanvas();
      drawShip(ship);
      drawBullets(bullets);
      drawTargets(targets);
      return drawStats();
    };
    updateShip = function(ship) {
      var bullet, myBullets;
      if (ship.movingLeft) {
        if (ship.x > 0) {
          ship.x -= ship.movementInterval;
        }
      }
      if (ship.movingRight) {
        if ((ship.x + ship.width) < canvas.width()) {
          ship.x += ship.movementInterval;
        }
      }
      if (ship.firing) {
        myBullets = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = bullets.length; _i < _len; _i++) {
            bullet = bullets[_i];
            if (!bullet.expired && bullet.owner === ship) {
              _results.push(bullet);
            }
          }
          return _results;
        })();
        if (myBullets.length <= 4) {
          bullets.push({
            width: 2,
            height: 2,
            x: ship.x + ship.width / 2,
            y: ship.y - 1,
            velocity: -8,
            owner: ship
          });
        }
      }
      if (ship.expired) {
        lives -= 1;
        return ship.expired = false;
      }
    };
    updateTargets = function() {
      var target, _i, _len;
      for (_i = 0, _len = targets.length; _i < _len; _i++) {
        target = targets[_i];
        if (target.expired) {
          score += 100;
        }
        if (Math.random() < 0.01) {
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
          if (bullet.y < ship.y + ship.height && bullet.y > ship.y && bullet.x < ship.x + ship.width && bullet.x > ship.x) {
            ship.expired = true;
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
      if (Math.random() < 0.01) {
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
    drawShip = function(ship) {
      if (!ship.expired) {
        canvas.get(0).getContext("2d").fillRect(ship.x, ship.y, ship.width, ship.height);
        return canvas.get(0).getContext("2d").fillRect(ship.x + ship.width / 2 - 1, ship.y - 4, 2, 4);
      }
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
      return $('#lives').text(lives);
    };
    handleKeys = function(options) {
      return function() {
        if (event.which === $.ui.keyCode.LEFT) {
          ship.movingLeft = options.down;
        }
        if (event.which === $.ui.keyCode.RIGHT) {
          ship.movingRight = options.down;
        }
        if (event.which === $.ui.keyCode.SPACE) {
          return ship.firing = options.down;
        }
      };
    };
    $(document).keydown(handleKeys({
      down: true
    }));
    $(document).keyup(handleKeys({
      down: false
    }));
    return init();
  });
}).call(this);
