Array::remove = (value) ->
  i = 0
  while i < @length
    if @[i] == value
      @splice i, 1
    else
      ++i
  return @

Array::random = ->
  @[parseInt(Math.random() * @length)]

rectanglesIntersect = (r1, r2) ->
  r1.x < r2.x + r2.width  && r1.x + r1.width  > r2.x &&
  r1.y < r2.y + r2.height && r1.y + r1.height > r2.y
