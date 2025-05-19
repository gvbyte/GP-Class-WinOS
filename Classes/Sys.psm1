using module .\Log.psm1
class Sys {
    # Get uptime from (Server)
    static [string] GetUptime([string] $Server) {
         # Gather wmi info
        try{
            # Get Processes
            $wmi_info = Get-WmiObject -Class Win32_OperatingSys -ComputerName $Server
            # Get uptime
            $uptime = $wmi_info.ConvertToDateTime($wmi_info.LastBootUpTime)
            $uptimeDays = (Get-Date) - $uptime
            # Format uptime
            $final_uptime = "{0:N2}" -f $uptimeDays.TotalDays + " days"
        }catch{
                $final_uptime = "N/A"
        }
        return $final_uptime;
    }
    # Function to get CPU utilization
    static [double] GetCPUUtilization([string] $Server) {
        $cpu = try {
            return Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {
                $SampleCount = 5;
                $IntervalSec = 1;
                $CPUSamples = Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval $IntervalSec -MaxSamples $SampleCount
                $values = $CPUSamples.CounterSamples | Select-Object -ExpandProperty CookedValue
                $averageCPU = [System.Math]::Round(($values | Measure-Object -Average).Average,2);
                return $averageCPU;
            }
        }
        catch {
            return -1.00
        }
        $cpu_utilization = [math]::Round(($cpu), 2)
        return $cpu_utilization;
    }
    # Function to get RAM utilization
    static [System.Object] GetRAMUtilization([string] $Server) {
        $RAM = try {
            Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {
                $os = Get-WmiObject -Class Win32_OperatingSys
                if($os.TotalVisibleMemorySize -eq 0){throw;}
                $total_ram = $os.TotalVisibleMemorySize
                $free_ram = $os.FreePhysicalMemory
                $used_ram = $total_ram - $free_ram
                $ram_utilization = ($used_ram / $total_ram) * 100
                $ram_utilization = [math]::Round($ram_utilization, 2)
                if(!($ram_utilization)){$ram_utilization = "N/A"}
                return [PSCustomObject]@{
                    RAMTotal = $total_ram
                    RAMFree  = $free_ram
                    RAMUsed  = $used_ram
                    RAMUtil  = $ram_utilization
                }
            }
        }
        catch {
            [PSCustomObject]@{
                RAMTotal = 'N/A'
                RAMFree  = 'N/A'
                RAMUsed  = 'N/A'
                RAMUtil  = 'N/A'
            }
        }
        return $RAM
    }
    # Function to get Total Processes
    static [string] GetProcesses([string] $Server) {
        $total_processes = (Get-WmiObject -Class Win32_OperatingSys -ComputerName $Server).NumberOfProcesses;
        if(!($total_processes)){$total_processes = "N/A"};
        return $total_processes;
    }
    # Function to concatenate all information regarding the server
    static [PSCustomObject] GetServerInfo([string] $Server) {
            # Get last KB installed
            $kb_table = Get-HotFix -ComputerName $Server | Sort-Object InstalledOn -Descending | Select-Object -First 5
            if(!($kb_table)){$kb_table = "N/A"}
            $lastKB = $kb_table | select -First 1;
            if(!($lastKB)){$lastKB = "N/A"};
            # RAM
            $RAM      = [Sys]::GetRAMUtilization([string] $Server);
            $RAMTotal = [System.Math]::Round($($RAM.RAMTotal / 2048),2)
            $RAMFree  = $RAM.RAMFree / 1024
            $RAMUsed  = $RAM.RAMUsed / 1024
            $RAMUtil  = $RAM.RAMUtil 
            
            $Server_overview = [PSCustomObject]@{
                Server             = $Server
                Uptime             = [Sys]::GetUptime([string] $Server);
                CPUUtil            = "$([Sys]::GetCPUUtilization([string] $Server))%";
                RAMUtil            = "$RAMUtil%"
                RAMTotal           = "$RAMTotal GB"
                RAMFree            = "$RAMFree GB"
                RAMUsed            = "$RAMUsed GB"
                Processes          = [Sys]::GetProcesses([string] $Server);
                ApplicationLogs    = [Log]::GetApplicationCount($Server);
                SecurityLogs       = ""
                SysLogs         = ""
                LastKB             = "$($lastKB.HotFixID) - $($lastKB.InstalledOn)";
                KBTable            = $kb_table
            } 
            return $Server_overview
    }
}