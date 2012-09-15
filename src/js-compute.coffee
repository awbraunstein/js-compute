if typeof window is 'undefined'
  start = () =>


    more = false
    cond = () => more
    doWhile(runCode, cond)

  runCode = () ->
    taskId = 3
    importScripts("http://localhost:3000/task/#{taskId}/work")
    response =
      result: task(params)
      input: taskId

    request = new XMLHttpRequest()
    request.open('POST', "http://localhost:3000/task/#{taskId}/work", false)
    request.setRequestHeader("Content-type", "application/json");
    request.send(JSON.stringify(response))
    if request.status is 200
      more = JSON.parse(request.responseText).more || false

  @onmessage = (event) ->
    start()

  doWhile = (func, condition) ->
    func()
    func() while condition()
else
  worker = new Worker 'js-compute.js'
  worker.onmessage = (event) =>
    console.log event.data
    return
  worker.postMessage()

