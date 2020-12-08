 	# https://hub.docker.com/_/microsoft-windows-servercore
	# "ltsc2016" to get fonts installed
	# Server Core 2019 is shipped without fonts
	
	FROM mcr.microsoft.com/windows/servercore:ltsc2016
	
	# Copy the application from folder "app" to "C:\app" on container machine
	
	COPY app/ /app
	
	SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
	
	# Install IIS
	
	RUN Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole; \
		Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer; \
		Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
	
	# Download and install Visual C++ Redistributable Packages for Visual Studio 2013
	
	RUN Invoke-WebRequest -OutFile vc_redist.x64.exe https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe; \
		Start-Process "vc_redist.x64.exe" -ArgumentList "/passive" -wait -Passthru; \
		del vc_redist.x64.exe
	
	# Install ASP.NET Core Runtime
	# Checksum and direct link from: https://dotnet.microsoft.com/download/dotnet-core/thank-you/runtime-aspnetcore-3.1.5-windows-hosting-bundle-installer
	
	RUN Invoke-WebRequest -OutFile dotnet-hosting-3.1.0-win.exe https://download.visualstudio.microsoft.com/download/pr/fa3f472e-f47f-4ef5-8242-d3438dd59b42/9b2d9d4eecb33fe98060fd2a2cb01dcd/dotnet-hosting-3.1.0-win.exe; \
		Start-Process "dotnet-hosting-3.1.0-win.exe" -ArgumentList "/passive" -wait -Passthru; \
		Remove-Item -Force dotnet-hosting-3.1.0-win.exe
	
	# Create a new IIS ApplicationPool
		
	RUN [string]$appPoolName = 'myAppPool'; \
		New-WebAppPool $appPoolName; \
		Import-Module WebAdministration; \
		$appPool = Get-Item IIS:\AppPools\$appPoolName; \
		$appPool.managedRuntimeVersion = ''; \
		$appPool | set-item
	
	RUN [string]$appPoolName = 'myAppPool'; \
		[string]$appName = 'myDotnetCoreApp'; \
		New-WebApplication -Name $appName -Site 'Default Web Site' -PhysicalPath C:\app -ApplicationPool $appPoolName