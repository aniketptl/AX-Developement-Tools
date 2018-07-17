	 if (-NOT [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))
	 {
		throw "You must be running the script in an Elevated command prompt using the Run as administrator option!"
	 }

	 if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	 {
		throw "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"    
	 }


	[ScriptBlock] $global:AddDll =
	{
	param ([string] $AXBCpath)

	try
	{
		$bcassembly = [Reflection.Assembly]::Loadfile($AXBCpath)      
		
		$ax = new-object Microsoft.Dynamics.BusinessConnectorNet.Axapta
		$ax.logon("dat","en-us",$ComputerName,$axConfigPath)
		
		$xSession = $ax.CreateAxaptaObject("XSession")   
		$AOSName = $xSession.call("AOSName")

		$ax.CallStaticClassMethod("FoxBuildAutoReference", "runAutoRef","F:\Build Scripts\dllimport.txt","C:\Program Files (x86)\Microsoft Dynamics AX\60\Client\Bin\")
		
		$logedOff = $ax.logoff()
	}
	catch [Exception]
	{
		Write-Host "Failed" -ForegroundColor Red
		Write-Host $_.exception.message
	}
	}

	$Session = New-PSSession -ComputerName $ComputerName
	Invoke-Command -Session $Session -ScriptBlock $AddDll -ArgumentList "$AXBCpath"
	Remove-PSSession -Session $Session
