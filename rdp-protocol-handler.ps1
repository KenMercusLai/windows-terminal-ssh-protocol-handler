# Copyright (c) Ken Lai. All rights reserved.
# Licensed under the MIT License.
#
# RDP Protocol Handler Script
# by Ken Lai
# 
# --> Begin user modifiable variables

# Set the RDP Client you would like to call
# Default: mstsc
$rdpPreferredClient = 'mstsc'

# <-- End user modifiable variables

$inputURI = $args[0]
$inputArguments = @{}

if ($inputURI -match '(?<Protocol>\w+)\:\/\/(?<HostAddress>.+)\:(?<Port>\d{2,5})') {
    $inputArguments.Add('Protocol', $Matches.Protocol)
    $inputArguments.Add('Port', $Matches.Port)
    $rawHost = $Matches.HostAddress
	
    switch -Regex ($rawHost) {
        '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' {
            # Basic test for IP Address 
            $inputArguments.Add('HostAddress', $rawHost)
            # Break
        }
        '(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{0,62}[a-zA-Z0-9]\.)+[a-zA-Z]{2,63}$)' { 
            # Test for a valid Hostname
            $inputArguments.Add('HostAddress', $rawHost)
            # Break
        }
        Default {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup($rawHost, 0, "The Hostname/IP Address passed is invalid", 0x0)
            Exit
        }
    }

    # the port must be [1, 65535]
    $port = $inputArguments.Port -as [Int]
    if (!($port)) {
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup($port, 0, "The port is empty", 0x0)
        Exit
    }
    elseif (!(($port -ge 1) -and ($port -le 65535))) {
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup($port, 0, "The port is invalid", 0x0)
        Exit
    }
    
}
else {
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup($inputURI, 0, "The URL passed is invalid", 0x0)
    Exit
}

$RDPArguments = ''

$PHD = New-Object System.Management.Automation.Host.ChoiceDescription '&Normal account', $env:ACCOUNT
$LSD = New-Object System.Management.Automation.Host.ChoiceDescription '&Privilege account', $env:PA_ACCOUNT
$MSD = New-Object System.Management.Automation.Host.ChoiceDescription '&Manual input', "Manual input username"
$QUIT = New-Object System.Management.Automation.Host.ChoiceDescription '&Quit', 'Abort login'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($PHD, $LSD, $MSD, $QUIT)
$title = 'Choose the account'
$message = ""
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
if ($result -eq 0) {
    $inputArguments.Add('Username', $env:ACCOUNT) 
    $inputArguments.Add('Password', $env:ACCOUNT_PWD)
}
elseif ($result -eq 1) {
    $inputArguments.Add('Username', $env:PA_ACCOUNT) 
    $inputArguments.Add('Password', $env:PA_ACCOUNT_PWD)
}
elseif ($result -eq 2) {
    Write-Output 'Manual input'
}
else {
    Exit
}


if ($rdpPreferredClient -eq 'mstsc') {
    $appExec = Get-Command 'mstsc.exe' | Select-Object -ExpandProperty 'Source'
    if (Test-Path $appExec) {
        $RDPClient = $appExec
    }
    else {
        Write-Warning 'Could not find mstsc.exe in Path. Exiting...'
        Exit
    }

    if ($inputArguments.Username) {
        $RDPArguments = "/generic:TERMSRV/{0} /user:{1} /pass:{2}" -f $inputArguments.HostAddress, $inputArguments.Username, $inputArguments.Password
        Start-Process -WindowStyle Hidden -FilePath "cmdkey" -ArgumentList $RDPArguments
    }

    $arguments = "/v:{0}:{1} /f" -f $inputArguments.HostAddress, $inputArguments.Port
    Start-Process -FilePath $RDPClient -ArgumentList $arguments

    if ($inputArguments.Username) {
        $RDPArguments = "/delete:TERMSRV/{0}" -f $inputArguments.HostAddress
        Start-Sleep -Seconds 5
        Start-Process -WindowStyle Hidden -FilePath "cmdkey" -ArgumentList $RDPArguments
    }
}
