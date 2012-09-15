express = require 'express'
fs = require 'fs'
redis = require 'redis'

dbconfig = JSON.parse fs.readFileSync('etc/redis.json').toString()
db = redis.createClient(dbconfig['port'] || 6379, dbconfig['host'] || 'localhost')

db.on 'error', (err) ->
  console.log "Redis error: #{err}"

app = express()

app.use(express.bodyParser())

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

app.get('/run-me.js', (req, res) ->
  fs.readFile('./public/run-me.js', 'utf8', (err,data) ->
    if err
      return console.log(err)
    res.send data
  )
)

# Create a task
app.post('/task/create', (req, res) ->
  code = req.param('code')
  inputs = req.param('inputs')
  db.get('task:last_id', (err, reply) =>
    id = parseInt(reply[0])
    db.incr('task:last_id')
    db.set("task:#{id}:code", code)
    db.sadd('task:all', id)
    # Should be a way to lpush everything at once
    for input in inputs
      db.lpush("task:#{id}:inputs", JSON.stringify(input))
    res.send id: id
  )
)

# Work on a random task
app.get('/task/work', (req, res) ->
  db.srandmember('task:all', (err, id) ->
    # Should work with AJAX?
    res.redirect("/task/#{id}/work")
  )
)

# Get the code/input to do a task for an input
app.get('/task/:id/work', (req, res) ->
  id = req.param('id')
  db.multi([
    ['get', "task:#{id}:code"],
    ['lpop', "task:#{id}:inputs"]
  ]).exec (err, replies) ->
    [code, input] = replies
    # Add it back to the queue in case we fail
    db.rpush("tasks:#{id}:inputs", input)
    res.send input: JSON.parse(input), code: code
)

# Callback for when a task has finished for an input
# TODO make a note if we're done with a task
app.post('/task/:id/work', (req, res) ->
  id = req.param('id')
  input = req.param('input')
  result = req.param('result')
  # Add to the results set:
  db.hset("task:#{id}:results", JSON.stringify(input), JSON.stringify(result))
  db.lrem("task:#{id}:inputs", 0, JSON.stringify(input))
  res.send 'Something'
)

# Get results for a task so far
app.get('/task/:id', (req, res) ->
  db.hgetall("task:#{req.param('id')}:results", (err, reply) =>
    # Output should be better later
    res.send reply
  )
)

app.listen 3000
console.log 'Listening on port 3000'
