express = require 'express'
fs = require 'fs'
redis = require 'redis'
coffee = require 'coffee-script'

# Redis setup
dbconfig = JSON.parse fs.readFileSync('etc/redis.json').toString()
db = redis.createClient(dbconfig['port'] || 6379, dbconfig['host'] || 'localhost')

db.on 'error', (err) ->
  console.log "Redis error: #{err}"

# Other boilerplate...
app = express()

app.use(express.bodyParser())

app.set('views', __dirname + '/../views')
app.use(express.static(__dirname + '/../public'))
app.engine('jade', require('jade').__express)

app.all('/*', (req, res, next) ->
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Headers', 'X-Requested-With')
  next()
)

# Serve form for creating a new task
app.get('/', (req, res) ->
  res.render 'new_task.jade'
)

# Create a new task
app.post('/', (req, res) ->
  title = req.param('title')
  code = coffee.compile(req.param('code'))
  inputs = JSON.parse(req.param('inputs'))
  db.get('task:last_id', (err, id) =>
    id = parseInt(id)
    db.incr('task:last_id')
    db.set("task:#{id}:title", title)
    db.set("task:#{id}:code", code)
    db.sadd('task:all', id)
    db.sadd('task:ongoing', id)
    # Should be a way to lpush everything at once
    for input in inputs
      db.lpush("task:#{id}:inputs", JSON.stringify(input))
    res.redirect("/#{id}")
  )
)

# Dashboard for a task
app.get('/:id', (req, res) ->
  id = req.param('id')
  db.multi([
    ['sismember', 'task:ongoing', id],
    ['llen', "task:#{id}:inputs"],
    ['hgetall', "task:#{id}:results"],
    ['get', "task:#{id}:title"],
  ]).exec (err, replies) =>
    [ongoing, pending_count, results, title] = replies
    res.render 'task.jade',
      id: id
      ongoing: ongoing
      results: results
      title: title
      pending_count: pending_count
)

# JSON of results for a task
app.get('/:id/results', (req, res) ->
  id = req.param('id')
  db.hgetall "task:#{id}:results", (err, results) =>
    res.send results
)

# Worker script (script to be embedded)
app.get('/:id/worker', (req, res) ->
  
)

# Work on a random task
app.get('/task/work', (req, res) ->
  db.srandmember('task:ongoing', (err, id) ->
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
    db.rpush("task:#{id}:inputs", input)
    res.send input: JSON.parse(input), code: code
)

# Callback for when a task has finished for an input
# TODO make a note if we're done with a task
app.post('/task/:id/work', (req, res) ->
  id = req.param('id')
  input = req.param('input')
  result = req.param('result')
  # Add to the results set:
  db.hset("task:#{id}:results", JSON.stringify(input), JSON.stringify(result), redis.print)
  db.lrem("task:#{id}:inputs", 0, JSON.stringify(input))
  db.llen("task:#{id}:inputs", (err, len) ->
    if len is 0
      db.sadd('task:completed', id)
      db.srem('task:ongoing', id)
    res.send more: len isnt 0
  )
)

app.listen 3000
console.log 'Listening on port 3000'
