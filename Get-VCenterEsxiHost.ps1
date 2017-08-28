#requires -Modules VMware.PowerCLI
<#
.SYNOPSIS
    Find what ESXi host a VM is running on
.DESCRIPTION
    This function will login to each ESXi host to see if the VCenter VM is running on it currently.
.EXAMPLE
    Get-VCenterEsxiHost -VCenterVMName 'vcenterhost' -ESXiHosts @("host1","host2","host3")

.EXAMPLE
    $hosts = @("host1","host2","host3")
    $Credential = Get-Credential
    Get-VCenterEsxiHost -VCenterVMName 'vcenterhost' -ESXiHosts $hosts -RootCredential $Credential

    WARNING: Could not find seaway on host1
    WARNING: Could not find seaway on host3
    WARNING: Could not find seaway on host2

    Name        VMHost
    ----        ------
    vcenterhost host1
#>
function Get-VCenterEsxiHost {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VCenterVMName,

        [Parameter(Mandatory=$true)]
        [string[]]$ESXiHosts,

        [Parameter(Mandatory=$true)]
        [pscredential]$RootCredential
    )
        #Foreach ESXi host in $ESXiHosts attempt to connect and find VCenter
        foreach ($item in $ESXiHosts)
        {
            try 
            {
                Connect-VIServer -Server $item -Credential $RootCredential -ErrorAction stop | Out-Null
            }
            catch  
            {
                $ErrorMessage = $_.Exception.Message
                $ErrorMessage 
                continue
            }
            try 
            {
                Get-VM -Name $VCenterVMName -Server $item -ErrorAction Stop | select-object Name,VMhost
                Disconnect-viserver -force -confirm:$false
            }
            catch
            {
                Write-Warning -Message "Could not find $VCenterVMName on $Item"
                Continue
            }
            Break
        }
        
}
