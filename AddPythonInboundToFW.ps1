
# Copyright (c) 2019 Gurjit Singh

# This source code is licensed under the MIT license that can be found in
# the accompanying LICENSE file or at https://opensource.org/licenses/MIT.


#region Get-AnyKeyTo
function Get-AnyKeyTo ($msg) {

  Write-Output "Press any key to $msg..."
  $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

}

#endregion

#region Get-Admin
function Get-Admin {
  [CmdletBinding()]
  param ()

  Begin {

    # Catch All Errors
    $ErrorActionPreference = "Stop"

  }

  process {
    if (!(([Security.Principal.WindowsIdentity]::GetCurrent()).Owner.Value.Equals("S-1-5-32-544"))) {

      try {

        $ProcParam = @{
          FilePath     = 'powershell'
          ArgumentList = "-File `"$($MyInvocation.PSCommandPath)`" -NoExit"
          Verb         = 'runAs'

        }

        Start-Process @ProcParam

      }
      catch {

        Write-Output ("`n`nError: `n$($PSItem.Exception)`n" +
          "`n$($PSItem.CategoryInfo)`n")

        # requires Get-AnyKeyTo.psm1 module
        Get-AnyKeyTo -msg "exit"
      }
      finally {
        Exit
      }
    }

  }

}

#endregion

Get-Admin

$ParamTable = @{
  DisplayName   = 'PythonVM'
  Program       = $([System.Environment]::ExpandEnvironmentVariables('%USERPROFILE%\AppData\Local\Programs\Python\Python38\python.exe'))
  Protocol      = 'TCP'
  Action        = 'Allow'
  Enabled       = 'True'
  Profile       = 'Any'
  RemoteAddress = 'LocalSubnet'
  # LocalAddress  = '10.1.1.1-10.1.1.2'

}

# New-NetFirewallRule @ParamTable -Direction 'Outbound'

New-NetFirewallRule @ParamTable -Direction 'Inbound'

Get-AnyKeyTo -msg "Exit"

