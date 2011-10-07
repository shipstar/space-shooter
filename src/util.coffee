Array::remove = (value) ->
  i = 0
  while i < @length
    if @[i] == value
      @splice i, 1
    else
      ++i
  return @

rectanglesIntersect = (r1, r2) ->
  if (r1.x > r2.x + r2.width || 
	  r2.x > r1.x + r1.width || 
	  r1.y > r2.y + r2.height || 
	  r2.y > r1.y + r1.height
	 )
    return false;
  else
  	return true;