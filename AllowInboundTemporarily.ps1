
# Copyright (c) 2019 Gurjit Singh

# This source code is licensed under the MIT license that can be found in
# the accompanying LICENSE file or at https://opensource.org/licenses/MIT.

#region Get-Admin
function Get-Admin() {

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
                $ErrorActionPreference = "Continue"
                Exit
            }
        }
    
    }
    
}

#endregion

#region Get-AnyKey
function Get-AnyKeyTo ($msg) {
    
    Write-Output "Press any key to $msg..."
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

}
#endregion

# Elevate privileges
Get-Admin

$ProfileParam = @{
    All = $true
    # AllowInboundRules    = 'False'

}

$ProfileParam.Add("AllowInboundRules", "True")

Set-NetFirewallProfile @ProfileParam

Write-Host @"

Inbound Rules Allowed.

"@

Get-AnyKeyTo("revert back to block all inbound")

$ProfileParam.Set_Item("AllowInboundRules", "False")

Set-NetFirewallProfile @ProfileParam
