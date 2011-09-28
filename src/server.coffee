sys = require 'sys'
http = require 'http'
fs = require 'fs'
url = require 'url'

server = http.createServer (req, res) ->
  path = url.parse(req.url).pathname
  switch path
    when '/', '/index.html', '/style.css'
      path = '/index.html' if path == '/'
      path = "/.." + path
      fs.readFile __dirname + path, (err, data) ->
        if err
          sys.puts err
          send404(res)
        else
          res.writeHead 200, 'text/html'
          res.write data, 'utf8'
          res.end()

    when '/compiled/game.js'
      path = "/.." + path
      fs.readFile __dirname + path, (err, data) ->
        if err
          sys.puts err
          send404(res)
        else
          res.writeHead 200, 'text/html'
          res.write data, 'utf8'
          res.end()

    else
      send404 res

send404 = (res) ->
  res.writeHead 404
  res.write '404'
  res.end()

sys.puts process.env.PORT
server.listen port = Number(process.env.PORT || 8888)
