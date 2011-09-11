(function() {
  $(function() {
    var canvas, clearCanvas, context, drawShip, gameLoop, init, ship, updateShip;
    canvas = null;
    context = null;
    ship = null;
    clearCanvas = function() {
      return context.clearRect(0, 0, canvas.width(), canvas.height());
    };
    drawShip = function(ship) {
      canvas.get(0).getContext("2d").fillRect(ship.x, ship.y, ship.width, ship.height);
      return canvas.get(0).getContext("2d").fillRect(ship.x + ship.width / 2 - 1, ship.y - 4, 2, 4);
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
      clearCanvas();
      return drawShip(ship);
    };
    updateShip = function(event) {
      if (event.which === $.ui.keyCode.LEFT) {
        return ship.x -= ship.movementInterval;
      } else if (event.which === $.ui.keyCode.RIGHT) {
        return ship.x += ship.movementInterval;
      }
    };
    $(document).keydown(updateShip);
    return init();
  });
}).call(this);
