#region config
$conf = "$home\Documents\RSA.conf.txt"
if (!(Test-Path $conf)) {
New-Item -Path $conf -ItemType "File" -Value "localhost
server.domain.local" | Out-Null
}
$domain = "$env:userdnsdomain"
$Font = "Arial"
$Size = "12"

Add-Type -assembly System.Windows.Forms
Add-Type -assembly System.Drawing

$ico_rdp       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command mstsc).Path)
$ico_usr       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command lusrmgr.msc).Path)
$ico_cred      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command netplwiz).Path)
$ico_pad       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command notepad).Path)
$ico_info      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command msinfo32).Path)
$ico_comp      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command compmgmt).Path)
$ico_services  = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command services.msc).Path)
$ico_proc      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command taskmgr.exe).Path)
$ico_net       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command ncpa.cpl).Path)
$ico_gp        = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command gpedit.msc).Path)
$ico_gpr       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command rsop.msc).Path)
$ico_disk      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command diskmgmt.msc).Path)
$ico_iscsi     = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command iscsicpl.exe).Path)
$ico_system    = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command sysdm.cpl).Path)
$ico_netfolder = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command fsmgmt.msc).Path)
$ico_report    = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command devmgmt.msc).Path)
$ico_event     = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command eventvwr.exe).Path)
$ico_soft      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command control.exe).Path)
$ico_upd       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command wusa.exe).Path)
$ico_dism      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command cleanmgr).Path)
$ico_dev       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command devmgmt.msc).Path)
$ico_time      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command timedate.cpl).Path)
$ico_kms       = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command msconfig).Path)
$ico_sync      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command mobsync.exe).Path)
$ico_desk      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command desk.cpl).Path)
$ico_regedit   = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command regedit).Path)
$ico_perf      = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command perfmon.msc).Path)

$dll_import = @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;
namespace System
{
public class IconExtractor
{
public static Icon Extract(string file, int number, bool largeIcon)
{
IntPtr large;
IntPtr small;
ExtractIconEx(file, number, out large, out small, 1);
try
{
return Icon.FromHandle(largeIcon ? large : small);
}
catch
{
return null;
}
}
[DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);
}
}
"@
Add-Type -TypeDefinition $dll_import -ReferencedAssemblies System.Drawing
#endregion

#region main_form
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = "Remote Shadow Administrator"
$main_form.ShowIcon = $false
$main_form.StartPosition = "CenterScreen"
$main_form.Font = "$Font,$Size"
$main_form.ForeColor = "Black"
$main_form.FormBorderStyle = "FixedSingle"
$main_form.Size = New-Object System.Drawing.Size(1000,730) # 850 710
$main_form.AutoSize = $true
#endregion

#region functions-main
function list-update {
$ListBox.Items.Clear()
$srv_list = Get-Content $conf
foreach ($tmp in $srv_list) {$ListBox.Items.Add($tmp)}
}

function list-domain {
$Status.Text = "Connecting to a domain: $domain"
$ListBox.Items.Clear()
$domain_comp = Get-ADComputer -Filter * -Properties *
$domain_comp_name = $domain_comp.Name
foreach ($tmp in $domain_comp_name) {$ListBox.Items.Add($tmp)}
}

function get-ping {
$ping = ping -n 1 -v 4 $srv
if ($ping -match "ttl") {$ping = @("Server: $srv - available at")} else {$ping = @("Server: $srv - unavailable")}
$global:ping_out = $ping
}

function Get-Query {
$usrv = query user /server:$srv

$usrv = $usrv -replace "\s{1,50}"," "
$usrv = $usrv -replace "USERNAME.+"
$usrv = $usrv -replace "rdp-tcp#(\d{1,4})\s"
$usrv = $usrv -replace "console "
$usrv = $usrv -replace "Active([\s\d\.]{1,20})","connected"
$usrv = $usrv -replace "Disc","disabled"
$usrv = $usrv -replace "connected.+","Connected"
$usrv = $usrv -replace "disabled.+","Disabled"
$usrv = $usrv -replace "^\s"
$usrv = $usrv -split "\s"


$obj = @()
if ($usrv[1] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[1]; "ID" = $usrv[2]; "Status" = $usrv[3]}}
if ($usrv[4] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[4]; "ID" = $usrv[5]; "Status" = $usrv[6]}}
if ($usrv[7] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[7]; "ID" = $usrv[8]; "Status" = $usrv[9]}}
if ($usrv[10] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[10]; "ID" = $usrv[11]; "Status" = $usrv[12]}}
if ($usrv[13] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[13]; "ID" = $usrv[14]; "Status" = $usrv[15]}}
if ($usrv[16] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[16]; "ID" = $usrv[17]; "Status" = $usrv[18]}}
if ($usrv[19] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[19]; "ID" = $usrv[20]; "Status" = $usrv[21]}}
if ($usrv[22] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[22]; "ID" = $usrv[23]; "Status" = $usrv[24]}}
if ($usrv[25] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[25]; "ID" = $usrv[26]; "Status" = $usrv[27]}}
if ($usrv[28] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[28]; "ID" = $usrv[29]; "Status" = $usrv[30]}}
if ($usrv[31] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[31]; "ID" = $usrv[32]; "Status" = $usrv[33]}}
if ($usrv[34] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[34]; "ID" = $usrv[35]; "Status" = $usrv[36]}}
if ($usrv[37] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[37]; "ID" = $usrv[38]; "Status" = $usrv[39]}}
if ($usrv[40] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[40]; "ID" = $usrv[41]; "Status" = $usrv[42]}}
if ($usrv[43] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[43]; "ID" = $usrv[44]; "Status" = $usrv[45]}}
if ($usrv[46] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[46]; "ID" = $usrv[47]; "Status" = $usrv[48]}}
if ($usrv[49] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[49]; "ID" = $usrv[50]; "Status" = $usrv[51]}}
if ($usrv[52] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[52]; "ID" = $usrv[53]; "Status" = $usrv[54]}}
if ($usrv[55] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[55]; "ID" = $usrv[56]; "Status" = $usrv[57]}}
if ($usrv[58] -gt 0) {$obj += [PSCustomObject]@{"Name" = $usrv[58]; "ID" = $usrv[59]; "Status" = $usrv[60]}}
$global:obj = $obj
}

function get-obj {
$DataGridView.DataSource = $null
$DataGridView.Rows.Clear()
$DataGridView.ColumnCount = 3
$DataGridView.Columns[0].Name = "Name"
$DataGridView.Columns[1].Name = "ID"
$DataGridView.Columns[2].Name = "Status"
$Service_dgv = foreach ($ojs in $obj) {
$DataGridView.Rows.Add($ojs.Name,$ojs.ID,$ojs.Status)
}
$DataGridView.Rows | ForEach-Object {
if ($_.Cells["Status"].Value -eq "Connected") {
$_.Cells[2] | %{$_.Style.BackColor = "green"}
} elseif ($_.Cells["Status"].Value -eq "Disabled") {
$_.Cells[2] | %{$_.Style.BackColor = "pink"}
}}
}

function up-time {
$boottime = Get-CimInstance -ComputerName $srv Win32_OperatingSystem | select LastBootUpTime
$datetime = (Get-Date) - $boottime.LastBootUpTime | SELECT Days,Hours,Minutes
$string = [convert]::ToString($datetime)
$string = $string -replace "@{"
$string = $string -replace "}"
$string = $string -replace ";"

$global:uptime = $string
}

function fun-main {
get-ping
$Status.Text = "$ping_out"
$ping_out_false = "Server: $srv - unavailable"
if ("$ping_out" -ne $ping_out_false) {
Get-Query
get-obj
up-time
} else {
$uptime = $null
}
if ($uptime.Length -gt 1) {$Status.Text += ". Working time - $uptime"} else {$Status.Text += ". WinRM is not available"}
$button_1.Enabled = $true
}

