 $Query = @{
           logname = 'System'
           ID = 9,11707,11724,6008,1074,7031,7034,1564,1069,1135,1260,1076,7045
           StartTime =  [datetime]::Today.AddDays(-3)
           EndTime = [datetime]::Today
    }
Get-WinEvent -FilterHashTable $Query -ErrorAction Ignore | Select-Object MachineName,TimeCreated,ID,Message  