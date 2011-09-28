(function() {
  var fs, http, port, send404, server, sys, url;
  sys = require('sys');
  http = require('http');
  fs = require('fs');
  url = require('url');
  server = http.createServer(function(req, res) {
    var path;
    path = url.parse(req.url).pathname;
    switch (path) {
      case '/':
      case '/index.html':
      case '/style.css':
        if (path === '/') {
          path = '/index.html';
        }
        path = "/.." + path;
        return fs.readFile(__dirname + path, function(err, data) {
          if (err) {
            sys.puts(err);
            return send404(res);
          } else {
            res.writeHead(200, 'text/html');
            res.write(data, 'utf8');
            return res.end();
          }
        });
      case '/compiled/game.js':
        path = "/.." + path;
        return fs.readFile(__dirname + path, function(err, data) {
          if (err) {
            sys.puts(err);
            return send404(res);
          } else {
            res.writeHead(200, 'text/html');
            res.write(data, 'utf8');
            return res.end();
          }
        });
      default:
        return send404(res);
    }
  });
  send404 = function(res) {
    res.writeHead(404);
    res.write('404');
    return res.end();
  };
  sys.puts(process.env.PORT);
  server.listen(port = Number(process.env.PORT || 8888));
}).call(this);
