#Define a port mapping scheme (equivalent to JavaScript objects)
$portMap = @{
    1 = 'TCP Port Service Multiplexer (TCPMUX)'
    2 = 'compressnet (Management Utility)'
    3 = 'compressnet (Compression Process)'
    5 = 'Remote Job Entry - MIB PIM & IANA services (using socket 5 in its old socket form'
    7 = 'Echo Protocol'
    9 = 'Discard Protocol & Wake-on-LAN'
    11 = 'Active Users (systat service)'
    13 = 'Daytime Protocol'
    15 = 'netstat service'
    17 = 'Quote of the Day (QOTD)'
    18 = 'Message Send Protocol'
    19 = 'Character Generator Procotol (CHARGEN)'
    20 = 'File Transfer Protocol (FTP) data transfer services'
    21 = 'File Transfer Protocol (FTP) control command'
    22 = 'SSH'
    23 = 'Telnet - Unencrypted plain text communications'
    25 = 'Simple Mail Transfer Protocol (SMTP)'
    27 = 'nsw-fe (NSW User System FE)'
    28 = 'Palo Alto Networks Panorama High Availability'
    29 = 'msg-icp (MSG ICP)'
    31 = 'msg-auth (MSG Authentication)'
    33 = 'dsp (Display Support Protocol)'
    37 = 'Time Protocol'
    38 = 'rap (Route Access Protocol)'
    39 = 'rlp (Resource Location Protocol)'
    41 = '6in4 (IPv6 packets encapsulated in IPv4 tunneling)'
    42 = 'Host Name Server Protocol'
    43 = 'WHOIS protocol'
    #44 = 'mpm-flags (MPM FLAGS Protocol)'
    #45 = 'mpm (Message Processing Module [recv])'
    #46 = 'mpm-snd (MPM [default send])'
    #47 = 'Reserved port'
    #48 = 'auditd (Digital Audit Daemon)'
    49 = 'TACACS Login Host protocol. TACACS+. Used for Use Authentication, Authorization, Accounting purposes'
    50 = 'Internet Key Exchange Protocol'
    #51 = 'Interface Message Processor'
    52 = 'Not assigned/Xerox Network Systems (XNS) Time Protocol'
    53 = 'Domain Name System (DNS)'
    63 = 'Not assigned'
    66 = 'SQL-Net (Oracle SQL*NET)'
    67 = 'Bootstrap Protocol (BOOTP) server used by DHCP'
    68 = 'Bootstrap Protocol (BOOTP) client'
    69 = 'Trivial File Transfer Protocol (TFTP)'
    79 = 'Finger protocol (Show users last login names)'
    80 = 'HTTP'
    81 = 'TorPark (Dark Web browsing) service'
    82 = 'TorPark (Dark Web browsing) control'
    88 = 'Kerberos authentication'
    105 = 'CCSO Nameserver'
    109 = 'POP2'
    110 = 'POP3'
    111 = 'Portmapper (RPCBIND) service'
    115 = 'Simple File Transfer Protocol (SFTP)'
    117 = 'UUCP Mapping Project (path service) for UNIX file share'
    118 = 'Default SQL services'
    119 = 'Network News Transfer Protocol (NNTP)'
    123 = 'Network Time Protocol (NTP)' 
    135 = 'Microsoft Endpoint Mapper (EPMAP) incl. DHCP, DNS server used by DCOM'
    137 = 'NetBIOS Name Service'
    138 = 'NetBios Datagram Service'
    139 = 'NetBios Session Service'
    143 = 'Internet Message Access Protocol (IMAP)'
    161 = 'Simple Network Management Protocol (SNMP)'
    162 = 'SNMPTrap'
    179 = 'Border Gateway Protocol(BGP)'
    199 = 'SNMP Unix Multiplexer (SMUX)'
    220 = 'IMAP3'
    #264 = 'Border Gateway Multicast Protocol (BGMP)'
    #311 = 'macOS Server Admin'
    #312 = 'macOS Xsan administration'
    318 = 'PKIX Time Stamp Protocol (TSP)'
    369 = 'RPC2PortMap'
    389 = 'Lightweight Directory Access Protocol (LDAP)'
    8080 = 'HTTP'
    443 = 'TLS'
    445 = 'SMB'
    464 = 'Kerberos Change/Set password'
    465 = 'Simple Mail Transfer Secure Protocol (SMTPS)'
    475 = 'Aladdin Knowledge Systems Hasp services (Sentinel HASP) software protection & licensing solutions by SafeNet'
    
    476 = 'Tapestry Distributed Computing System (tn-tl-fd1)'
    2049 = 'Network File System (NFS)'
    28260 = 'internal sysd IPC communication for internal processes'
    28261 = 'internal md applications to manage internal processes'
    5900 = 'VNC viewer Server'
    5901 = 'VNC viewer Client1'
    5902 = 'VNC viewer Client2'
    5903 = 'VNC viewer Client3'
    5904 = 'VNC viewer Client4'
    5905 = 'VNC viewer Client5'
    5906 = 'VNC viewer Client6'
    5907 = 'VNC viewer Client7'
    5908 = 'VNC viewer Client8'
    5909 = 'VNC viewer Client9'
    5910 = 'VNC viewer Client10'
    5985 = 'WinRM PowerShell endpoint'
}


