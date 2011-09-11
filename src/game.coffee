$ ->
  $('#kills').addClass('red')
  $('#stage').click ->
    this.getContext("2d").fillRect(50, 25, 150, 100)
