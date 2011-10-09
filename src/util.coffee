Array::remove = (value) ->
  i = 0
  while i < @length
    if @[i] == value
      @splice i, 1
    else
      ++i
  return @