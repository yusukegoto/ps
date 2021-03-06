# ps

WindowsマシンへのGUIインストーラを利用したレシピの検証です.

インストールはGUIから行うためタスクスケジューラから
`sendkyes`を利用することでインストールを実行します.

## 準備

### プロビジョニング対象のWindowsマシン

対象のWindowsマシンが以下のことを実行済みであること.

*PowerShell*

- Set-ExecutionPolicy RemoteSigned
- winrm quickconfig

*コマンドプロンプト*

- wimrm set winrm/config/cient/auth @{BasicAuth="true"}
- wimrm set winrm/config/service/auth @{BasicAuth="true"}
- wimrm set winrm/config/service @{AllowUnencrypted="true"}

*コントロールパネル等*

- winrmのファイヤーウォールの許可(HTTP: 5985, HTTPS: 5986)


## 参考

[Sendkyes](https://msdn.microsoft.com/ja-jp/library/cc364423.aspx)

[Managing Windows Servers with Chef](https://www.packtpub.com/networking-and-servers/managing-windows-servers-chef)

[ShowWindowの定数](https://msdn.microsoft.com/en-us/library/windows/desktop/ms633548%28v=vs.85%29.aspx)
