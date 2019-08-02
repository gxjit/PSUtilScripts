
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

$ruleName = "VSCode"

# Coercing to array to grab first rule out of multiple rules with same name.
$rule = (Get-NetFirewallRule -DisplayName $ruleName)[0]

Write-Host @"
$ruleName is Enabled: $($rule.Enabled.ToString()).
"@

Get-AnyKeyTo("toggle.")

$ruleParam = @{
    DisplayName = $ruleName
    # Enabled = "True"
}

if ($rule.Enabled.ToString() -eq "False") {
    $ruleParam.Add("Enabled", "True")

}

elseif ($rule.Enabled.ToString() -eq "True") {
    $ruleParam.Add("Enabled", "False")

}

Set-NetFirewallRule @ruleParam
# Set-NetFirewallRule -DisplayName $ruleName -Enabled True
