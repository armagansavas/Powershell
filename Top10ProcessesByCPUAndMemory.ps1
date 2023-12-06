$Top10CPUUsage = Get-Counter "\Process(*)\% Processor Time" -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty CounterSamples |
    Where-Object {$_.Status -eq 0 -and $_.instancename -notin "_total", "idle"} |
    Sort-Object CookedValue -Descending |
    Select-Object @{N="Name";E={$friendlyName = $_.InstanceName
        try {
            $procId = [System.Diagnostics.Process]::GetProcessesByName($_.InstanceName)[0].Id
            $proc = Get-WmiObject -Query "SELECT ProcessId, ExecutablePath FROM Win32_Process WHERE ProcessId=$procId"
            $procPath = ($proc | Where-Object { $_.ExecutablePath } | Select-Object -First 1).ExecutablePath
            $friendlyName = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($procPath).FileDescription
        } catch { }
        $friendlyName
    }},
    @{N="CPU";E={($_.CookedValue/100/$env:NUMBER_OF_PROCESSORS).ToString("P")}} -First 10 |
    Format-Table -AutoSize
 
$Top10MemUsage = Get-WmiObject Win32_Process |
    Group-Object -Property name |
    Select-Object *, @{n='Mem (GB)';e={'{0:N5}' -f (($_.Group|Measure-Object WorkingSetSize -Sum).Sum / 1GB)}} |
    Sort-Object -Property {[float]$_.'Mem (GB)'} -Descending |
    Select-Object -First 10 |
    Select-Object name,'Mem (GB)'
 

$GetTop10CPUUsage = $Top10CPUUsage | Out-String
$GetTop10MemUsage = $Top10MemUsage | Out-String
 
$EventLogPerf = $GetTop10MemUsage + $GetTop10CPUUsage
 
$EventLogPerf | Format-Table -AutoSize