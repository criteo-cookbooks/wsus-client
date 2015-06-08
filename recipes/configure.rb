#
# Author:: Baptiste Courtois (<b.courtois@criteo.com>)
# Cookbook Name:: wsus-client
# Recipe:: configure
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
# Microsoft documentation
#: registry configuration per http://technet.microsoft.com/en-us/library/dd939844.aspx
# Other documentation
#: http://smallvoid.com/article/winnt-automatic-updates-config.html
#
# WSUS is a windows only feature
return unless platform?('windows')

conf = node['wsus_client']

# Converts days symbols to AUOptions value
install_day = case conf['schedule_install_day']
  when :every_day then 0
  when :sunday    then 1
  when :monday    then 2
  when :tuesday   then 3
  when :wednesday then 4
  when :thursday  then 5
  when :friday    then 6
  when :saturday  then 7
  else fail "Invalid value of '#{conf['schedule_install_day'] }' for attribute 'schedule_install_day'"
end

# Converts symbols behavior to AUOptions value
au_options = case conf['automatic_update_behavior']
  when :disabled  then 1
  when :detect    then 2
  when :download  then 3
  when :install   then 4
  when :manual    then 5
  else fail "Invalid value of '#{conf['automatic_update_behavior'] }' for attribute 'automatic_update_behavior'"
end
# Disables auto_update on au_options :disabled
no_auto_update = au_options == 1 ? 1 : 0

# A helper to verify attributes values
check_limit = lambda { |k, m| fail "Invalid value of '#{conf[k]}' for attribute '#{k}'" if conf[k] > m && conf[k] < 0 }

check_limit['detection_frequency', 22]
check_limit['schedule_install_time', 23]
check_limit['schedule_retry_wait', 60]
check_limit['reboot_warning', 30]
check_limit['reboot_prompt_timeout', 1440]

registry_key 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate' do
  values [
    # Allows signed non-Microsoft updates.
    { type:  :dword, name:   'AcceptTrustedPublisherCerts', data:  conf['enable_non_microsoft_updates'] ? 1 : 0 },
    # Disables access to Windows Update.
    { type:  :dword, name:    'DisableWindowsUpdateAccess', data: conf['disable_windows_update_access'] ? 1 : 0 },
    # Authorizes Users to approve or disapprove updates.
    { type:  :dword, name:              'ElevateNonAdmins', data: conf['allow_user_to_install_updates'] ? 1 : 0 },
    # Defines the current computer update group.
    { type: :string, name:                   'TargetGroup', data:                          conf['update_group'] },
    # Allows client-side update group targeting.
    { type:  :dword, name:            'TargetGroupEnabled', data:                  conf['update_group'] ? 1 : 0 },
    # Defines the WSUS Server url.
    { type: :string, name:                      'WUServer', data:                           conf['wsus_server'] },
    { type: :string, name:                'WUStatusServer', data:                           conf['wsus_server'] },
  ]
  notifies :restart, 'service[wuauserv]', :immediately
  recursive true
end

registry_key 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' do
  values [
    # Defines Automatic Updates behavior.
    { type:  :dword, name:                     'AUOptions', data:                                    au_options },
    # Defines whether minor update should be automatically installed.
    { type:  :dword, name:       'AutoInstallMinorUpdates', data:    conf['auto_install_minor_updates'] ? 1 : 0 },
    # Defines times in hours between detection cycles (default frequency is 22 hours).
    { type:  :dword, name:            'DetectionFrequency', data:                   conf['detection_frequency'] },
    { type:  :dword, name:     'DetectionFrequencyEnabled', data:           conf['detection_frequency'] ? 1 : 0 },
    # Disables automatic reboot with logged-on users.
    { type:  :dword, name: 'NoAutoRebootWithLoggedOnUsers', data:   conf['no_reboot_with_logged_users'] ? 1 : 0 },
    # Disables automatic update detection, notification and installation.
    { type:  :dword, name:                  'NoAutoUpdate', data:                                no_auto_update },
    # Defines times in hours between detection cycles (default frequency is 22 hours).
    { type:  :dword, name:         'RebootRelaunchTimeout', data:                 conf['reboot_prompt_timeout'] },
    { type:  :dword, name:  'RebootRelaunchTimeoutEnabled', data:         conf['reboot_prompt_timeout'] ? 1 : 0 },
    # Defines scheduling and reboot settings.
    { type:  :dword, name:          'RebootWarningTimeout', data:                        conf['reboot_warning'] },
    { type:  :dword, name:   'RebootWarningTimeoutEnabled', data:                conf['reboot_warning'] ? 1 : 0 },
    { type:  :dword, name:            'RescheduleWaitTime', data:                   conf['schedule_retry_wait'] },
    { type:  :dword, name:     'RescheduleWaitTimeEnabled', data:           conf['schedule_retry_wait'] ? 1 : 0 },
    { type:  :dword, name:           'ScheduledInstallDay', data:                                   install_day },
    { type:  :dword, name:          'ScheduledInstallTime', data:                 conf['schedule_install_time'] },
    # Defines whether a custom WSUS server should be used instead of Microsoft Windows Update server.
    { type:  :dword, name:                   'UseWUServer', data:                   conf['wsus_server'] ? 1 : 0 },
  ]
  notifies :restart, 'service[wuauserv]', :immediately
  recursive true
end

service 'wuauserv' do
  supports status: true, start: true, stop: true, restart: true
  action [:start, :enable]
  notifies :run, 'execute[Force Windows update detection cycle]', :immediately
end

# Force detection in case the client-side update group changed
execute 'Force Windows update detection cycle' do
  command 'c:\windows\sysnative\wuauclt.exe /ResetAuthorization /DetectNow'
  action :nothing
end
