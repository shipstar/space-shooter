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
    var bullets, canvas, clearCanvas, context, drawBullets, drawShip, gameLoop, init, ship, updateBullets, updateShip;
    canvas = null;
    context = null;
    ship = null;
    bullets = [];
    clearCanvas = function() {
      return context.clearRect(0, 0, canvas.width(), canvas.height());
    };
    drawShip = function(ship) {
      canvas.get(0).getContext("2d").fillRect(ship.x, ship.y, ship.width, ship.height);
      return canvas.get(0).getContext("2d").fillRect(ship.x + ship.width / 2 - 1, ship.y - 4, 2, 4);
    };
    updateBullets = function(bullets) {
      var bullet, _i, _len;
      for (_i = 0, _len = bullets.length; _i < _len; _i++) {
        bullet = bullets[_i];
        bullet.y += bullet.velocity;
      }
      return bullets = (function() {
        var _j, _len2, _results;
        _results = [];
        for (_j = 0, _len2 = bullets.length; _j < _len2; _j++) {
          bullet = bullets[_j];
          if (bullet.y > 0) {
            _results.push(bullet);
          }
        }
        return _results;
      })();
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
    init = function() {
      canvas = $("#canvas");
      context = canvas.get(0).getContext("2d");
      ship = {
        width: 20,
        height: 20,
        x: canvas.width() / 2,
        y: 550,
        movementInterval: 10
      };
      return setInterval(gameLoop, 17);
    };
    gameLoop = function() {
      updateBullets(bullets);
      clearCanvas();
      drawShip(ship);
      return drawBullets(bullets);
    };
    updateShip = function(event) {
      if (event.which === $.ui.keyCode.LEFT) {
        if (ship.x > 0) {
          return ship.x -= ship.movementInterval;
        }
      } else if (event.which === $.ui.keyCode.RIGHT) {
        if ((ship.x + ship.width) < canvas.width()) {
          return ship.x += ship.movementInterval;
        }
      } else if (event.which === $.ui.keyCode.SPACE) {
        return bullets.push({
          width: 2,
          height: 2,
          x: ship.x + ship.width / 2,
          y: ship.y - 1,
          velocity: -15
        });
      }
    };
    $(document).keydown(updateShip);
    return init();
  });
}).call(this);
