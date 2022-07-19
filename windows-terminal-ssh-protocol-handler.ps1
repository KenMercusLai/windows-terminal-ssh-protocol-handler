# Copyright (c) Ken Lai. All rights reserved.
# Licensed under the MIT License.
#
# SSH Protocol Handler Script
# by Ken Lai
# 
# Requires: putty
#   Option 1: scoop install putty
#   Option 2: 
#       Download Link: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
#   Note: putty.exe path must be defined in your PATH environment variable, try to run putty in the command line to confirm it

# --> Begin user modifiable variables

# Set the SSH Client you would like to call
# Options: <putty>
# Default: putty
$sshPreferredClient = 'putty'

# <-- End user modifiable variables

$inputURI = $args[0]
$inputArguments = @{}

if ($inputURI -match '(?<Protocol>\w+)\:\/\/(?:(?<Username>[\w|\@|\.]+)@)?(?<HostAddress>.+)\:(?<Port>\d{2,5})') {
    # Optional
    if ($Matches.Username -eq "PA_ACCOUNT") {
        $inputArguments.Add('Username', $env:PA_ACCOUNT) 
        $inputArguments.Add('Orig_User', "PA_ACCOUNT")
    }
    elseif ($Matches.Username -eq "ACCOUNT") {
        $inputArguments.Add('Username', $env:ACCOUNT) 
        $inputArguments.Add('Orig_User', "ACCOUNT")
    }
    else {
        $inputArguments.Add('Username', $Matches.Username)
        $inputArguments.Add('Orig_User', $Matches.Username)
    }
    $inputArguments.Add('Protocol', $Matches.Protocol)
    $inputArguments.Add('Port', $Matches.Port)
    $rawHost = $Matches.HostAddress
	
    switch -Regex ($rawHost) {
        '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' {
            # Basic test for IP Address 
            $inputArguments.Add('HostAddress', $rawHost)
            Break
        }
        '(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{0,62}[a-zA-Z0-9]\.)+[a-zA-Z]{2,63}$)' { 
            # Test for a valid Hostname
            $inputArguments.Add('HostAddress', $rawHost)
            # Break
        }
        Default {
            Write-Warning 'The Hostname/IP Address passed is invalid. Exiting...'
            # Exit
        }
    }
}
else {
    Write-Warning 'The URL passed to the handler script is invalid. Exiting...'
    # Exit
}

$sshArguments = ''

if ($sshPreferredClient -eq 'putty') {
    $appExec = Get-Command 'putty.exe' | Select-Object -ExpandProperty 'Source'
    if (Test-Path $appExec) {
        $SSHClient = $appExec
    }
    else {
        Write-Warning 'Could not find putty.exe in Path. Exiting...'
        Exit
    }

    if ($inputArguments.Username) {
        if ($inputArguments.Orig_User -eq "PA_ACCOUNT") {
            $sshArguments += "{0} -l {1} -P {2} -pw {3}" -f $inputArguments.HostAddress, $inputArguments.Username, $inputArguments.Port, $env:PA_ACCOUNT_PWD
        }
        elseif ($inputArguments.Orig_User -eq "ACCOUNT") {
            $sshArguments += "{0} -l {1} -P {2} -pw {3}" -f $inputArguments.HostAddress, $inputArguments.Username, $inputArguments.Port, $env:ACCOUNT_PWD
        }
        else {
            $sshArguments += "{0} -l {1} -P {2}" -f $inputArguments.HostAddress, $inputArguments.Username, $inputArguments.Port
        }
    }
    else {
        $sshArguments += "{0} -P {1}" -f $inputArguments.HostAddress, $inputArguments.Port   
    }

    Start-Process -WindowStyle Hidden -FilePath $SSHClient -ArgumentList "-ssh $sshArguments"
}
