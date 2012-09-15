if typeof window is 'undefined'
  start = () =>
    postMessage 'Start'
    importScripts('http://localhost:3000/task/work')
    response =
      result: task(params)
      taskId: taskId

    request = new XMLHttpRequest()
    request.open('POST', "http://localhost:3000/#{response.taskId}/work", false)
    request.send(JSON.stringify(response))

  @onmessage = (event) ->
    start()

else
  worker = new Worker 'js-compute.js'
  worker.onmessage = (event) =>
    console.log event.data
    return
  worker.postMessage()

