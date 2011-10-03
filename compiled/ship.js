(function() {
  var Ship;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
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
}).call(this);
