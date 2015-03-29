#
# Cookbook Name:: ps
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
::Chef::Recipe.send(:include, Windows::Helper)

tmp_path = Chef::Config[:file_cache_path]
msi_path = File.join tmp_path, '7zip.msi'

remote_file msi_path do
  source 'http://www.7-zip.org/a/7z938-x64.msi'
end

ps1_path = File.join(tmp_path, 'svn_zip_install.ps1')
file ps1_path do
  content <<-PS
# Use SendKeys
add-type -AssemblyName System.Windows.Forms


# Prepare for Activate Window
$showWindowAsyncDef = @"
[DllImport("user32.dll")]public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@
$showWindowAsync = Add-Type -MemberDefinition $showWindowAsyncDef -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru


# main

$installer = start-process #{ msi_path } -PassThru
start-sleep -Seconds 5 # wait till installer to be lauched

# force activate
$showWindowAsync::ShowWindowAsync($installer.MainWindowHandle, 6) # SW_MINIMIZE
start-sleep -Seconds 1
$showWindowAsync::ShowWindowAsync($installer.MainWindowHandle, 9) # SW_RESTORE
start-sleep -Seconds 1

[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
start-sleep -Milliseconds 500

[System.Windows.Forms.SendKeys]::SendWait(" ")
start-sleep -Milliseconds 500

[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
start-sleep -Milliseconds 500

[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
start-sleep -Milliseconds 500

[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
start-sleep -Seconds 30

# finish
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
  PS
end

windows_task 'install 7zip' do
  action [:create, :enable]
  command "powershell.exe -WindowStyle Hidden -File #{ps1_path}"
  user node['ps']['user']
  password node['ps']['password']
  frequency :once
  interactive_enabled true
  start_time lazy { (Time.now + 1 * 60).strftime('%H:%M') } # 1min
  run_level :highest
end

