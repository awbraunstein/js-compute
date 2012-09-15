express = require 'express'
fs = require 'fs'
app = express()

app.all('/*', (req, res, next) ->
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Headers', 'X-Requested-With')
  next()
)

app.get('/', (req, res) ->
  res.send 'Hello World'
)

app.get('/index.html', (req, res) ->
  fs.readFile('./public/index.html', 'utf8', (err,data) ->
    if err
      return console.log(err)
    res.send data
  )
)

app.get('/js-compute.js', (req, res) ->
  fs.readFile('./public/js-compute.js', 'utf8', (err,data) ->
    if err
      return console.log(err)
    res.send data
  )
)

app.post('/', (req, res) ->
  console.log req.body
  res.send(200)
)

app.get('/run-me.js', (req, res) ->
  fs.readFile('./public/run-me.js', 'utf8', (err,data) ->
    if err
      return console.log(err)
    res.send data
  )
)

app.listen 3000
console.log 'Listening on port 3000'