function broker-user {
$broker = Read-Host "Enter the full domain name of Sever with the RDCB role:"
Import-Module RemoteDesktop
$con = Get-RDUserSession -ConnectionBroker $broker | select hostserver, UserName, SessionState, CreateTime, DisconnectTime, unifiedsessionid | `
Out-GridView -title "Server: $broker" -PassThru
if ($con -ne $null) {$id = $con | select -ExpandProperty unifiedsessionid}
if ($con -ne $null) {$srv = $con | select -ExpandProperty hostserver}
if ($con -ne $null) {mstsc /v:"$srv" /shadow:"$id" /control /noconsentprompt}
}

function domain-comp {
$comp = Get-ADComputer -Filter * -Properties * | select @{Label="Status"; Expression={
if ($_.Enabled -eq "True") {$_.Enabled -replace "True","Active"} else {$_.Enabled -replace "False","Blocked"}
}}, @{Label="Name"; Expression={$_.Name}}, @{Label="IP-The address is"; Expression={$_.IPv4Address}}, `
@{Label="Operating system"; Expression={$_.OperatingSystem}}, @{Label="User"; `
Expression={$_.ManagedBy -replace "(CN=|,.+)"}}, @{Label="Creation date"; Expression={$_.Created}} | sort -Descending "Creation date" | `
Out-GridView -Title "domain: $domain" –PassThru
$global:srv = $comp.Name
fun-main
}
#endregion

#region functions-admin
function comp-manager {
compmgmt.msc /computer=\\$srv
}

function services-view-ogv {
$Service = Get-Service -computername "$srv" | Out-GridView -Title "Services on Server $srv" –PassThru
$global:Service_out = $Service.Name
if ($Service_out -ne $null) {
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Stop or restart the service: $Service_out",0,"Select an action",2)
if ($output -eq "4") {Get-Service -computername $srv | Where {$_.Name -Like $Service_out} | Restart-Service}
if ($output -eq "3") {Get-Service -computername $srv | Where {$_.Name -Like $Service_out} | Stop-Service}
$status_services = Get-Service -computername $srv | Where {$_.Name -Like $Service_out}
$status_services = $status_services.Status
$output = $wshell.Popup("Status: $status_services",0,"Information",64)
$Service_out = $null
}
}

function services-view {
$DataGridView.DataSource = $null
$DataGridView.Rows.Clear()
$DataGridView.ColumnCount = 3
$DataGridView.Columns[0].Name = "Status"
$DataGridView.Columns[1].Name = "Name"
$DataGridView.Columns[2].Name = "Display Name"
$Service_dgv = foreach ($gs in $Service) {
$DataGridView.Rows.Add($gs.Status,$gs.Name,$gs.DisplayName)
}
$DataGridView.Rows | ForEach-Object {
if ($_.Cells["Status"].Value -eq "Running") {
$_.Cells[0] | %{$_.Style.BackColor = "lightgreen"}
} elseif ($_.Cells["Status"].Value -eq "Stopped") {
$_.Cells[0] | %{$_.Style.BackColor = "pink"}
}}
$Count = $Service.Count
$Status.Text = "Found $Count services on Server $srv"

$ContextMenu_services = New-Object System.Windows.Forms.ContextMenu
$ContextMenu_services.MenuItems.Add("Restart",{
$global:dgv_selected_services = $DataGridView.SelectedCells.Value
services-restart
})
$ContextMenu_services.MenuItems.Add("Stop",{
$global:dgv_selected_services = $DataGridView.SelectedCells.Value
services-stop
})
$main_form.ContextMenu = $ContextMenu_services
}

function services-restart {
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Restart the service: $dgv_selected_services on Server $srv ?",0,"Select an action",4)
if ($output -eq "6") {Get-Service -computername $srv | Where {$_.Name -Like $dgv_selected_services} | Restart-Service}
$status_services = Get-Service -computername $srv | Where {$_.Name -Like $dgv_selected_services}
$status_services = $status_services.Status
$output = $wshell.Popup("Status: $status_services",0,"Information",64)
$Status.Text = "Service $dgv_selected_services launched"
$dgv_selected_services = $null
$global:Service = Get-Service -computername "$srv" | Sort Name
services-view
}

function services-stop {
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Stop the service: $dgv_selected_services on Server $srv ?",0,"Select an action",4)
if ($output -eq "6") {Get-Service -computername $srv | Where {$_.Name -Like $dgv_selected_services} | Stop-Service}
$status_services = Get-Service -computername $srv | Where {$_.Name -Like $dgv_selected_services}
$status_services = $status_services.Status
$output = $wshell.Popup("Status: $status_services",0,"Information",64)
$Status.Text = "Service $dgv_selected_services stopped"
$dgv_selected_services = $null
$global:Service = Get-Service -computername "$srv" | Sort Name
services-view
}

function services-search {
$SearchTextBox.Add_TextChanged({
$search_text = $SearchTextBox.Text
$Service = @($Service_search | Where {
$_.Name -match "$search_text"
})
services-view
})
}

function process-users-ogv {
Invoke-Command -ComputerName "$srv" -ScriptBlock {Get-Process -IncludeUserName} | sort -Descending CPU | `
select CPU, WS, UserName, ProcessName, Company, ProductVersion, Path | `
Out-GridView -Title "Processes on Server $srv" –PassThru | `
Invoke-Command -ComputerName $srv -ScriptBlock {Stop-Process -Force}
}

function process-users {
$DataGridView.DataSource = $null
$DataGridView.Rows.Clear()
$DataGridView.ColumnCount = 6
$DataGridView.Columns[0].Name = "User"
$DataGridView.Columns[1].Name = "Name"
$DataGridView.Columns[2].Name = "Company"
$DataGridView.Columns[3].Name = "CPU"
$DataGridView.Columns[4].Name = "WS"
$DataGridView.Columns[5].Name = "Path"
$Service_dgv = foreach ($gp in $process) {
$DataGridView.Rows.Add($gp.UserName,$gp.ProcessName,$gp.Company,$gp.CPU,$gp.WS,$gp.Path)
}
$DataGridView.Rows | ForEach-Object {
if ($_.Cells["User"].Value -match "\\") {
$_.Cells[0] | %{$_.Style.BackColor = "lightgreen"}
}
if ($_.Cells["CPU"].Value -gt "10") {
$_.Cells[3] | %{$_.Style.BackColor = "pink"}
}
if ($_.Cells["WS"].Value -gt "100000000") {
$_.Cells[4] | %{$_.Style.BackColor = "pink"}
}
}
$Count = $process.Count
$Status.Text = "Found $Count of processes on Server $srv"

$ContextMenu_services = New-Object System.Windows.Forms.ContextMenu
$ContextMenu_services.MenuItems.Add("Stop",{
$dgv_selected_proc = $DataGridView.SelectedCells.Value
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Stop the process: $dgv_selected_proc on Server $srv ?",0,"Select an action",4)
if ($output -eq "6") {Invoke-Command -ComputerName $srv -ScriptBlock {
Get-Process -IncludeUserName -ProcessName $using:dgv_selected_proc | Stop-Process -Force
}
$Status.Text = "The process $dgv_selected_proc stopped"
$global:process = Invoke-Command -ComputerName "$srv" -ScriptBlock {Get-Process -IncludeUserName} | sort -Descending UserName
process-users
}
})
$main_form.ContextMenu = $ContextMenu_services
}

function process-search {
$SearchTextBox.Add_TextChanged({
$search_text = $SearchTextBox.Text
$global:process = @($process_search | Where {
$_.ProcessName -match "$search_text"
})
process-users
})
}

function view-soft {
$software = icm $srv {Get-Package -ProviderName msi} # | select name,version,Source,ProviderName
$DataGridView.DataSource = $null
$DataGridView.Rows.Clear()
$DataGridView.ColumnCount = 3
$DataGridView.Columns[0].Name = "Name"
$DataGridView.Columns[1].Name = "Version"
$DataGridView.Columns[2].Name = "Source"
$Service_dgv = foreach ($gpack in $software) {
$DataGridView.Rows.Add($gpack.Name,$gpack.Version,$gpack.Source)
}

$ContextMenu_services = New-Object System.Windows.Forms.ContextMenu
$ContextMenu_services.MenuItems.Add("Delete",{
$global:dgv_selected_soft = $DataGridView.SelectedCells.Value
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Delete $dgv_selected_soft on Server $srv ?",0,"Select an action",4)
if ($output -eq "6") {
remove-soft
}
})
$main_form.ContextMenu = $ContextMenu_services
}

function remove-soft {
$Status.Text = "10%...deletion"; sleep 1
$session = New-PSSession $srv
$Status.Text = "20%...deletion"; sleep 1
icm -Session $session {$dgv_selected_soft = $using:dgv_selected_soft}
$Status.Text = "30%...deletion"; sleep 1
icm -Session $session {if ($dgv_selected_soft -ne $null) {
Get-Package -Name "$dgv_selected_soft" | Uninstall-Package}
}
$Status.Text = "50%...deletion"; sleep 1
icm -Session $session {$dgv_selected_soft = $null}
$Status.Text = "70%...deletion"; sleep 1
Disconnect-PSSession $session
$Status.Text = "80%...deletion"; sleep 1
Remove-PSSession $session
$Status.Text = "90%...deletion"; sleep 1
$dgv_selected_soft = $null
$Status.Text = "100%...Completed"; sleep 1
view-soft
}

function upd-dism {
$session = New-PSSession $srv
$dismName = icm -Session $session {dism /Online /Get-Packages /format:table} | Out-Gridview `
-Title "Packages on Server $srv" –PassThru
if ($dismName -ne $null) {
$dismNamePars = $dismName -replace "\|.+"
$dismNamePars = $dismNamePars -replace "\s"
} else {$dismNamePars = $null}
$wshell = New-Object -ComObject Wscript.Shell
if ($dismNamePars -ne $null) {
$output = $wshell.Popup("Remove $dismNamePars update on Server $srv ?",0,"Select an action",4)
}
if ($output -eq "6") {icm -Session $session {$dismNamePars = $using:dismNamePars}}
if ($output -eq "6") {$Status.Text = "10%...deletion"; sleep 1}
if ($output -eq "6") {icm -Session $session {dism /Online /Remove-Package /PackageName:$dismNamePars /quiet /norestart}}
if ($output -eq "6") {$Status.Text = "100%...ready"; sleep 1}
if ($output -eq "6") {icm -Session $session {$dismNamePars = $null}}
Disconnect-PSSession $session
Remove-PSSession $session
if ($output -eq "6") {$dismNamePars = $null}
}

function SMB-files-ogv {
$session = New-CIMSession –Computername $srv
Get-SmbOpenFile -CIMSession $session | select ClientUserName,ClientComputerName,Path,SessionID | `
Out-GridView -PassThru –title "Open files on Server $srv" | Close-SmbOpenFile -CIMSession $session -Confirm:$false –Force
}

function SMB-files {
$session = New-CIMSession –Computername $srv
$open_smb = Get-SmbOpenFile -CIMSession $session

$DataGridView.DataSource = $null
$DataGridView.Rows.Clear()
$DataGridView.ColumnCount = 4
$DataGridView.Columns[0].Name = "User Name"
$DataGridView.Columns[1].Name = "Client Computer Name"
$DataGridView.Columns[2].Name = "Path"
$DataGridView.Columns[3].Name = "File ID"
$Service_dgv = foreach ($smbf in $open_smb) {
$DataGridView.Rows.Add($smbf.ClientUserName,$smbf.ClientComputerName,$smbf.Path,$smbf.FileId)
}

$ContextMenu_services = New-Object System.Windows.Forms.ContextMenu
$ContextMenu_services.MenuItems.Add("Close",{
$dgv_selected_fileid = $DataGridView.SelectedCells.Value
$session = New-CIMSession –Computername $srv
Close-SmbOpenFile -CIMSession $session -FileId $dgv_selected_fileid -Confirm:$false –Force
SMB-files
})
$main_form.ContextMenu = $ContextMenu_services
}

function TCP-Viewer {
$tcp = Invoke-Command -ComputerName $srv -ScriptBlock {Get-NetTCPConnection -State Established,Listen | select LocalAddress,LocalPort, `
@{name="RemoteHostName";expression={(Resolve-DnsName $_.RemoteAddress).NameHost}},RemoteAddress,RemotePort,State, `
@{name="ProcessName";expression={(Get-Process -Id $_.OwningProcess).Path}},CreationTime} | select LocalAddress,LocalPort,RemoteHostName,RemoteAddress,RemotePort,State,ProcessName,CreationTime | `
Out-Gridview -Title "TCP network connections on Server $srv"
#$DataGridView.DataSource = $null
#$DataGridView.Rows.Clear()
#$DataGridView.ColumnCount = 8
#$DataGridView.Columns[0].Name = "LocalAddress"
#$DataGridView.Columns[1].Name = "LocalPort"
#$DataGridView.Columns[2].Name = "RemoteHostName"
#$DataGridView.Columns[3].Name = "RemoteAddress"
#$DataGridView.Columns[4].Name = "RemotePort"
#$DataGridView.Columns[5].Name = "State"
#$DataGridView.Columns[6].Name = "ProcessName"
#$DataGridView.Columns[7].Name = "CreationTime"
#$Service_dgv = foreach ($tcps in $tcp) {
#$DataGridView.Rows.Add($tcps.LocalAddress,$tcps.LocalPort,$tcps.RemoteHostName,$tcps.RemoteAddress,$tcps.RemotePort,$tcps.State,$tcps.ProcessName,$tcps.CreationTime)
#}
}

function gp-upd {
Invoke-Command -ComputerName $srv -ScriptBlock {gpupdate /force}
if ($lastexitcode -eq 0) {$Status.Text = "Group policies on Server $srv are applied"} else {$Status.Text = "Error in applying policies"}
}

function gp-res {
$usr = Read-Host "Enter your user name:"
$path = "C:\Users\$env:UserName\desktop\GPResult-$srv-$usr.html"
GPRESULT /S $srv /user $usr /H $path
ii $path
}
#endregion

#region functions-dns
function get-dns-zone {
$global:zone = icm -ComputerName $srv {Get-DnsServerZone} | select ZoneName,ZoneType,DynamicUpdate,ReplicationScope,SecureSecondaries,DirectoryPartitionName | `
Out-GridView -Title "DNS Server: $srv" –PassThru
$zone_name = $zone.ZoneName
if ($zone_name -ne $null) {
icm -ComputerName $srv {Get-DnsServerResourceRecord -ZoneName $using:zone_name | sort RecordType | select RecordType,HostName, @{Label="IPAddress"; `
Expression={$_.RecordData.IPv4Address.IPAddressToString}},TimeToLive,Timestamp} | select RecordType,HostName,IPAddress,TimeToLive,Timestamp `
| Out-GridView -Title "DNS Server: $srv"
}
$zone_name = $null
}
#endregion

#region functions-power
function power-reboot {
shutdown /r /f /t 60 /m \\$srv /c "Scheduled reboot after 30 seconds"
if ($lastexitcode -eq 0) {$Status.Text = "The reboot is scheduled"}
if (($lastexitcode -ne 0) -and ($lastexitcode -eq 1190)) {$Status.Text = "A reboot is already planned"}
if (($lastexitcode -ne 0) -and ($lastexitcode -ne 1190)) {$Status.Text = "Restart error"}
}

function power-off {
shutdown /s /f /t 30 /m \\$srv
if ($lastexitcode -eq 0) {$Status.Text = "Switching off is scheduled"} else {$Status.Text = "Shutdown error"}
}

function power-cancel {
shutdown /a /m \\$srv
if ($lastexitcode -eq 0) {$Status.Text = "Reboot canceled"}
if (($lastexitcode -ne 0) -and ($lastexitcode -eq 1116)) {$Status.Text = "The reset has already been canceled"}
if (($lastexitcode -ne 0) -and ($lastexitcode -ne 1116)) {$Status.Text = "Error canceling the restart"}
}

function power-monitor {
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("To disable the screen lock press yes
To specify Time before locking, press no",0,"Select an action",3)
if ($output -eq "6") {$timeout = "0"}
if ($output -eq "7") {$timeout = Read-Host "Enter Time in minutes"}
$session = New-PSSession $srv
icm -Session $session {$timeout = $using:timeout}
icm -Session $session {powercfg -change -monitor-timeout-ac $timeout}
icm -Session $session {powercfg -change -monitor-timeout-dc $timeout}
Remove-PSSession $session
if ($output -eq "6") {$Status.Text = "The screen lock is disabled"}
if ($output -eq "7") {$Status.Text = "Screen lock enabled ($timeout minutes)"}
}

function power-standby {
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("To disable sleep mode press yes
To specify Time before hibernation press no",0,"Select an action",3)
if ($output -eq "6") {$timeout = "0"}
if ($output -eq "7") {$timeout = Read-Host "Enter Time in minutes"}
$session = New-PSSession $srv
icm -Session $session {$timeout = $using:timeout}
icm -Session $session {powercfg -x -standby-timeout-ac $timeout}
icm -Session $session {powercfg -x -standby-timeout-dc $timeout}
Remove-PSSession $session
if ($output -eq "6") {$Status.Text = "Sleep mode is disabled"}
if ($output -eq "7") {$Status.Text = "Sleep mode enabled ($timeout minutes)"}
}

function power-wol {
[string]$mac_out = $outputBox_message.text
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Wake up the Server with the MAC address: $mac_out ?",0,"Address from the message input field",4)
if ($output -eq "6") {
$global:mac = $mac_out;
wol-pack
}}

function wol-pack {
$BroadcastProxy=[System.Net.IPAddress]::Broadcast
$Ports = 0,7,9

$synchronization = [byte[]](,0xFF * 6)
$bmac = $mac -Split '-' | ForEach-Object { [byte]('0x' + $_) }
$packet = $synchronization + $bmac * 16

$UdpClient = New-Object System.Net.Sockets.UdpClient
ForEach ($port in $Ports) {$UdpClient.Connect($BroadcastProxy, $port)
$UdpClient.Send($packet, $packet.Length) | Out-Null}
$UdpClient.Close()
$Status.Text = "Package sent"
}

function resolve {
#$ns = nslookup $srv
#$ns = $ns[-2]
#$global:ns = $ns -replace "Address:\s{1,10}"
$rdns = Resolve-DnsName $srv
$global:ns = $rdns.IPAddress
}

function get-mac-proxy {
if ($srv -NotMatch "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}") {resolve} else {$ns = $srv}
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Use a proxy-Server?",0,"Select an action",3)
if ($output -eq "6") {$proxy = Read-Host "Enter the proxy address of Sever:"}
if ($output -eq "7") {$arp = arp -a}
if ($proxy -ne $null) {$arp = Invoke-Command -ComputerName $proxy -ScriptBlock {arp -a}}
$arp = $arp -match "\b$ns\b"
$arp = $arp -replace "\s{1,10}"," "
$arp = $arp -replace "\s","+"
$arp = $arp -split "\+"
$mac = $arp -match "\w\w-\w\w-"
$outputBox_message.ForeColor = [System.Drawing.SystemColors]::WindowText
$outputBox_message.text = $mac
}

function get-dhcp {
$mac = Invoke-Command -ComputerName $srv -ScriptBlock {Get-DhcpServerv4Scope | Get-DhcpServerv4Lease} | `
select AddressState,HostName,IPAddress,ClientId,DnsRegistration,DnsRR,ScopeId,ServerIP | out-gridview -Title "HDCP Server: $srv" –PassThru
$mac = $mac.ClientId
$outputBox_message.ForeColor = [System.Drawing.SystemColors]::WindowText
$outputBox_message.text = $mac
}
#endregion

