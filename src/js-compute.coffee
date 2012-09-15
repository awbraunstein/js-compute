if typeof window is 'undefined'
  start = () =>
    postMessage 'Start'
    importScripts('http://localhost:3000/run-me.js')
    response =
      result: task(params)
      taskId: taskId

    request = new XMLHttpRequest()
    request.open('POST', 'http://localhost:3000/', false)
    request.send(JSON.stringify(response))


  @onmessage = (event) ->
    start()
else
  worker = new Worker 'js-compute.js'
  worker.onmessage = (event) =>
    console.log event.data
    return
  worker.postMessage()

