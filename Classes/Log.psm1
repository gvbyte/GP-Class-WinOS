class Log {

    [array] GetDailyLogs([string] $server){
        # Get the current date
        $currentDate = (Get-Date).Date
        # Get event log entries from the specified server for the current day
        $logSummary = Get-EventLog -LogName * -After $currentDate -ComputerName $server | Select-Object Log, @{Name="Count";Expression={($_.Entries).Count}}
        # Display the results in a formatted table
        $logSummary | Format-Table -AutoSize
        return $logSummary
    }

    [string] GetLogTypeCount([string] $server, [string] $log){
        $logtable = [Log]::new().GetDailyLogs([string] $server);
        $log_count = ($logtable | ? {$_.Log -like $log}).Count
        if(!($log_count)){$log_count = "N/A"}

        return $log_count
    }

    [array] GetLogType([string] $server, [string] $log){
        $logtable = [Log]::new().GetDailyLogs([string] $server);
        $log_count = ($logtable | ? {$_.Log -like $log})
        if(!($log_count)){$log_count = "N/A"}

        return $log_count
    }

    static [string] GetApplicationCount([string] $server) {
        $logtable = [Log]::new().GetDailyLogs([string] $server);
        $application_logs = ($logtable | ? {$_.Log -like 'Application'}).Count
        if(!($application_logs)){$application_logs = "N/A"}
        return $application_logs
    }
}