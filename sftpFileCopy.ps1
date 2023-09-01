	#Author: Kevin Munoz
	
	# Set the FTP server 
    $sftpServer = "x.x.x.x"
    $username = "user"
    # Encrypted password. Only works with the FTP service account.
    $password = 'pass'
    $securePassword = $password  | ConvertTo-SecureString

	# Set the source and destination folder paths
	$sourceFolder = "/path/to/directory/"
	$destinationFolder = "D:\path\to\folder"

	# Set file names to search for with varying ending numbers
	$file1BaseName = "file1"
	$file2BaseName = "file2"

	# Setting credentials to connect to SFTP server
	$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

	# Remove any open sessions
	Get-SFTPSession | Remove-SFTPSession | Out-Null

	# Creating an SFTP Session and storing the session id.
	$Session = New-SFTPSession -ComputerName $sftpServer -Credential $creds -AcceptKey
	$SessionID = $Session.SessionId

	# Get a list of files from the source folder
		$files = Get-SFTPChildItem -SessionId $SessionID -Path "/path/to/directory/"

# Find the newest file for "test1"
$filesTest1 = Get-SFTPChildItem -SessionId $SessionID -Path $sourceFolder | Where-Object { $_.Name -like "$file1BaseName*" }
$newestFileTest1 = $filesTest1 | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Find the newest file for "test2"
$filesTest2 = Get-SFTPChildItem -SessionId $SessionID -Path $sourceFolder | Where-Object { $_.Name -like "$file2BaseName*" }
$newestFileTest2 = $filesTest2 | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Copy the newest "test1" file if found
if ($newestFileTest1 -ne $null) {
    $sourcePathTest1 = Join-Path $sourceFolder $newestFileTest1.Name
    Get-SFTPItem -Path $newestFileTest1.FullName -Destination $destinationFolder -SessionId $SessionID -Force
    Write-Output "Newest $file1BaseName file copied to $($destinationFolder)"
}

# Copy the newest "test2" file if found
if ($newestFileTest2 -ne $null) {
    $sourcePathTest2 = Join-Path $sourceFolder $newestFileTest2.Name
    Get-SFTPItem -Path $newestFileTest2.FullName -Destination $destinationFolder -SessionId $SessionID -Force
    Write-Output "Newest $file2BaseName file copied to $($destinationFolder)"
}
  #send out an email letting know the process is complete 
	$emailBody = "The files have been placed into the folder on the Shares drive. Please review and load these files for processing."
    $From    = "Infomation Technology <IT@domain.com>"
    $To      = "address@domain.com"
    $Subject = "Files"
    $PSEmailServer = "emailServer.com" 
	$smtpPort = 587
	Send-MailMessage -From $From -to $To -Subject $Subject -Body $emailBody -BodyAsHtml -SmtpServer $PSEmailServer -Port $SMTPPort -UseSsl
	#>
# Close the SFTP session
Get-SFTPSession | Remove-SFTPSession | Out-Null

Write-Output "Files copied successfully."
	
	
