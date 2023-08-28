#Author: Kevin Munoz
	
# Set the FTP server 
$sftpServer = "x.x.x.x"
$username = "user"
# Encrypted password. 
$password = 'pass'
$securePassword = $password | ConvertTo-SecureString

# Set the source and destination folder paths
$sourceFolder = "/path/to/dir/"
$destinationFolder = "D:\folder\path" 

# Set file names to search for with any extention type
$file1BaseName = "test 1" 
$file2BaseName = "test 2" 

# Setting credentials to connect to SFTP server
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

# Remove any open sessions
Get-SFTPSession | Remove-SFTPSession | Out-Null

# Creating an SFTP Session and storing the session id.
$Session = New-SFTPSession -ComputerName $sftpServer -Credential $creds -AcceptKey
$SessionID = $Session.SessionId

# Get a list of files from the source folder
$files = Get-SFTPChildItem -SessionId $SessionID -Path "/path/to/dir/"

	# Loop through each file and copy if the file names match hardcoded file
    foreach ($file in $files) {
		if ($file.Name -match $file1BaseName -or $file.Name -match $file2BaseName) {
			$sourceFolder = Join-Path $sourceFolder $file.Name
			Get-SFTPItem -Path $file.FullName -Destination $destinationFolder -SessionId $SessionID -Force
			Write-Output "File $($file.BaseName) copied to $($destinationFolder)"
		}
}
	# send out an email letting know the process is complete 
	$emailBody = "The files have been placed into the specified folder. Please review and load these files for processing."
    $From    = "Out Going Address <outemail@cc.com>"
    $To      = "example@cc.com"
    $Subject = "Files Copied"
    $PSEmailServer = "emailserver.com" 
	$smtpPort = 587
	Send-MailMessage -From $From -to $To -Subject $Subject -Body $emailBody -BodyAsHtml -SmtpServer $PSEmailServer -Port $SMTPPort -UseSsl


# Close the SFTP session
Get-SFTPsession | Remove-SFTPSession | Out-Null

Write-Output "Files copied successfully."
