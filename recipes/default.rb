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
start-sleep -Seconds 5

$showWindowAsync::ShowWindowAsync($installer.MainWindowHandle, 1) # SW_SHOWNORMAL

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

minute_after = (Time.now + 2 * 60).strftime('%H:%M')

windows_task 'install 7zip' do
  action [:create, :enable]
  command "powershell.exe -WindowStyle Normal -File #{ps1_path}"
  user node['ps']['user']
  password node['ps']['password']
  frequency :once
  interactive_enabled true
  start_time minute_after
  run_level :highest
end

log "---- Install Task will be executed at #{minute_after} ----"
