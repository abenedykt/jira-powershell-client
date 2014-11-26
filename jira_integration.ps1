$jiraBasePath = "http://<<url to jira>>/rest/api/2/"
$userName = "<<user name>>"

function Jira-Auth-Header{
    # basic credentials should be defuned as userName:password => base64
    return "Authorization:Basic YWJlbmVkeWt0OlBvd2llZHoxS29tcGxlbWVudA=="
}

function Jira-Tasks{
    Jira-Issues
}

function Jira-Issues{

    $web = New-Object Net.WebClient
    $web.Encoding = [System.Text.Encoding]::UTF8
    $web.Headers.Add("$(Jira-Auth-Header)")
    $web.Headers.Add("Accept-Charset: utf-8")
    $issuesResult = $web.DownloadString("$($jiraBasePath)search?jql=assignee=$($userName)%20and%20status!=Closed%20and%20(type=Harmonogram%20or%20type%20=%20%22Zmiana%20harmonogramu%22%20or%20type%20=%20%22Zmiana%20harmonogramu%22)")

    $issues = $issuesResult | ConvertFrom-Json
    
    foreach($issue in $issues.issues){
        Write-Host  "$($issue.key)" -f Green -NoNewline;
        Write-Host  " $($issue.fields.summary)"
    }
}

function Jira-Issues-Git{

    $web = New-Object Net.WebClient
    $web.Encoding = [System.Text.Encoding]::UTF8
    $web.Headers.Add("$(Jira-Auth-Header)")
    $web.Headers.Add("Accept-Charset: utf-8")
    $issuesResult = $web.DownloadString("$($jiraBasePath)search?jql=assignee=$($userName)%20and%20status!=Closed%20and%20(type=Harmonogram%20or%20type%20=%20%22Zmiana%20harmonogramu%22%20or%20type%20=%20%22Zmiana%20harmonogramu%22)")

    $issues = $issuesResult | ConvertFrom-Json
    
    foreach($issue in $issues.issues){
        Write-Output  "$($issue.key) $($issue.fields.summary)"
    }
}

function Jira-Issues-Keys{

    $web = New-Object Net.WebClient
    $web.Encoding = [System.Text.Encoding]::UTF8
    $web.Headers.Add("$(Jira-Auth-Header)")
    $web.Headers.Add("Accept-Charset: utf-8")
    $issuesResult = $web.DownloadString("$($jiraBasePath)search?jql=assignee=$($userName)%20and%20status!=Closed%20and%20(type=Harmonogram%20or%20type%20=%20%22Zmiana%20harmonogramu%22%20or%20type%20=%20%22Zmiana%20harmonogramu%22)")

    $issues = $issuesResult | ConvertFrom-Json
    
    foreach($issue in $issues.issues){
        Write-Output "$($issue.key)"
    }
}

function Jira-Close{
    [CmdletBinding()]
    Param(
        # Any other parameters can go here
    )
 
    DynamicParam {
            # Set the dynamic parameters' name
            $ParameterName = 'Issue'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 1

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = Jira-Issues-Keys
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }

    begin {
        # Bind the parameter to a friendly variable
        $SelectedIssueKey = $PsBoundParameters[$ParameterName]
    }

    process {
        $itemToClose = "$($jiraBasePath)issue/$($SelectedIssueKey)/transitions"
        $jsonContentHeader = "Content-Type: application/json"

        $closedState = "{""transition"": {""id"": ""2""} }"

        $web = New-Object Net.WebClient
        $web.Encoding = [System.Text.Encoding]::UTF8
        $web.Headers.Add("$(Jira-Auth-Header)")
        $web.Headers.Add("Accept-Charset: utf-8")
        $web.Headers.Add($jsonContentHeader)
        $web.UploadString($itemToClose,$closedState)
    }
}

function Jira-Time {
[CmdletBinding()]
    Param(
        # Any other parameters can go here
        [string]$Time="1h",
        [string]$Comment=""
    )
 
    DynamicParam {
            # Set the dynamic parameters' name
            $ParameterName = 'Issue'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 1

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = Jira-Issues-Keys
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }

    begin {
        # Bind the parameter to a friendly variable
        $SelectedIssueKey = $PsBoundParameters[$ParameterName]
    }

    process {
        $itemToClose = "$($jiraBasePath)issue/$($SelectedIssueKey)/worklog?adjustEstimate=auto"
        $jsonContentHeader = "Content-Type: application/json"

        $workLog= "{""timeSpent"": ""$($Time)"",""comment"": ""$($Comment)""}"

        $web = New-Object Net.WebClient
        $web.Encoding = [System.Text.Encoding]::UTF8
        $web.Headers.Add("$(Jira-Auth-Header)")
        $web.Headers.Add("Accept-Charset: utf-8")
        $web.Headers.Add($jsonContentHeader)
        $web.UploadString($itemToClose,$workLog)
    }
}

function Commit {
[CmdletBinding()]
    Param(
        # Any other parameters can go here
        [string]$Comment=""
    )
 
    DynamicParam {
            # Set the dynamic parameters' name
            $ParameterName = 'Issue'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 1

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = Jira-Issues-Keys
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }

    begin {
        # Bind the parameter to a friendly variable
        $SelectedIssueKey = $PsBoundParameters[$ParameterName] + ' ' + $Comment
    }

    process {
        git commit -m $SelectedIssueKey
    }
}


function Git-Commit {
    [CmdletBinding()]
    Param(
        # Any other parameters can go here
    )
 
    DynamicParam {
            # Set the dynamic parameters' name
            $ParameterName = 'Issue'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 1

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = Jira-Issues-Git
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }

    begin {
        # Bind the parameter to a friendly variable
        $SelectedIssueKey = $PsBoundParameters[$ParameterName]
    }

    process {
        # Your code goes here
        git commit -m $SelectedIssueKey
    }
}
