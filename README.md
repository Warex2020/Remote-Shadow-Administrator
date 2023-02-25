# RSA - Remote Shadow Administrator

Program for connecting to ongoing RDP sessions via **Shadow connection**. Also contains a collection of scripts for **automating remote communication and administration of Windows**.

Can be used as an alternative remote connectivity tool (e.g., Radmin or VNC, which require software installation and have some security vulnerabilities). Uses 100% powershell and Windows Forms code (no Toolbox), no module dependencies. Tested on Windows Server 2016 DC and Windows 10 Pro. To display the output correctly, English localization must be used.

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Image/Interface-1.4.jpg)

> List of servers can be called from the program by right-clicking in the list of servers or the key combination Ctrl+S (when you first start or delete the list, is created automatically).

When you select a server and click on the "Check" button, the list of current users is displayed in the form of a table (since version 1.3.1). **When you select a user ID, you can perform three actions: Shadow connection with and without connection request (the latter is configured through GPO), disconnecting user (logout) and sending typed message to all users on the server or selected in the table.** Creating table is done in 3 stages, firstly server availability is checked, which is reported in status-bar and additionally uptime is checked (if WinRM is not available, program will report it), if server is not available, to avoid a long delay checking users is not done. The second step is parsing the query output with Regex, the last step is creation of Custom Object with output to DGV.

> You can use [this script] (https://github.com/Lifailon/Find-Users) to search for users on the network.

To connect to the server via rdp mstsc with /admin switch is used, it allows to connect to RDSH server without Broker. **For authentication cmdkey** is used, after single authentication (in File menu - Authentication), then there is preliminary authentication to all servers in the list and it works until the program is closed, **that allows not to store administrator password in code, as well as storage of OS keys (which can be compromised) **. 

## Update 1.4
* Made changes in interface: form size was increased, icons were replaced (import dll from system32)
* Reworked DGV command output (except for TCP Viewer and DISM). For Services, Process and SMP open files context menu output in OGV is saved. Added search menu for services and processes. For service statuses as well as processes with trigger values more than 100mb RAM and 10 CPU are highlighted.
* Viewing the list of DNS zones and records in it (via icm, the module is not required) on the host with DNS role for fast search. Added power log (reboots and shutdowns).

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Image/Services.jpg)

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Image/Process.jpg)

## Update 1.3.2
* After making changes to the list of servers, to update the list from the program itself added Refresh button (File - Refresh, by right-clicking in the list, or by keyboard shortcut Ctrl+R).
* Added possibility to fill the list of servers with all computers of the current domain (Ctrl+D).
* Table of domain servers list (Ctrl+T), with the search of users registered on them (ManagedBy, only for client OS) as well as sorting by status (Active/Blocked), OS version and creation time, with the possibility to select a server to display the list of users and further cooperation.
* Added an option to select an external source of computer clock synchronization (Time - Change source), for example: ru.pool.ntp.org
* Added scripts to remotely disable/enable hibernation mode and screen lock in the Power menu.

### scripts for activating corporate licenses on the network (KMS).

* Find out OS edition and version, license channel, key type, activation status and licensing server.
* KMS-server address in the network by srv-record.
* GVLK activator. Contains GVLK (Generic Volume License Key) public keys with the possibility of remote activation.
* Specify the KMS server manually (for example, if the KMS server is not published in DNS).
* Get the license manually.

## Version 1.3.1 Remote administration automation scripts.
** Typical:** reboot and shutdown (shutdown) with a 30 second delay and cancellation capability. Computer Management, gpupdate on remote machine, gpresult with output to XML file and user name. Service check with possibility of convenient search filtering and status check after stop/restart. List of running user processes with the possibility of terminating them. List of open SMB sessions with the ability to close them to free the file. Viewing of all network resources with the ability to open them (including c$). Viewing and filtering logs (3 logs are used).

** Borrowed:** TCP Viewer (source: [winitpro](https://winitpro.ru/index.php/2021/01/25/get-nettcpconnection-powershell-nestat)) - performs FQDN query for all remote addresses and by Get-Process identifies the path of the executing process by its ID. Connection Broker (requires RemoteDesktop module installed) with Shadow connection to user. Wake on Lan (source: [coolcode](https://coolcode.ru/wake-on-lan-and-powershell)) - Formation of Magic Packet with sending broadcast (MAC-address is taken from the message entry form). Checking for free space on disk partitions (source: [fixmypc](https://fixmypc.ru/post/kak-uznat-v-powershell-svobodnoe-mesto-na-diske)) and by analogy RAM.

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Image/Disk.jpg)

## **Introduction:**

### **Search the computer's MAC address**.
Used when you want to know the MAC address of a computer which is no longer accessible. Produced by browsing ARP tables on other servers as a proxy (Power - Get-MAC-Proxy). The 2nd option, viewing all clients on the server with DHCP role (Power - Get-DHCP, via icm on the server with DHCP role, no module installation required) as a table with sorted output. Used for subsequent sending Magic Packet.

> The MAC address is output (from Get-MAC-Proxy and Get-DHCP) and taken (for Magic Packet) from the form for sending messages to users.

### **Computer clock synchronization scripts (w32tm):**
*Displays the current time on the server and the difference from the source server (localhost). 
*Learn the source time, as well as the frequency and time of the last synchronization (the latter is displayed depending on the language package on the remote machine). 
* Check the server as a time source. 
* Immediately synchronize the time on the remote server with the source. 
* Change the time source on the remote server to the nearest DC in the subnet.

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Image/Times.jpg)

### **WMI:** 
* View the list of updates (when you press ok, the update number is copied to the clipboard). Because deleting updates through WUSA in silent mode is not supported anymore, it is used in conjunction with DISM online (I purposely left it as a separate tab, you can automate deletion process and/or parse output of updates to implement complete table).
* List of installed drivers.
* Remote check, as well as enabling/disabling rdp and nla. 
* List of installed programs with the possibility to uninstall. Two methods are used: get-packet and gwmi.

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Image/Software.jpg)

**Fixture inventory** - CPU model, motherboard, video card, RAM, disk model, convertible to HTML file:

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Image/Report.jpg)

**Installing programs**. Via install-package (now this option is used in menu: WMI - Installation) and 2 methods gwmi (function wmi-installer). In first case installation happens not on all servers (not depending on using TLS version), in wmi case installation happens from unc-path only on the same server where msi package is located (incl. via invoke session and pre-authentication on remote machine, directory via icm is available on path).

For questions and suggestions **Telegram: @kup57**
