(function() {
  $(function() {
    $('#kills').addClass('red');
    return $('#stage').click(function() {
      return this.getContext("2d").fillRect(50, 25, 150, 100);
    });
  });
}).call(this);
