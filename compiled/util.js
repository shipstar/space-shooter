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
}).call(this);
