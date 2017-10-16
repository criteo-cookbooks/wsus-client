# Wsus-client Cookbook
[![Cookbook Version][cookbook_version]][supermarket_url]
[![Build Status][build_status]][build_status]
[![License][license]][license]

Configures WSUS clients to retrieve approved updates.

## Testing

The PowerShell script will always fail if run via the winrm vagrant provider
as the IUpdateSession::CreateUpdateDownloader is not available remotely.

## Logs

The Microsoft.Update.Session object keeps a log in: C:\Windows\WindowsUpdate.log

## Requirements

This cookbook recommends Chef 12.6+.

### Platforms
* Windows XP
* Windows Vista
* Windows Server 2003 R2
* Windows 7
* Windows Server 2008 (R1, R2)
* Windows 8 and 8.1
* Windows Server 2012 (R1, R2)
* Windows 10
* Windows Server 2016

## Usage

Using this cookbook is quite easy; add the desired recipes to the run list of a node, or role.
Adjust any attributes as desired. For example, to configure a windows server role that connects to your WSUS server:

```ruby
$ cat roles/updated_windows_server.rb
name 'updated_windows_server'
description 'Setup a windows server to keep up-to-date'

run_list(
  'wsus-client::default'
)

default_attributes(
  wsus_client: {
    wsus_server: 'http://wsus-server.my-corporation.com:8530',
    update_group: 'updated_server2015',
  },
)
```

## Providers & Resources

### update
This provider allows to synchronously download and/or install available windows updates.

#### Actions
Action   | Description
---------|---------------------------
download | Download available updates
install  | Install downloaded updates

> NOTE: The default behavior is `[:download, :install]`

#### Attributes
Attribute        | Description                                            | Type                  | Default
-----------------|--------------------------------------------------------|-----------------------|------------------------
actions          | An array of actions to perform (see. actions above)    | Symbol array          | `[:download, :install]`
name             | Name of the resource                                   | String                |
download_timeout | Time alloted to the download operation before failing  | Integer               | `3600`
install_timeout  | Time alloted to the install operation before failing   | Integer               | `3600`
handle_reboot    | Indicate whether to reboot or not after update install | TrueClass, FalseClass | `false`
reboot_delay     | The amount of time (in minutes) to delay the reboot    | Integer               | `1`

## Recipes

### wsus-client::default
Convenience recipe that configures WSUS client and performs a synchronous update.
It basically includes `wsus-client::configure` and `wsus-client::update`

### wsus-client::configure
This recipe modifies the Windows registry to configure [WSUS update settings][wsus_registry].

#### Attributes
The following attributes are used to configure the `wsus-client::configure` recipe, accessible via `node['wsus_client'][attribute]`.

Attribute                    | Description                                                                                            | Type                | Default
-----------------------------|--------------------------------------------------------------------------------------------------------|---------------------|--------
wsus_server                  |Defines a custom WSUS server to use instead of Microsoft Windows Update server                          |String, URI          |`nil`
update_group                 |Defines the current computer update group. (see [client-side targeting][client_targeting])              |String               |`nil`
disable_windows_update_access|Disables access to Windows Update (or your WSUS server)                                                 |TrueClass, FalseClass|`false`
enable_non_microsoft_updates |Allows signed non-Microsoft updates.                                                                    |TrueClass, FalseClass|`true`
allow_user_to_install_updates|Authorizes Users to approve or disapprove updates.                                                      |TrueClass, FalseClass|`false`
auto_install_minor_updates   |Defines whether minor update should be automatically installed.                                         |TrueClass, FalseClass|`false`
no_reboot_with_logged_users  |Disables automatic reboot with logged-on users.                                                         |TrueClass, FalseClass|`true`
automatic_update_behavior    |Defines auto update behavior.                                                                           |Symbol`*`            |`:disabled`
detection_frequency          |Defines times in hours between detection cycles.                                                        |FixNum               |`22`
schedule_install_day         |Defines the day of the week to schedule update install.                                                 |Symbol`**`           |`:every_day`
schedule_install_time        |Defines the time of day in 24-hour format to schedule update install.                                   |FixNum (1-23)        |`0`
schedule_retry_wait          |Defines the time in minutes to wait at startup before applying update from a missed scheduled time      |FixNum (0-60)        |`0`
reboot_warning               |Defines time in minutes of the restart warning countdown after reboot-required updates automatic install|FixNum (1-30)        |`5`
reboot_prompt_timeout        |Defines time in minutes between prompts for a scheduled restart                                         |FixNum (1-1440)      |`10`

`*` automatic_update_behavior values are:

```ruby
# :disabled  = Disables automatic updates
# :detect    = Only notify users of new updates
# :download  = Download updates, but let users install them
# :install   = Download and install updates
# :manual    = Lets the users configure the behavior
```

`**` schedule_install_day possible values are: `:every_day`, `:sunday`, `:monday`, `:tuesday`, `:wednesday`, `:thursday`, `:friday`, `:saturday`

### wsus-client::update

This recipe performs a synchronous detection and install of available Windows updates.

#### Attributes

The following attributes are used to configure the `wsus-client::update` recipe, accessible via `node['wsus_client']['update'][attribute]`.

Attribute        | Description                                             | Type                  | Default
-----------------|---------------------------------------------------------|-----------------------|--------
action           | Define actions performed by the update recipe.          | Array of symbols      | `[:download, :install]`
download_timeout | Time alloted to the download operation before failing.  | Integer               | `3600`
install_timeout  | Time alloted to the install operation before failing.   | Integer               | `3600`
handle_reboot    | Indicate whether to reboot or not after update install. | TrueClass, FalseClass | `false`
reboot_delay     | The amount of time (in minutes) to delay the reboot.    | Integer               | `1`

# Contributing

1. Fork the [repository on Github][repository]
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

# License and Authors

Authors: [Baptiste Courtois][author] (<b.courtois@criteo.com>)

```text
Copyright 2014-2015, Criteo.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[author]:                   https://github.com/Annih
[repository]:               https://github.com/criteo-cookbooks/wsus-client
[license]:                  https://img.shields.io/github/license/criteo-cookbooks/wsus-client.svg
[client_targeting]:         https://technet.microsoft.com/library/cc720450
[wsus_registry]:            https://technet.microsoft.com/library/dd939844
[build_status]:             https://api.travis-ci.org/criteo-cookbooks/wsus-client.svg?branch=master
[cookbook_version]:         https://img.shields.io/cookbook/v/wsus-client.svg
[supermarket_url]:          https://supermarket.chef.io/cookbooks/wsus-client
