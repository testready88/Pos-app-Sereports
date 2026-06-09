# Database Connection Troubleshooting Guide

## Error: Connection Refused to SQL Server

The application cannot connect to SQL Server at `69.62.83.161:1433`.

### Error Details
```
The TCP/IP connection to the host 69.62.83.161, port 1433 has failed. 
Error: "Connection refused. Verify the connection properties. 
Make sure that an instance of SQL Server is running on the host and accepting TCP/IP connections at the port. 
Make sure that TCP connections to the port are not blocked by a firewall."
```

## Troubleshooting Steps

### 1. Verify SQL Server is Running
- Check if SQL Server service is running on the remote server
- Verify SQL Server is listening on port 1433
- Check SQL Server error logs

### 2. Check Network Connectivity
Test if you can reach the server:
```bash
# Test if port is open
telnet 69.62.83.161 1433

# Or use nc (netcat)
nc -zv 69.62.83.161 1433

# Or use ping
ping 69.62.83.161
```

### 3. Check Firewall Rules
- **On SQL Server machine**: Ensure Windows Firewall allows port 1433
- **On your machine**: Ensure outbound connections to port 1433 are allowed
- **Network firewall**: Check if corporate/cloud firewall blocks the connection

### 4. Verify SQL Server TCP/IP Configuration
On the SQL Server machine:
1. Open SQL Server Configuration Manager
2. Go to SQL Server Network Configuration > Protocols for [Instance Name]
3. Ensure TCP/IP is **Enabled**
4. Right-click TCP/IP > Properties > IP Addresses tab
5. Verify:
   - IPAll section: TCP Port = 1433
   - TCP Dynamic Ports is empty (or set to 1433)

### 5. Check SQL Server Authentication
Verify credentials in `application.properties`:
- Username: `SA`
- Password: `@SePOSDevOp12345`
- Database: `Semicolans_SeReports`

Test connection using SQL Server Management Studio (SSMS) or `sqlcmd`:
```bash
sqlcmd -S 69.62.83.161,1433 -U SA -P "@SePOSDevOp12345" -d Semicolans_SeReports
```

### 6. Check SQL Server Browser Service
If using a named instance, ensure SQL Server Browser service is running.

### 7. Verify Connection String
Current connection string:
```
jdbc:sqlserver://69.62.83.161:1433;databaseName=Semicolans_SeReports;encrypt=true;trustServerCertificate=true;loginTimeout=30;connectRetryCount=3;connectRetryInterval=10
```

If using a named instance, use:
```
jdbc:sqlserver://69.62.83.161:1433\\InstanceName;databaseName=Semicolans_SeReports;...
```

### 8. Test from Different Network
- Try connecting from a different network/location
- This helps identify if it's a network-specific issue

### 9. Check SQL Server Error Logs
On the SQL Server machine, check:
- SQL Server Error Log
- Windows Event Viewer > Application Log
- Look for connection-related errors

### 10. Verify IP Address and Port
- Confirm `69.62.83.161` is the correct IP address
- Verify port `1433` is correct (default SQL Server port)
- If using a different port, update `application.properties`

## Quick Fixes

### Option 1: Use Local SQL Server (for development)
If you have SQL Server locally, update `application.properties`:
```properties
spring.datasource.maindb.jdbcUrl=jdbc:sqlserver://localhost:1433;databaseName=Semicolans_SeReports;encrypt=true;trustServerCertificate=true
```

### Option 2: Use SQL Server Express (for development)
```properties
spring.datasource.maindb.jdbcUrl=jdbc:sqlserver://localhost\\SQLEXPRESS:1433;databaseName=Semicolans_SeReports;encrypt=true;trustServerCertificate=true
```

### Option 3: Check if Server Requires VPN
- Some servers require VPN connection
- Connect to VPN before starting the application

### Option 4: Contact Database Administrator
If you don't have access to the SQL Server:
- Contact the DBA to verify:
  - Server is running
  - Port 1433 is open
  - Your IP is whitelisted
  - Credentials are correct
  - Database exists

## Configuration Updates Made

1. **Added explicit Hibernate dialect** in `MainDBConfig.java` to prevent secondary errors
2. **Added connection timeout and retry settings** in connection string:
   - `loginTimeout=30` - Wait 30 seconds for login
   - `connectRetryCount=3` - Retry connection 3 times
   - `connectRetryInterval=10` - Wait 10 seconds between retries

## Testing Connection

After fixing the issue, test the connection:

1. **Start the application:**
   ```bash
   mvn spring-boot:run
   ```

2. **Check logs** for successful connection:
   ```
   HikariPool-1 - Starting...
   HikariPool-1 - Start completed.
   ```

3. **If connection fails**, you'll see the error in logs with more details

## Common Solutions

### Solution 1: Enable SQL Server TCP/IP
```sql
-- Run on SQL Server
EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IPAll', 
    N'TcpPort', 
    REG_SZ, 
    N'1433'
```

### Solution 2: Restart SQL Server Service
```bash
# On Windows
net stop MSSQLSERVER
net start MSSQLSERVER

# Or use Services.msc
```

### Solution 3: Check SQL Server Authentication Mode
- Ensure SQL Server Authentication (Mixed Mode) is enabled
- Not just Windows Authentication

## Next Steps

1. Verify SQL Server is accessible from your network
2. Check firewall rules
3. Test connection using SSMS or sqlcmd
4. Update connection string if needed
5. Restart the Spring Boot application

If the issue persists, contact your database administrator or network administrator.