#region functions-event
function event-vwr {eventvwr $srv}

function event-sys {
Get-EventLog -ComputerName $srv -LogName System -Newest 50 -EntryType Error,Warning | `
select TimeWritten,EventID,EntryType,Source,Message | `
Out-Gridview -Title "System logs on Server $srv"
}

function event-app {
Get-EventLog -ComputerName $srv -LogName Application -Newest 50 -EntryType Error,Warning | `
select TimeWritten,EventID,EntryType,Source,Message | `
Out-Gridview -Title "Application logs on Server $srv"
}

function rdp-con {
$RDPAuths = Get-WinEvent -ComputerName $srv -LogName "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational" `
-FilterXPath '<QueryList><Query Id="0"><Select>*[System[EventID=1149]]</Select></Query></QueryList>'
[xml[]]$xml = $RDPAuths | Foreach {$_.ToXml()}
$EventData = Foreach ($event in $xml.Event)
{ New-Object PSObject -Property @{
"Time connections" = (Get-Date ($event.System.TimeCreated.SystemTime) -Format 'yyyy-MM-dd hh:mm K')
"Name of user" = $event.UserData.EventXML.Param1
"The address is customer" = $event.UserData.EventXML.Param3
}} $EventData | Out-Gridview -Title "RDP Connection History on Server $srv"
}

function event-power {
Get-WinEvent -ComputerName $srv -FilterHashtable @{logname='System';id=1074} | select TimeCreated,Message | Out-Gridview -Title "Power Logs on Server $srv"
}
#endregion

#region functions-time
function net-time {
$net_time = net time \\$srv
$regtime = $net_time -match "$srv"
$regtime = $regtime -replace "$srv"
$regtime = $regtime -replace "Current time at \\\\ is "
$global:nettime = $regtime
$Status.Text = "The current Time on Server $srv is $nettime. "

$span = new-timespan -Start (get-date) -end (icm $srv {get-date})
[string]$diff = $span.TotalSeconds
$Status.Text += "Time difference: $diff seconds"
}

function check-time {
[string]$in_time = icm $srv {w32tm /query /status}
if ($in_time -match "Last") {
[string]$in_time = $in_time -replace ".+(?<= Last)"
[string]$in_time = $in_time -replace "^","Last"
} else {
[string]$in_time = icm $srv {w32tm /query /source}
}
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("$in_time",0,"Status $srv",64)
}

function time-test {
$in_time = w32tm /stripchart /computer:$srv /dataonly /samples:1
if ($in_time -match "0x800705B4") {
$Status.Text = "Time source error $srv"
} else {$Status.Text = "No time source error $srv"}
}

function sync-domain {
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("
To make the time source domain, click yes
Specify external source, press no",0, "Select action for Server $srv",3)
if ($output -eq "6") {sync-PDC}
if ($output -eq "7") {sync-external}
}

function sync-external {
$session = New-PSSession $srv
$servertime = Read-Host "Enter Name Server"
icm -Session $session {$servertime = $using:servertime}
if ($servertime -ne $null) {icm -Session $session {w32tm.exe /config /manualpeerlist:"$servertime,0x8" /syncfromflags:manual /reliable:yes /update}}
icm -Session $session {Get-Service | Where {$_.Name -match "w32time"} | restart-service}
Remove-PSSession $session
$Status.Text = "$servertime selected as an external time source"
}

function sync-PDC {
$session = New-PSSession $srv
icm -Session $session {Get-Service | Where {$_.Name -match "w32time"} | stop-service}
$Status.Text = "10%...Stop Services"; sleep 5
icm -Session $session {w32tm.exe /unregister}
$Status.Text = "20%...Reset Settings"; sleep 10
$Status.Text = "30%...Reset Settings"; sleep 10
$Status.Text = "40%...Reset Settings"; sleep 5
$Status.Text = "50%...Setting up"; sleep 5
icm -Session $session {w32tm.exe /register}
$Status.Text = "60%...Setting up"; sleep 5
$Status.Text = "70%...Setting up"; sleep 5
icm -Session $session {Get-Service | Where {$_.Name -match "w32time"} | start-service}
$Status.Text = "80%...Setting up"; sleep 5
icm -Session $session {w32tm /config /syncfromflags:domhier /update}
$Status.Text = "90%...Launch Services"; sleep 5
icm -Session $session {Get-Service | Where {$_.Name -match "w32time"} | restart-service}
Remove-PSSession $session
$Status.Text = "100%...Done"
}

function sync-time {
icm $srv {w32tm /resync /rediscover}
$Status.Text = "Sync by"
}
#endregion

#region functions-kms
function kms-status {
$wmios = gwmi Win32_OperatingSystem -computername $srv
$os = $wmios.Caption

$check = icm $srv {Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where {$_.PartialProductKey}}
$kms_ver = $check.LicenseFamily
$kms_channel = $check.Description
$kms_key = $check.ProductKeyChannel
$kms_check = $check.LicenseStatus
if ($kms_check -eq 0) {$kms_status = "Server is not activated"}
if ($kms_check -eq 1) {$kms_status = "Server activated"}
if ($kms_check -eq 2) {$kms_status = "OOBGrace"}
if ($kms_check -eq 3) {$kms_status = "OOTGrace (cannot be activated automatically or more than 180 days have passed)"}
if ($kms_check -eq 4) {$kms_status = "NonGenuineGrace"}
if ($kms_check -eq 5) {$kms_status = "The trial period for Windows is over"}
if ($kms_check -eq 6) {$kms_status = "ExtendedGrace (You can extend the trial version of Windows several times by using the slmgr /rearm)"}

$kms_ip = $check.DiscoveredKeyManagementServiceMachineIpAddress
if ($check.DiscoveredKeyManagementServiceMachineName -gt 0) {$kms_name = $check.DiscoveredKeyManagementServiceMachineName}
if ($check.KeyManagementServiceMachine -gt 0) 				{$kms_name = $check.KeyManagementServiceMachine}
if ($check.DiscoveredKeyManagementServiceMachinePort -gt 0) {$kms_port = $check.DiscoveredKeyManagementServiceMachinePort}
if ($check.KeyManagementServicePort -gt 0) 					{$kms_port = $check.KeyManagementServicePort}
$ip_port = "$kms_ip"+":"+"$kms_port"

$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup(
"Operating System: $os
Edited by: $kms_ver
Channel: $kms_channel
Key: $kms_key
Status: $kms_status ($kms_check)
Server licenses: $kms_name ($ip_port)",
64,"$srv")
}

function kms-domain {
$kms_domain = nslookup -type=srv _vlmcs._tcp.$domain
#$kms_domain = $kms_domain -Match "(hostname|port)"
$kms_domain = $kms_domain -Match "(hostname)"
[string]$kms_domain = $kms_domain -replace ".+(?<== )"
$Status.Text = "The address is KMS-Server $kms_domain in the domain $domain"
}

function gvlk-managment {
$main_form_gvlk = New-Object System.Windows.Forms.Form
$main_form_gvlk.Text = "GVLK activator"
$main_form_gvlk.ShowIcon = $false
$main_form_gvlk.StartPosition = "CenterScreen"
$main_form_gvlk.Font = "$Font,$Size"
$main_form_gvlk.ForeColor = "Black"
$main_form_gvlk.Size = New-Object System.Drawing.Size(290,390)
$main_form_gvlk.AutoSize = $true

$ListBox_gvlk = New-Object System.Windows.Forms.ListBox
$ListBox_gvlk.Location  = New-Object System.Drawing.Point(10,10)
$ListBox_gvlk.Size = New-Object System.Drawing.Size(250,300)
$ListBox_gvlk.Items.Add("Windows Server 2016 Datacenter")
$ListBox_gvlk.Items.Add("Windows Server 2016 Standart")
$ListBox_gvlk.Items.Add("Windows Server 2019 Datacenter")
$ListBox_gvlk.Items.Add("Windows Server 2019 Standart")
$ListBox_gvlk.Items.Add("Windows Server 2022 Datacenter")
$ListBox_gvlk.Items.Add("Windows Server 2022 Standart")
$ListBox_gvlk.Items.Add("Windows 10 Professional")
$main_form_gvlk.Controls.add($ListBox_gvlk)

$button_gvlk = New-Object System.Windows.Forms.Button
$button_gvlk.Text = "Select"
$button_gvlk.Location = New-Object System.Drawing.Point(10,310)
$button_gvlk.Size = New-Object System.Drawing.Size(100,30)
$main_form_gvlk.Controls.Add($button_gvlk)

$button_gvlk.Add_Click({
$global:gvlk_key = $ListBox_gvlk.selectedItem
$main_form_gvlk.close()
})

$main_form_gvlk.ShowDialog()

if ($gvlk_key -eq "Windows Server 2016 Datacenter") {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk CB7KF-BWN84-R7R2Y-793K2-8XDDG}}
if ($gvlk_key -eq "Windows Server 2016 Standart")   {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY}}
if ($gvlk_key -eq "Windows Server 2019 Datacenter") {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk WMDGN-G9PQG-XVVXX-R3X43-63DFG}}
if ($gvlk_key -eq "Windows Server 2019 Standart")   {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk N69G4-B89J2-4G8F4-WWYCC-J464C}}
if ($gvlk_key -eq "Windows Server 2022 Datacenter") {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk WX4NM-KYWYW-QJJR4-XV3QB-6VM33}}
if ($gvlk_key -eq "Windows Server 2022 Standart")   {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk VDYBN-27WPP-V4HQT-9VMD4-VMK7H}}
if ($gvlk_key -eq "Windows 10 Professional")        {icm $srv {cscript $env:windir\system32\slmgr.vbs /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX}}
if ($gvlk_key -eq $null) {

$Status.Text = "Editor's note: This is not the editorial board."} else {
$Status.Text = "Activating the public key Generic Volume License Key for edit $gvlk_key is executed"}
$gvlk_key = $null
}

function kms-server {
$kms_srv_enter = Read-Host "Enter The address is KMS-Server"
$Status.Text = "Selected KMS-Server: $kms_srv_enter"
$port_default = "1688"
$kms_srv_port = "$kms_srv_enter"+":"+"$port_default"
$session = New-PSSession $srv
icm -Session $session {$kms_srv_port = $using:kms_srv_port}
icm -Session $session {cscript $env:windir\system32\slmgr.vbs /skms $kms_srv_port}
Remove-PSSession $session
}

function kms-lic {
icm $srv {cscript $env:windir\system32\slmgr.vbs /ato}
$Status.Text = "Activation complete"
}
#endregion

#region functions-wmi
function wim-disk {
$DataGridView.DataSource = $null
$DataGridView.Rows.Clear()
$DataGridView.ColumnCount = 0
$disk = gwmi Win32_logicalDisk -ComputerName $srv | select @{Label="Section"; Expression={$_.DeviceID}}, @{Label="Total"; Expression={[string]([int]($_.Size/1Gb))+" GB"}},`
@{Label="Available at"; Expression={[string]([int]($_.FreeSpace/1Gb))+" GB"}}, @{Label="Available at %"; Expression={[string]([int]($_.FreeSpace/$_.Size*100))+" %"}}
$list = New-Object System.collections.ArrayList
$list.AddRange($disk)
$dataGridView.DataSource = $list
$DataGridView.Rows | ForEach-Object {
if ($_.Cells["Available at %"].Value -gt "15") {
$_.Cells[3] | %{$_.Style.BackColor = "lightgreen"}
} elseif ($_.Cells["Available at %"].Value -eq $null) {
} elseif ($_.Cells["Available at %"].Value -le "15") {
$_.Cells[3] | %{$_.Style.BackColor = "pink"}
}}
}

