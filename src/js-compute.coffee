workerFunction = () ->
  start = () =>

    @more = false
    cond = () => @more
    @doWhile(runCode, cond)

  runCode = () =>
    taskId = 8
    importScripts("http://5a3t.localtunnel.com/task/#{taskId}/work")
    response =
      result: task(params)
      input: params

    request = new XMLHttpRequest()
    request.open('POST', "http://5a3t.localtunnel.com/task/#{taskId}/work", false)
    request.setRequestHeader("Content-type", "application/json");
    request.send(JSON.stringify(response))
    if request.status is 200
      @more = JSON.parse(request.responseText).more || false

  @onmessage = (event) ->
    start()

  @doWhile = (func, condition) ->
    func()
    func() while condition()

  return

getUrlForWorker = (workerFunction) ->
  BlobBuilder = window.MozBlobBuilder or window.WebKitBlobBuilder or window.BlobBuilder
  URL = window.URL or window.webkitURL
  mainString = workerFunction.toString()
  bodyString = mainString.substring( mainString.indexOf("{")+1, mainString.lastIndexOf("}") )
  bb = new BlobBuilder()

  bb.append(bodyString)

  return URL.createObjectURL(bb.getBlob())

workerUrl = getUrlForWorker workerFunction
worker = new Worker workerUrl
worker.onmessage = (event) =>
  console.log event.data
  return
worker.postMessage()

