Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global variable to hold the form and label
$global:form = $null
$global:label = $null
$global:progress = 0

#region FormShit
function Show-Form {

    $global:form = New-Object System.Windows.Forms.Form
    $global:form.Text = "Project Initialization..."
    $global:form.Size = New-Object System.Drawing.Size(400, 200)
    $global:form.StartPosition = "CenterScreen"

    $global:label = New-Object System.Windows.Forms.Label
    $global:label.Text = "Initializing..."
    $global:label.AutoSize = $true
    $global:label.Location = New-Object System.Drawing.Point(20, 40)
    $global:form.Controls.Add($label)

    $global:progressbar = New-Object System.Windows.Forms.ProgressBar
    $global:progressbar.Minimum = 0
    $global:progressbar.Maximum = 100
    $global:progressbar.Value = $global:progress
    $global:progressbar.Location = New-Object System.Drawing.Point(20, 100)
    $global:progressbar.Width = 350
    $global:progressbar.Height = 50
    $global:form.Controls.Add($global:progressbar)


    $form.Show()
}
function YesOrNoForm {
param ([string] $message)

    # Create a form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Node.js Update"
    $form.Size = New-Object System.Drawing.Size(300, 140)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedSingle"


    # Create a label
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(20, 25)
    $label.Size = New-Object System.Drawing.Size(250,45)
    $label.Text = $message

    # Create a "Yes" button
    $yesButton = New-Object System.Windows.Forms.Button
    $yesButton.Location = New-Object System.Drawing.Point(30, 70)
    $yesButton.Size = New-Object System.Drawing.Size(100, 30)
    $yesButton.Text = "Yes"
    $yesButton.Add_Click({
        $form.Tag = $true
        $form.Close()
    })

    # Create a "No" button
    $noButton = New-Object System.Windows.Forms.Button
    $noButton.Location = New-Object System.Drawing.Point(160, 70)
    $noButton.Size = New-Object System.Drawing.Size(100, 30)
    $noButton.Text = "No"
    $noButton.Add_Click({
        $form.Tag = $false
        $form.Close()
    })

    # Add controls to the form
    $form.Controls.Add($label)
    $form.Controls.Add($yesButton)
    $form.Controls.Add($noButton)

    # Show the form and wait for user input
    $form.ShowDialog() | Out-Null

    # Return the value of the Tag property, which will be $true for "Yes" and $false for "No"
    return $form.Tag
}

#endregion

#region Functions
function NodeJsIsOnPc {

    $global:label.Text = "Checking for Node.js on your pc."
    $global:progressbar.Value += 10
    try{
        $nodeVersion = node -v
        if($nodeVersion){
            $global:label.Text = "Found Node.js"
            return $true
        }
    }
    catch{
        $global:label.Text = "Node.js not found"
        return $false
    }
}

function GetLatestNodeJsUrl {
    $global:label.Text = "Fetching freshest stable Node.js version"
    

    try{
        $latestVersionInfo = Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json" | Where-Object {$_.lts -ne $null} | Select-Object -First 1
    
        $bitVersion = (Get-WmiObject win32_operatingsystem | select -ExpandProperty osarchitecture) -match "\d+" | Out-Null
        $bitVersion = $Matches[0]

        $nodeInstallerUrl = "https://nodejs.org/dist/$latestVersion/node-$latestVersion-x$bitVersion.msi"
        $global:label.Text = "Found Node.js version!"
        

        return $nodeInstallerUrl
    }catch{
        $global:label.Text = "Failed to fetch information!"
        

        throw $_
        
    }

}
#endregion



Show-Form


#Install Node.js
if (-not (NodeJsIsOnPc)) {
    $global:progressbar.Value += 10

    $nodeInstallerUrl = GetLatestNodeJsUrl
    $installerPath = "$env:TEMP\nodejs-installer.msi"
    
    $global:label.Text = "Downloading Node.js"
    Invoke-WebRequest -Uri $nodeInstallerUrl -OutFile $installerPath

    
    $global:label.Text = "Installing Node.js..."
    Start-Process msiexec.exe -ArgumentList "/i $installerPath /quiet" -NoNewWindow -Wait

    node -v
    npm -v
    
    $global:progressbar.Value += 10

    $global:label.Text = "Node.js and npm installation completed."
} else {
    $global:progressbar.Value += 10

    $result = YesOrNoForm("Would you like to update your Node.js?")
    if ($result) {
        $global:label.Text = "Attempting to update Node.js"

        npm install -g npm@latest

        $global:label.Text = "The update was successful!"
    }
    $global:progressbar.Value += 10
}

#npm install on project folder
$result = YesOrNoForm("Would you like to install npm modules for the FrontEnd?")
$global:progressbar.Value += 10
if ($result) {
    try {
        $global:label.Text = "Installing npm modules... this may take a while"
        

        cd .\react-frontend
        npm install
        $global:label.Text = "npm install successful"
    } catch {
        $global:label.Text = "npm install failed: $_"
    }
}
$global:progressbar.Value += 10

$form.Close()