# Iterate through useful IPs and Ports
function Scan-LocalPorts {
    param(
        [string]$currentIP,
        [int]$currentPort,
        [int]$timeoutInSeconds = 15
    )
    $loopback = "127.0.0.1";
    $openPorts = @();
    $runningServices = @();
    $portsAndServices = @();
    
    Write-Host "Scanning ports for localhost: $loopback";

    foreach ($currentPort in $portMap.Keys) {
        Write-Host "Testing TCP port: $currentPort";

        $job = Start-Job -ScriptBlock {
            param($ip, $port)
                Test-NetConnection -ComputerName $ip -Port $port
        } -ArgumentList $loopback, $currentPort

        # Wait for the job to complete or timeout
        $result = Wait-Job $job -Timeout $timeoutInSeconds
        #$test = Test-NetConnection -ComputerName $currentIP -Port $currentPort
        #$test;

        if ($result -eq $null) {
            # Job timed out
            Stop-Job $job
            Remove-Job $job
            Write-Host "Pinging TCP port:$currentPort has timed out on localhost"

        } else {
            # Job completed successfully
            $test = Receive-Job $job
            Remove-Job $job
                
            if ($test.TcpTestSucceeded -eq "True") {
                
                $openPort = $currentPort;
                # Display test
                #Write-Host "$($portMap[$currentPort])";
                $runningService="$($portMap[$currentPort])";

                $portAndService = "TCP Port: $currentPort is OPEN! Service running: $runningService";
                $portsAndServices += $portAndService;
                Write-Host "$portAndService";
                # Append openPort & runnginService to respective arrays
                $openPorts += $openPort;
                $runningServices += $runningService;
            } else {
                Write-Host "Port $currentPort is closed on localhost"
            }
    
        }
    }
Write-Host "========================================";
Write-Host "Returning open Ports detected as below: ";
return $openPorts, $runningServices, $portsAndServices;
}
#Scan-LocalPorts;

$doneTime = date -Format "yyyy-MM-dd_hh-mm-ss";

# Store detected Open Ports from Scan-LocalPorts
$result = Scan-LocalPorts;

# Retrieving arrays
# $openPorts
# $runningServices
# using Object destructuring
$openPorts, $runningServices, $portsAndServices = $result;

Write-Host "________________________________________";
# Display $openPorts array
#Write-Host "Array1 openPorts: $openPorts";
#Write-Host "Array2 runningServices: $runningServices";
#Write-Host "Array3 portsAndServices: $portsAndServices";

# Saving $openPorts array to a file
Write-Host "Saving open Ports to a file...";
$openPorts;
$openPorts | Out-File -FilePath ".\Scan-Ports_openPorts_$doneTime.txt";

# Saving $runningServices array to a file
Write-Host "Saving running services to a file...";
$runningServices;
$runningServices | Out-File -FilePath ".\Scan-Ports_runningServices_$doneTime.txt";

# Saving $portsAndServices array to a file
Write-Host "Saving open Ports & running services to a file...";
$portsAndServices;
$portsAndServices | Out-File -FilePath ".\Scan-Ports_portsAndRunningServices_$doneTime.txt";