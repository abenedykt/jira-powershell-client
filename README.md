Jira PowerShell Client
=====================


1) *Jira-Issues* - show my list of tasks

```
>Jira-Issues

LIDTWO-233 Task1
LIDTWO-233 Task2
LIDTWO-420 Bug12
```

2) *Jira-Close* - close task

```
>Jira-Close LIDTWO-233
```

3) *Jira-Time* - register time for task

```
>Jira-Time -Issue "LIDTWO-420" -Time 2h -Comment "Just a test fix"
```

4) *Git-Clone* - clone with the selected task key and description as a message

```
>Git-Commit "LIDTWO-233 Task1"
```
