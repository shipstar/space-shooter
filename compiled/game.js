(function() {
  $(function() {
    var canvas, spaceship;
    canvas = $('#canvas');
    spaceship = {
      width: 20,
      height: 20,
      x: canvas.width() / 2,
      y: 550
    };
    canvas.get(0).getContext("2d").fillRect(spaceship.x, spaceship.y, spaceship.width, spaceship.height);
    canvas.get(0).getContext("2d").fillRect(spaceship.x + spaceship.width / 2 - 1, spaceship.y - 4, 2, 4);
    return $(document).keydown(function(event) {
      if (event.which === $.ui.keyCode.LEFT) {
        return console.log('pressed left!');
      } else if (event.which === $.ui.keyCode.RIGHT) {
        return console.log('pressed right.');
      }
    });
  });
}).call(this);
