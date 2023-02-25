# RSA - Remote Shadow Administrator

Program for connecting to ongoing RDP sessions via **Shadow connection**. Also contains a collection of scripts for **automating remote communication and administration of Windows**.

Can be used as an alternative remote connectivity tool (e.g., Radmin or VNC, which require software installation and have some security vulnerabilities). Uses 100% powershell and Windows Forms code (no Toolbox), no module dependencies. Tested on Windows Server 2016 DC and Windows 10 Pro. To display the output correctly, English localization must be used.

![Image alt](https://github.com/Lifailon/Remote-Shadow-Administrator/blob/rsa/Image/Interface-1.4.jpg)

> Server list can be called from the program by right-clicking in the list of servers or key combination Ctrl+S (when you first start or delete the list, is created automatically).

When you select a server and click on the "Check" button, the list of current users is displayed in the form of a table (since version 1.3.1). **When you select a user ID, you can perform three actions: Shadow connection with and without connection request (the latter is configured through GPO), user disconnection (logout) and sending typed message to all users on the server or selected in the table.** Creating the table is done in 3 stages, firstly server availability is checked, which is reported in the status bar and additionally uptime is checked (if WinRM is not available the program will report it), if server is not available, to avoid a long delay checking users is not done. The second step is parsing the query output with Regex, the last step is creation of Custom Object with output to DGV.

> You can use [this script] (https://github.com/Lifailon/Find-Users) to search for users on the network.

To connect to the server via rdp mstsc with /admin switch is used, it allows to connect to RDSH server without Broker. **For authentication cmdkey** is used, after single authentication (in File menu - Authentication), then there is preliminary authentication to all servers in the list and it works until the program is closed, **that allows not to store administrator password in code, as well as storage of OS keys (which can be compromised) **. 

## Update 1.4
* Made changes in interface: form size was increased, icons were replaced (import dll from system32)
* Reworked DGV command output (except for TCP Viewer and DISM). For Services, Process and SMP open files context menu output in OGV is saved. Added search menu for services and processes. For service statuses as well as processes with trigger values more than 100mb RAM and 10 CPU are highlighted.
* Added showing a list of DNS zones and records in it (via icm, the module is not required) on the host with DNS role for fast search. Added
