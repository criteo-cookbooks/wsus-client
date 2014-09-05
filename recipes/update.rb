#
# Author:: Baptiste Courtois (<b.courtois@criteo.com>)
# Cookbook Name:: wsus-client
# Recipe:: update
#
# Copyright:: Copyright (c) 2014 Criteo.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# WSUS is a windows only feature
return unless platform?('windows')

include_recipe 'wsus-client::configure'
include_recipe 'powershell::powershell4'


::Chef::Recipe.send(:include, ::Chef::Mixin::PowershellOut)

# Chef does not have guard_interpreter feature before 11.12.0
if powershell_out('(New-Object -com \'Microsoft.Update.Session\').CreateUpdateSearcher().Search(\'IsInstalled=0\').Updates.Count -ne 0').stdout.strip == 'True'
  # Api documentation: http://msdn.microsoft.com/en-us/library/windows/desktop/aa387099.aspx
  powershell_script 'wsus_update_script' do
    code <<-EOH
$session = New-Object -com 'Microsoft.Update.Session'

Write-Host 'Looking for updates...'
$searcher = $session.CreateUpdateSearcher()
$foundUpdates = $searcher.Search('IsInstalled=0').Updates

Write-Host 'Update(s) to download: ' $foundUpdates.Count
if ($foundUpdates.Count -eq 0) {
  Write-Warning 'No update available.'
  exit 0
}

$downloader = $session.CreateUpdateDownloader()
$downloader.Updates = $foundUpdates

Write-Host 'Downloading updates...'
$downloadResult = $downloader.Download()
# ResultCode values: http://msdn.microsoft.com/en-us/library/windows/desktop/aa387095.aspx
if (($downloadResult.HResult -ne 0) -or (($downloadResult.ResultCode -ne 2) -and ($downloadResult.ResultCode -ne 3))) {
  Write-Host 'Download failed.' -f red
  exit 1
}

Write-Host 'Preparing updates...'
$updatesToInstall = New-object -com 'Microsoft.Update.UpdateColl'
foreach ($update in $foundUpdates) {
  if (! $update.isdownloaded) {
    Write-Warning "Update $($update.Title) not downloaded."
    continue
  }
  if (! $update.EulaAccepted) {
    Write-Host "Accepting EULA for $($update.Title)." -F green
    $update.AcceptEula()
  }
  $updatesToInstall.Add($update) | out-null
}

$installer = $session.CreateUpdateInstaller()
$installer.ForceQuiet = $true
$installer.Updates = $updatesToInstall

$installationResult = $installer.Install()
if (($installationResult.HResult -ne 0) -or ($installationResult.ResultCode -ne 2)) {
  Write-Host "Installation failed. (Error code $($installationResult.HResult))" -f red
  exit 1
}

if ($installationResult.RebootRequired) {
  Write-Host 'Reboot required.' -F blue
}
Write-Host 'Installation succeeded' -F green
    EOH
  end
end
