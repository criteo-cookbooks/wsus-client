Wsus-client Cookbook
=============
Configures WSUS clients to retrieve approved updates.


Requirements
------------
This cookbook requires Chef 11.10.0+.

### Platforms
* Windows XP
* Windows Vista
* Windows Server 2003 R2
* Windows 7
* Windows Server 2008 (R1, R2)
* Windows 8 and 8.1
* Windows Server 2012 (R1, R2)

### Cookbooks
The following cookbook is required as noted:

* [powershell][powershell_cookbook]

    `wsus-client::update` leverages the powershell_script resource and requires powershell 4

Attributes
----------
TODO: List your cookbook attributes here.

e.g.
#### wsus-client::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['wsus_client']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### wsus-client::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `wsus-client` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[wsus-client]"
  ]
}
```

Contributing
------------
1. Fork the [repository on Github][repository]
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: [Baptiste Courtois][author] (<b.courtois@criteo.com>)

```text
Copyright 2014, Criteo.

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
[powershell_cookbook]:      https://community.opscode.com/cookbooks/powershell