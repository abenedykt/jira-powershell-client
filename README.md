jira-powershell-client
======================

1) *Jira-Issues* - show my list of tasks
2) *Jira-Close* - close task
3) *Jira-Time* - register time for task

4) *Git-Clone* - clone with the selected task key and description as a message

appEngine
=========

appEngine - simple dispatcher for request

initialize appengine and register workers
```
var app = new ApplicationEngine();
app.RegisterWorker(workerThatWillHandleTheRequest);
```

and you're ready to go
```
//and now you can just