function wim-mem {
$memory = Invoke-Command -ComputerName $srv -ScriptBlock {Get-ComputerInfo | select @{Label="ALL"; `
Expression={[string]($_.CsPhyicallyInstalledMemory/1mb)+" GByte"}}, `
@{Label="FREE"; Expression={[string]([int]($_.OsFreePhysicalMemory/1kb))+" Mbytes"}}}
$DataGridView.DataSource = $null
$DataGridView.Rows.Clear()
$DataGridView.ColumnCount = 2
$DataGridView.Columns[0].Name = "Total"
$DataGridView.Columns[1].Name = "Available at"
$DataGridView.Rows.Add($memory.all,$memory.free)
#$DataGridView.Rows.Cells[0].Style.BackColor = "lightgreen"
#$DataGridView.Rows.Cells[1].Style.BackColor = "pink"
}

function wmi-soft {
$soft_wmi = gwmi Win32_Product -ComputerName $srv | select Name,Version,Vendor,InstallDate,InstallLocation,InstallSource | `
sort -Descending InstallDate | Out-Gridview -Title "Programs on Server $srv" –PassThru
$soft_wmi_uninstall = $soft_wmi.Name
$wshell = New-Object -ComObject Wscript.Shell
if ($soft_wmi_uninstall -ne $null) {
$output = $wshell.Popup("Delete $soft_wmi_uninstall on Server $srv ?",0,"Select an action",4)
}
if ($output -eq "6") {
$uninstall = (gwmi Win32_Product -ComputerName $srv -Filter "Name = '$soft_wmi_uninstall'").Uninstall()
}
if ($uninstall.ReturnValue -eq 0) {$Status.text = "Deleting $soft_wmi_uninstall on Server $srv performed"} else {
$Status.text = "Deletion error ($uninstall.ReturnValue)"
}}

function openfile {
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Filter = "msi (*.msi)|*.msi"
$OpenFileDialog.InitialDirectory = ".\"
$OpenFileDialog.Title = "Select a file"
$getKey = $OpenFileDialog.ShowDialog()
[string]$global:path_msi = $OpenFileDialog.FileNames
[string]$global:name_msi = $OpenFileDialog.SafeFileName
$status.Text = "Selected file: $path_msi"
}

function wmi-install {
openfile
$wshell = New-Object -ComObject Wscript.Shell
if ($path_msi -ne $null) {
$output = $wshell.Popup("Install $name_msi on Server $srv ?",0,"Select an action",4)
}
if ($output -eq "6") {wmi-installer}
}

function wmi-installer {
#$Status.Text = "The process of installing $name_msi on Server $srv"
#$install = Invoke-CimMethod -ComputerName $srv -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation=$path_msi}
#$install_out = $install.ReturnValue
#if ($install_out -eq "0") {$status.Text = "Installation of $name_msi on Server $srv succeeded"} else {
#$status.Text = "Installation error ($install_out)"}
############################################################
#$Status.Text = "Running the installation process $name_msi on Server $srv"
#$install = (Get-WMIObject -Authentication PacketPrivacy -ComputerName $srv -List | Where-Object -FilterScript {$_.Name -eq "Win32_Product"}).Install($path_msi)
#$install_out = $install.ReturnValue # pick up the output
#if ($install_out -eq "0") {$status.Text = "Installation of $name_msi on Server $srv succeeded"} else {
#$status.Text = "Installation error ($install_out)"}
############################################################
$session = New-PSSession $srv
icm -Session $session {$path_msi = $using:path_msi}
$Status.Text = "The installation process is started $name_msi on Server $srv"
$install = icm -Session $session {Install-Package -Name $path_msi -Force -Verbose}
icm -Session $session {$path_msi = $null}
Disconnect-PSSession $session
Remove-PSSession $session
$path_msi = $null
[string]$inst_out = $install.Status
if ($install -ne $null) {$Status.Text = "Installation completed ($inst_out)"} else {$Status.Text = "Installation error"}
}

function wmi-upd {
$HotFixID = Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName "$srv" | sort InstalledOn
$DataGridView.DataSource = $null
$DataGridView.Rows.Clear()
$DataGridView.ColumnCount = 4
$DataGridView.Columns[0].Name = "HotFixID"
$DataGridView.Columns[1].Name = "Description"
$DataGridView.Columns[2].Name = "InstalledBy"
$DataGridView.Columns[3].Name = "InstalledOn"
$Service_dgv = foreach ($upd in $HotFixID) {
$DataGridView.Rows.Add($upd.HotFixID,$upd.Description,$upd.InstalledBy,$upd.InstalledOn)
}

$ContextMenu_services = New-Object System.Windows.Forms.ContextMenu
$ContextMenu_services.MenuItems.Add("Copy",{
$dgv_selected_upd = $DataGridView.SelectedCells.Value
Set-Clipboard $dgv_selected_upd
$status.Text = "Update $dgv_selected_upd copied to clipboard, use to search in DISM"
})
$main_form.ContextMenu = $ContextMenu_services
}

function wmi-drivers {
$drivers = gwmi -ComputerName $srv Win32_SystemDriver
$DataGridView.DataSource = $null
$DataGridView.Rows.Clear()
$DataGridView.ColumnCount = 3
$DataGridView.Columns[0].Name = "Name"
$DataGridView.Columns[1].Name = "Display Name"
$DataGridView.Columns[2].Name = "Status"
$Service_dgv = foreach ($drs in $drivers) {
$DataGridView.Rows.Add($drs.Name,$drs.DisplayName,$drs.State)
}
$DataGridView.Rows | ForEach-Object {
if ($_.Cells["Status"].Value -eq "Running") {
$_.Cells[2] | %{$_.Style.BackColor = "lightgreen"}
} elseif ($_.Cells["Status"].Value -eq "Stopped") {
$_.Cells[2] | %{$_.Style.BackColor = "pink"}
}}
}

function wmi-report {
$path = "C:\Users\$env:UserName\desktop\$srv-Report.html"
$date = Get-Date
$space += "Operating system:"
$space += gwmi Win32_OperatingSystem -computername $srv | ConvertTo-HTML -As list Caption,Version
$space += "Motherboard:"
$space += gwmi Win32_BaseBoard -computername $srv | ConvertTo-HTML -As list Manufacturer,Product
$space += "Processor:"
$space += gwmi Win32_Processor -computername $srv | ConvertTo-HTML -As list Name, @{Label="Cores"; Expression={$_.NumberOfCores}}, @{Label="LogicalCPUs"; Expression={$_.NumberOfLogicalProcessors}}
$space += "Main memory:"
$space += gwmi Win32_PhysicalMemory -computername $srv | ConvertTo-HTML -As list DeviceLocator, @{Label="Memory"; Expression={[string]($_.Capacity/1Mb)+" Mbytes"}}
$space += "Drive model:"
$space += gwmi Win32_DiskDrive -computername $srv | ConvertTo-HTML -As list Model
$space += "Video card:"
$space += gwmi Win32_VideoController -computername $srv | ConvertTo-HTML -As list Name,CurrentHorizontalResolution,CurrentVerticalResolution,DriverVersion,`
@{Label="vRAM"; Expression={[string]($_.AdapterRAM/1Gb)+" GByte"}}
#$space += "Network adapter:"
#$space += gwmi Win32_NetworkAdapter -computername $srv | ConvertTo-HTML -As list Name,Macaddress
$space += @("Report date: $date")
$space | Out-File $path
Invoke-Item $path
}

function wmi-share {
$DataGridView.DataSource = $null
$DataGridView.Rows.Clear()
$DataGridView.ColumnCount = 0
$share = Get-WmiObject -ComputerName $srv -Class Win32_Share | Select Name,Path
$list = New-Object System.collections.ArrayList
$list.AddRange($share)
$dataGridView.DataSource = $list

$ContextMenu_services = New-Object System.Windows.Forms.ContextMenu
$ContextMenu_services.MenuItems.Add("Open",{
$dgv_selected_share = $DataGridView.SelectedCells.Value
$path_smb = "\\$srv\"+"$dgv_selected_share"
ii $path_smb
})
$main_form.ContextMenu = $ContextMenu_services
}

function wmi-rdp {
$rdp = Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -Computer $srv -Authentication 6
$rdp_status = $rdp.AllowTSConnections
if ($rdp_status -eq 1) {$rdp_var = "included"} elseif ($rdp_status -eq 0) {$rdp_var = "disabled"}
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Remote connection - $rdp_var, on Server $srv`
press yes to turn on or no to turn off",0,"Select an action",3)
if ($output -eq "6") {
(Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -Computer $srv `
-Authentication 6).SetAllowTSConnections(1,1)
}
if ($output -eq "7") {
(Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace root\CIMV2\TerminalServices -Computer $srv `
-Authentication 6).SetAllowTSConnections(0,0)
}
}

function wmi-nla {
$nla = (Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\Terminalservices -ComputerName $srv `
-Filter "TerminalName='RDP-tcp'")
if ($nla.UserAuthenticationRequired -eq 1) {$nla_out = "included"}
if ($nla.UserAuthenticationRequired -eq 0) {$nla_out = "off"}
$wshell = New-Object -ComObject Wscript.Shell
$output = $wshell.Popup("Network Level Authentication - $nla_out, on Server $srv`
press yes to turn on or no to turn off",0,"Select an action",3)
if ($output -eq "6") {
(Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\Terminalservices -ComputerName $srv `
-Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(1)
}
if ($output -eq "7") {
(Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\Terminalservices -ComputerName $srv `
-Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)
}
}
#endregion

#region cred
function srv-cred {
$user = $env:USERDNSDOMAIN + "\" + $env:username
$cred = Get-Credential $user
$global:username = $Cred.UserName
$global:password = $Cred.GetNetworkCredential().password
if ($password -ne $null) {$Status.Text = "Authorization performed by the user: $username"}
if ($password -eq $null) {$Status.Text = "Authorization failed"}
}
#endregion

#region srv-list
$GroupBox_srv = New-Object System.Windows.Forms.GroupBox
$GroupBox_srv.Text = "List of Servers"
$GroupBox_srv.AutoSize = $true
$GroupBox_srv.Location  = New-Object System.Drawing.Point(10,55)
$GroupBox_srv.Size = New-Object System.Drawing.Size(300,615)
$main_form.Controls.Add($GroupBox_srv)

$ListBox = New-Object System.Windows.Forms.ListBox
$ListBox.Location  = New-Object System.Drawing.Point(10,25)
$ListBox.Size = New-Object System.Drawing.Size(280,480)
list-update
$GroupBox_srv.Controls.add($ListBox)

$ContextMenu = New-Object System.Windows.Forms.ContextMenu
$ContextMenu.MenuItems.Add("Update",{list-update})
$ContextMenu.MenuItems.Add("List of Servers",{ii $conf})
$ContextMenu.MenuItems.Add("List of Servers domain",{list-domain})
$ListBox.ContextMenu = $ContextMenu

$button_1 = New-Object System.Windows.Forms.Button
$button_1.Text = " Check"
$button_1.Image = $ico_usr
$button_1.ImageAlign = "MiddleLeft"
$button_1.Location = New-Object System.Drawing.Point(8,505)
$button_1.Size = New-Object System.Drawing.Size(170,40)
$GroupBox_srv.Controls.Add($button_1)

$button_1.Add_Click({
$button_1.Enabled = $false
$global:srv = $ListBox.selectedItem
fun-main
})

$button_mstsc = New-Object System.Windows.Forms.Button
$button_mstsc.Text = "       Connect"
$button_mstsc.Image = $ico_rdp
$button_mstsc.ImageAlign = "MiddleLeft"
$button_mstsc.Location = New-Object System.Drawing.Point(8,550)
$button_mstsc.Size = New-Object System.Drawing.Size(170,40)
$GroupBox_srv.Controls.Add($button_mstsc)

$button_mstsc.Add_Click({
$Status.Text = "Connecting to Server: $srv"
if ($password -ne $Null) {
cmdkey /generic:"TERMSRV/$srv" /user:"$username" /pass:"$password"
}
mstsc /admin /v:$srv
Start-Sleep -Seconds 1
cmdkey /delete:"TERMSRV/$srv"
})
#endregion

#region user-dgv
$GroupBox_usr = New-Object System.Windows.Forms.GroupBox
$GroupBox_usr.Text = "List of users"
$GroupBox_usr.AutoSize = $true
$GroupBox_usr.Location  = New-Object System.Drawing.Point(320,55)
$GroupBox_usr.Size = New-Object System.Drawing.Size(660,615)
$main_form.Controls.Add($GroupBox_usr)

$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Location = New-Object System.Drawing.Point(10,25)
$dataGridView.Size = New-Object System.Drawing.Size(640,470)
$dataGridView.AutoSizeColumnsMode = "Fill" 
$dataGridView.Font = "$Font,10"
$dataGridView.AutoSize = $false
$dataGridView.MultiSelect = $false
$dataGridView.ReadOnly = $true
$GroupBox_usr.Controls.Add($dataGridView)

$button_2 = New-Object System.Windows.Forms.Button
$button_2.Text = "       Connect"
$button_2.Location = New-Object System.Drawing.Point(8,505)
$button_2.Size = New-Object System.Drawing.Size(170,40)
$button_2.Image = [System.IconExtractor]::Extract("imageres.dll", 194, $true)
#$button_2.Image = [System.IconExtractor]::Extract("dsuiext.dll", 12, $true)
#$button_2.Image = [System.IconExtractor]::Extract("shell32.dll", 174, $true)
$button_2.ImageAlign = "MiddleLeft"
$GroupBox_usr.Controls.Add($button_2)

$button_2.Add_Click({
$id = $dataGridView.SelectedCells.Value
$obj_usr = $obj | Where {$_.ID -match $id}
$obj_usr = $obj_usr.Name
$wshell = New-Object -ComObject Wscript.Shell
if ($obj_usr -gt 1) {
$output = $wshell.Popup("Request permission to connect to the user $obj_usr ?",0,"Select an action",3)
} else {
$output = $wshell.Popup("ID not selected in the list",0,"Attention",64)
}
if ($output -eq "6") {mstsc /shadow:$id /v:$srv /control}
if ($output -eq "7") {mstsc /shadow:$id /v:$srv /control /noconsentprompt}
})

$button_3 = New-Object System.Windows.Forms.Button
$button_3.Text = " Disable"
$button_3.Location = New-Object System.Drawing.Point(8,550)
$button_3.Size = New-Object System.Drawing.Size(170,40)
$button_3.Image = [System.IconExtractor]::Extract("dsuiext.dll", 27, $true)
$button_3.ImageAlign = "MiddleLeft"
$GroupBox_usr.Controls.Add($button_3)

$button_3.Add_Click({
$id = $dataGridView.SelectedCells.Value
$obj_usr = $obj | Where {$_.ID -match $id}
$obj_usr = $obj_usr.Name
$wshell = New-Object -ComObject Wscript.Shell
if ($obj_usr -gt 1) {
$Output = $wshell.Popup("Disconnect user $obj_usr ?",0,"Select an action",4)
} else {
$output = $wshell.Popup("ID not selected in the list",0,"Attention",64)
}
if ($output -eq "6") {logoff $id /server:$srv /v}
Get-Query
get-obj
})
#endregion

#region message
$watermark_Message = "Enter a message to send to users"
$outputBox_Enter = {
if ($outputBox_message.Text -like $watermark_Message) {
$outputBox_message.Text = ""
$outputBox_message.ForeColor = [System.Drawing.SystemColors]::WindowText
}}
$outputBox_Leave = {
if ($outputBox_message.Text -like "") {
$outputBox_message.Text = $watermark_Message
$outputBox_message.ForeColor = [System.Drawing.Color]::LightGray
}}

$outputBox_message = New-Object System.Windows.Forms.TextBox
$outputBox_message.Location = New-Object System.Drawing.Point(190,505)
$outputBox_message.Size = New-Object System.Drawing.Size(300,85)
$outputBox_message.MultiLine = $True
$outputBox_message.Font = "$Font,11"
$outputBox_message.ForeColor = [System.Drawing.Color]::LightGray 
$outputBox_message.add_Enter($outputBox_Enter)
$outputBox_message.add_Leave($outputBox_Leave)
$outputBox_message.Text = $watermark_Message
$GroupBox_usr.Controls.Add($outputBox_message)

$VScrollBar = New-Object System.Windows.Forms.VScrollBar
$outputBox_message.Scrollbars = "Vertical"

$button_6 = New-Object System.Windows.Forms.Button
$button_6.Text = "   Send"
$button_6.Location = New-Object System.Drawing.Point(500,505)
$button_6.Size = New-Object System.Drawing.Size(150,85)
$button_6.Image = [System.IconExtractor]::Extract("accessibilitycpl.dll", 1, $true)
$button_6.ImageAlign = "MiddleLeft"
$GroupBox_usr.Controls.Add($button_6)

$button_6.Add_Click({
$id = $dataGridView.SelectedCells.Value
$obj_usr = $obj | Where {$_.ID -match $id}
$obj_usr = $obj_usr.Name
$text = $outputBox_message.Text
$wshell = New-Object -ComObject Wscript.Shell
if ($obj_usr -gt 1) {
$output = $wshell.Popup("To send a message to all users, click yes`
To the user $obj_usr, press no`
on Server: $srv",0,"Select an action",3)
} else {
$output = $wshell.Popup("Not Selected ID in the list",0, "Warning",64)
}
if ($output -eq "6") {msg * /server:$srv $text}
if ($output -eq "7") {msg $id /server:$srv $text}
if ($lastexitcode -eq 0) {$Status.Text = "Message sent"} else {$Status.Text = "No message sent"}
})
#endregion

#region menu-file
$Menu = New-Object System.Windows.Forms.MenuStrip
$Menu.BackColor = "white"
$main_form.MainMenuStrip = $Menu
$main_form.Controls.Add($Menu)

$menuItem_file = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file.Text = "File" 
$Menu.Items.Add($menuItem_file)

$menuItem_file_cred = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_cred.Text = "Authentication"
$menuItem_file_cred.Image = [System.IconExtractor]::Extract("shell32.dll", 44, $true)
$menuItem_file_cred.ShortcutKeys = "Control, A"
$menuItem_file_cred.Add_Click({srv-cred})
$menuItem_file.DropDownItems.Add($menuItem_file_cred)

$menuItem_file_pad = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_pad.Text = "List of Servers"
$menuItem_file_pad.Image = $ico_pad
$menuItem_file_pad.ShortcutKeys = "Control, S"
$menuItem_file_pad.Add_Click({ii $conf})
$menuItem_file.DropDownItems.Add($menuItem_file_pad)

$menuItem_file_update = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_update.Text = "Update"
$menuItem_file_update.ShortcutKeys = "Control, R"
$menuItem_file_update.Add_Click({list-update})
$menuItem_file.DropDownItems.Add($menuItem_file_update)

$menuItem_file_domain = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_domain.Text = "List of domain severs"
$menuItem_file_domain.ShortcutKeys = "Control, D"
$menuItem_file_domain.Add_Click({list-domain})
$menuItem_file.DropDownItems.Add($menuItem_file_domain)

$menuItem_file_domain_table = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_domain_table.Text = "Domain Severs table"
$menuItem_file_domain_table.ShortcutKeys = "Control, T"
$menuItem_file_domain_table.Add_Click({domain-comp})
$menuItem_file.DropDownItems.Add($menuItem_file_domain_table)

$menuItem_file_broker = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_broker.Text = "Connection Broker"
$menuItem_file_broker.ShortcutKeys = "Control, B"
$menuItem_file_broker.Add_Click({broker-user})
$menuItem_file.DropDownItems.Add($menuItem_file_broker)

$menuItem_file_exit = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_file_exit.Text = "Exit"
$menuItem_file_exit.ShortcutKeys = "Control, W"
$menuItem_file_exit.Add_Click({$main_form.Close()})
$menuItem_file.DropDownItems.Add($menuItem_file_exit)
#endregion

#region menu-admin
$menuItem_admin = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin.Text = "Administering" 
$Menu.Items.Add($menuItem_admin)

$menuItem_admin_comp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_comp.Text = "Managing"
$menuItem_admin_comp.Image = [System.IconExtractor]::Extract("imageres.dll", 186, $true)
$menuItem_admin_comp.Add_Click({comp-manager})
$menuItem_admin.DropDownItems.Add($menuItem_admin_comp)

$menuItem_admin_services = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_services.Text = "Services"
$menuItem_admin_services.Image = [System.IconExtractor]::Extract("imageres.dll", 109, $true)
$menuItem_admin_services.Add_Click({
services-view-ogv
})
$menuItem_admin.DropDownItems.Add($menuItem_admin_services)

$menuItem_admin_process = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_process.Text = "Processes"
$menuItem_admin_process.Image = [System.IconExtractor]::Extract("imageres.dll", 144, $true)
$menuItem_admin_process.Add_Click({
process-users-ogv
})
$menuItem_admin.DropDownItems.Add($menuItem_admin_process)

$menuItem_admin_software_remove = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_software_remove.Text = "Programs"
$menuItem_admin_software_remove.Image = [System.IconExtractor]::Extract("shell32.dll", 21, $true)
$menuItem_admin_software_remove.Add_Click({view-soft})
$menuItem_admin.DropDownItems.Add($menuItem_admin_software_remove)

$menuItem_admin_dism = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_dism.Text = "DISM Packages"
$menuItem_admin_dism.Image = [System.IconExtractor]::Extract("shell32.dll", 162, $true)
$menuItem_admin_dism.Add_Click({upd-dism})
$menuItem_admin.DropDownItems.Add($menuItem_admin_dism)

$menuItem_admin_SMB = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_SMB.Text = "SMB Open Files"
$menuItem_admin_SMB.Image = [System.IconExtractor]::Extract("imageres.dll", 169, $true)
$menuItem_admin_SMB.Add_Click({SMB-files-ogv})
$menuItem_admin.DropDownItems.Add($menuItem_admin_SMB)

$menuItem_admin_TCP = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_TCP.Text = "TCP Viewer"
$menuItem_admin_TCP.Image = [System.IconExtractor]::Extract("imageres.dll", 20, $true)
$menuItem_admin_TCP.Add_Click({tcp-viewer})
$menuItem_admin.DropDownItems.Add($menuItem_admin_TCP)

$menuItem_admin_dnsz = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_dnsz.Text = "DNS Zone"
$menuItem_admin_dnsz.Add_Click({get-dns-zone})
$menuItem_admin.DropDownItems.Add($menuItem_admin_dnsz)

$menuItem_admin_gpu = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_gpu.Text = "GP Update"
$menuItem_admin_gpu.Add_Click({gp-upd})
$menuItem_admin.DropDownItems.Add($menuItem_admin_gpu)

$menuItem_admin_gpr = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_admin_gpr.Text = "GP Result"
$menuItem_admin_gpr.Add_Click({gp-res})
$menuItem_admin.DropDownItems.Add($menuItem_admin_gpr)
#endregion

#region menu-power
$menuItem_power = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power.Text = "Nutrition" 
$Menu.Items.Add($menuItem_power)

$menuItem_power_reboot = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_reboot.Text = "Reload"
$menuItem_power_reboot.Image = [System.IconExtractor]::Extract("shell32.dll", 238, $true)
$menuItem_power_reboot.Add_Click({power-reboot})
$menuItem_power.DropDownItems.Add($menuItem_power_reboot)

$menuItem_power_off = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_off.Text = "Turn off"
$menuItem_power_off.Image = [System.IconExtractor]::Extract("shell32.dll", 27, $true)
$menuItem_power_off.Add_Click({power-off})
$menuItem_power.DropDownItems.Add($menuItem_power_off)

$menuItem_power_cancel = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_cancel.Text = "Cancel"
$menuItem_power_cancel.Image = [System.IconExtractor]::Extract("imageres.dll", 255, $true)
$menuItem_power_cancel.Add_Click({power-cancel})
$menuItem_power.DropDownItems.Add($menuItem_power_cancel)

$menuItem_power_monitor = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_monitor.Text = "Screen lock"
$menuItem_power_monitor.Add_Click({power-monitor})
$menuItem_power.DropDownItems.Add($menuItem_power_monitor)

$menuItem_power_standby = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_standby.Text = "Sleep mode"
$menuItem_power_standby.Add_Click({power-standby})
$menuItem_power.DropDownItems.Add($menuItem_power_standby)

$menuItem_power_mac = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_mac.Text = "Get-MAC-Proxy"
$menuItem_power_mac.Add_Click({get-mac-proxy})
$menuItem_power.DropDownItems.Add($menuItem_power_mac)

$menuItem_power_dhcp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_dhcp.Text = "Get-DHCP"
$menuItem_power_dhcp.Add_Click({get-dhcp})
$menuItem_power.DropDownItems.Add($menuItem_power_dhcp)

$menuItem_power_wol = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_power_wol.Text = "Wake-on-Lan"
$menuItem_power_wol.Add_Click({power-wol})
$menuItem_power.DropDownItems.Add($menuItem_power_wol)
#endregion

#region menu-event
$menuItem_event = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_event.Text = "Logs" 
$Menu.Items.Add($menuItem_event)

$menuItem_event_sys = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_event_sys.Text = "System"
$menuItem_event_sys.Add_Click({event-sys})
$menuItem_event.DropDownItems.Add($menuItem_event_sys)

$menuItem_event_app = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_event_app.Text = "Applications"
$menuItem_event_app.Add_Click({event-app})
$menuItem_event.DropDownItems.Add($menuItem_event_app)

$menuItem_event_conn = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_event_conn.Text = "RDP-connections"
$menuItem_event_conn.Add_Click({rdp-con})
$menuItem_event.DropDownItems.Add($menuItem_event_conn)

$menuItem_event_power = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_event_power.Text = "Nutrition"
$menuItem_event_power.Add_Click({event-power})
$menuItem_event.DropDownItems.Add($menuItem_event_power)
#endregion

#region menu-time
$menuItem_Time = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time.Text = "Time" 
$Menu.Items.Add($menuItem_Time)

$menuItem_Time_Time = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time_Time.Text = "Time"
$menuItem_Time_Time.Image = [System.IconExtractor]::Extract("shell32.dll", 239, $true)
$menuItem_Time_Time.Add_Click({net-time})
$menuItem_Time.DropDownItems.Add($menuItem_Time_Time)

$menuItem_Time_Check_Time = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time_Check_Time.Text = "Source of time"
$menuItem_Time_Check_Time.Image = $ico_time
$menuItem_Time_Check_Time.Add_Click({check-time})
$menuItem_Time.DropDownItems.Add($menuItem_Time_Check_Time)

$menuItem_Time_Test_Time = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time_Test_Time.Text = "Check source"
$menuItem_Time_Test_Time.Add_Click({time-test})
$menuItem_Time.DropDownItems.Add($menuItem_Time_Test_Time)

$menuItem_Time_Sync_Domain = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time_Sync_Domain.Text = "Change Source"
$menuItem_Time_Sync_Domain.Add_Click({sync-domain})
$menuItem_Time.DropDownItems.Add($menuItem_Time_Sync_Domain)

$menuItem_Time_Sync_Time = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_Time_Sync_Time.Text = "Synchronize time"
$menuItem_Time_Sync_Time.Add_Click({sync-time})
$menuItem_Time.DropDownItems.Add($menuItem_Time_Sync_Time)
#endregion

#region menu-kms
$menuItem_kms = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms.Text = "KMS" 
$Menu.Items.Add($menuItem_kms)

$menuItem_kms_status = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms_status.Text = "License"
$menuItem_kms_status.Image = [System.IconExtractor]::Extract("accessibilitycpl.dll", 14, $true)
$menuItem_kms_status.Add_Click({kms-status})
$menuItem_kms.DropDownItems.Add($menuItem_kms_status)

$menuItem_kms_domain = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms_domain.Text = "Server domain"
$menuItem_kms_domain.Add_Click({kms-domain})
$menuItem_kms.DropDownItems.Add($menuItem_kms_domain)

$menuItem_kms_gvlk = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms_gvlk.Text = "GVLK activator"
$menuItem_kms_gvlk.Add_Click({gvlk-managment})
$menuItem_kms.DropDownItems.Add($menuItem_kms_gvlk)

$menuItem_kms_srv = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms_srv.Text = "Specify KMS-Server"
$menuItem_kms_srv.Add_Click({kms-server})
$menuItem_kms.DropDownItems.Add($menuItem_kms_srv)

$menuItem_kms_lic = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_kms_lic.Text = "Get a license"
$menuItem_kms_lic.Add_Click({kms-lic})
$menuItem_kms.DropDownItems.Add($menuItem_kms_lic)
#endregion

#region menu-wmi
$menuItem_wmi = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi.Text = "WMI" 
$Menu.Items.Add($menuItem_wmi)

$menuItem_wmi_disk = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_disk.Text = "Discs"
$menuItem_wmi_disk.Image = [System.IconExtractor]::Extract("imageres.dll", 293, $true)
$menuItem_wmi_disk.Add_Click({wim-disk})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_disk)

$menuItem_wmi_memory = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_memory.Text = "Memory"
$menuItem_wmi_memory.Image = [System.IconExtractor]::Extract("imageres.dll", 315, $true)
$menuItem_wmi_memory.Add_Click({wim-mem})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_memory)

$menuItem_wmi_software = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_software.Text = "Programs"
$menuItem_wmi_software.Image = $ico_soft
$menuItem_wmi_software.Add_Click({wmi-soft})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_software)

$menuItem_wmi_install = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_install.Text = "Installation"
$menuItem_wmi_install.Image = $ico_upd
$menuItem_wmi_install.Add_Click({wmi-install})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_install)

$menuItem_wmi_update = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_update.Text = "Updates"
$menuItem_wmi_update.Image = [System.IconExtractor]::Extract("shell32.dll", 46, $true)
$menuItem_wmi_update.Add_Click({wmi-upd})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_update)

$menuItem_wmi_drivers = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_drivers.Text = "Drivers"
$menuItem_wmi_drivers.Image = [System.IconExtractor]::Extract("imageres.dll", 142, $true)
$menuItem_wmi_drivers.Add_Click({wmi-drivers})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_drivers)

$menuItem_wmi_report = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_report.Text = "Inventory"
$menuItem_wmi_report.Image = [System.IconExtractor]::Extract("shell32.dll", 39, $true)
$menuItem_wmi_report.Add_Click({wmi-report})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_report)

$menuItem_wmi_share = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_share.Text = "Share"
$menuItem_wmi_share.Image = [System.IconExtractor]::Extract("imageres.dll", 205, $true)
$menuItem_wmi_share.Add_Click({wmi-share})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_share)

$menuItem_wmi_rdp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_rdp.Text = "RDP"
$menuItem_wmi_rdp.Add_Click({wmi-rdp})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_rdp)

$menuItem_wmi_nla = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem_wmi_nla.Text = "NLA"
$menuItem_wmi_nla.Add_Click({wmi-nla})
$menuItem_wmi.DropDownItems.Add($menuItem_wmi_nla)
#endregion

#region menu-2
$mainToolStrip = New-Object System.Windows.Forms.ToolStrip
$mainToolStrip.Location = New-Object System.Drawing.Point(0,25)
$mainToolStrip.ImageScalingSize = New-Object System.Drawing.Size(22,28)
$mainToolStrip.Size = New-Object System.Drawing.Size(1000,28)
$mainToolStrip.AutoSize = $false
$mainToolStrip.Anchor = "Top"
$main_form.Controls.Add($mainToolStrip)

$toolStripCred = New-Object System.Windows.Forms.ToolStripButton
$toolStripCred.ToolTipText = "Authentication"
$toolStripCred.Image = [System.IconExtractor]::Extract("shell32.dll", 44, $true)
$toolStripCred.Add_Click({srv-cred})
$mainToolStrip.Items.Add($toolStripCred)

$toolStripComp = New-Object System.Windows.Forms.ToolStripButton
$toolStripComp.ToolTipText = "Managing"
$toolStripComp.Image = [System.IconExtractor]::Extract("imageres.dll", 186, $true)
$toolStripComp.Add_Click({comp-manager})
$mainToolStrip.Items.Add($toolStripComp)

$toolStripDisk = New-Object System.Windows.Forms.ToolStripButton
$toolStripDisk.ToolTipText = "Discs"
$toolStripDisk.Image = [System.IconExtractor]::Extract("imageres.dll", 293, $true)
$toolStripDisk.Add_Click({wim-disk})
$mainToolStrip.Items.Add($toolStripDisk)

$toolStripMemory = New-Object System.Windows.Forms.ToolStripButton
$toolStripMemory.ToolTipText = "Memory"
$toolStripMemory.Image = [System.IconExtractor]::Extract("imageres.dll", 315, $true)
$toolStripMemory.Add_Click({wim-mem})
$mainToolStrip.Items.Add($toolStripMemory)

$toolStripShare = New-Object System.Windows.Forms.ToolStripButton
$toolStripShare.ToolTipText = "Share"
$toolStripShare.Image = [System.IconExtractor]::Extract("imageres.dll", 205, $true)
$toolStripShare.Add_Click({wmi-share})
$mainToolStrip.Items.Add($toolStripShare)

$toolStripSMB = New-Object System.Windows.Forms.ToolStripButton
$toolStripSMB.ToolTipText = "SMB Open Files"
$toolStripSMB.Image = [System.IconExtractor]::Extract("imageres.dll", 169, $true)
$toolStripSMB.Add_Click({SMB-files})
$mainToolStrip.Items.Add($toolStripSMB)

$toolStripServices = New-Object System.Windows.Forms.ToolStripButton
$toolStripServices.ToolTipText = "Services"
$toolStripServices.Image = [System.IconExtractor]::Extract("imageres.dll", 109, $true)
$toolStripServices.Add_Click({
$global:Service = Get-Service -computername "$srv" | Sort Name
$global:Service_search = $Service
services-view
services-search
})
$mainToolStrip.Items.Add($toolStripServices)

$toolStripProcess = New-Object System.Windows.Forms.ToolStripButton
$toolStripProcess.ToolTipText = "Processes"
$toolStripProcess.Image = [System.IconExtractor]::Extract("imageres.dll", 144, $true)
$toolStripProcess.Add_Click({
$global:process = Invoke-Command -ComputerName "$srv" -ScriptBlock {Get-Process -IncludeUserName} | sort -Descending UserName
$global:process_search = $process
process-users
process-search
})
$mainToolStrip.Items.Add($toolStripProcess)

$toolStripSoft = New-Object System.Windows.Forms.ToolStripButton
$toolStripSoft.ToolTipText = "Programs (Get-Package)"
$toolStripSoft.Image = [System.IconExtractor]::Extract("shell32.dll", 21, $true)
$toolStripSoft.Add_Click({view-soft})
$mainToolStrip.Items.Add($toolStripSoft)

$toolStripUpdate = New-Object System.Windows.Forms.ToolStripButton
$toolStripUpdate.ToolTipText = "Updates"
$toolStripUpdate.Image = [System.IconExtractor]::Extract("shell32.dll", 46, $true)
$toolStripUpdate.Add_Click({wmi-upd})
$mainToolStrip.Items.Add($toolStripUpdate)

$toolStripDISM = New-Object System.Windows.Forms.ToolStripButton
$toolStripDISM.ToolTipText = "DISM Packages"
$toolStripDISM.Image = [System.IconExtractor]::Extract("shell32.dll", 162, $true)
$toolStripDISM.Add_Click({upd-dism})
$mainToolStrip.Items.Add($toolStripDISM)

$toolStripDrivers = New-Object System.Windows.Forms.ToolStripButton
$toolStripDrivers.ToolTipText = "Drivers"
$toolStripDrivers.Image = [System.IconExtractor]::Extract("imageres.dll", 142, $true)
$toolStripDrivers.Add_Click({wmi-drivers})
$mainToolStrip.Items.Add($toolStripDrivers)

$toolStripTCP = New-Object System.Windows.Forms.ToolStripButton
$toolStripTCP.ToolTipText = "TCP Viewer"
$toolStripTCP.Image = [System.IconExtractor]::Extract("imageres.dll", 20, $true)
$toolStripTCP.Add_Click({TCP-Viewer})
$mainToolStrip.Items.Add($toolStripTCP)

$toolStripReport = New-Object System.Windows.Forms.ToolStripButton
$toolStripReport.ToolTipText = "Inventory"
$toolStripReport.Image = [System.IconExtractor]::Extract("shell32.dll", 39, $true)
$toolStripReport.Add_Click({wmi-report})
$mainToolStrip.Items.Add($toolStripReport)

$toolStripLog = New-Object System.Windows.Forms.ToolStripButton
$toolStripLog.ToolTipText = "Logs"
$toolStripLog.Image = $ico_event
$toolStripLog.Add_Click({event-vwr})
$mainToolStrip.Items.Add($toolStripLog)

$toolStripTime = New-Object System.Windows.Forms.ToolStripButton
$toolStripTime.ToolTipText = "Time"
$toolStripTime.Image = [System.IconExtractor]::Extract("shell32.dll", 239, $true)
$toolStripTime.Add_Click({net-time})
$mainToolStrip.Items.Add($toolStripTime)

$toolStripWDS = New-Object System.Windows.Forms.ToolStripButton
$toolStripWDS.ToolTipText = "License"
$toolStripWDS.Image = [System.IconExtractor]::Extract("accessibilitycpl.dll", 14, $true)
$toolStripWDS.Add_Click({kms-status})
$mainToolStrip.Items.Add($toolStripWDS)

$watermark = "Search"
$TextBox_Enter = {
if ($SearchTextBox.Text -like $watermark) {
$SearchTextBox.Text = ""
$SearchTextBox.ForeColor = [System.Drawing.SystemColors]::WindowText
}}
$TextBox_Leave = {
if ($SearchTextBox.Text -like "") {
$SearchTextBox.Text = $watermark
$SearchTextBox.ForeColor = [System.Drawing.Color]::LightGray
}}

$SearchTextBox = New-Object System.Windows.Forms.ToolStripTextBox
$SearchTextBox.Size = New-Object System.Drawing.Size(150)
$SearchTextBox.Font = "$Font,11"
$SearchTextBox.ForeColor = [System.Drawing.Color]::LightGray 
$SearchTextBox.add_Enter($TextBox_Enter)
$SearchTextBox.add_Leave($TextBox_Leave)
$SearchTextBox.Text = $watermark
$mainToolStrip.Items.Add($SearchTextBox)
#endregion

#region status
$StatusStrip = New-Object System.Windows.Forms.StatusStrip
$StatusStrip.BackColor = "white"
$StatusStrip.Font = "$Font,9"
$main_form.Controls.Add($statusStrip)

$Status = New-Object System.Windows.Forms.ToolStripMenuItem
$StatusStrip.Items.Add($Status)
$Status.Text = "©Telegram @kup57"

$main_form.ShowDialog()
#endregion