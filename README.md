# xzscanner

This module utilizes a very simple bash script proposed at https://www.openwall.com/lists/oss-security/2024/03/29/4 to monitor your infrastructure for vulnerable installations of liblzma.

> This module is not supported or maintained by Puppet and does not qualify for Puppet Support plans. It's provided without guarantee or warranty and you can use it at your own risk. All bugfixes, updates, and new feature development will come from community contributions.
>
> [tier:community]

## Description

This module can be used in two ways:
1. Run the xzscanner::run_scan task on a node. It will show if the node has a vulnerable liblzma ("yes") or not ("no").
2. Apply the xzscanner class to any Linux node with a Puppet Agent. This will set up a scheduled task to scan for the vulnerability once per day, and keeps a custom fact called 'xzscanner' updated with the results.

## Setup

### What xzscanner affects

When the class is applied, the module provides an additional fact (`xzscanner`). This
also adds a cron job that defaults to running once per day. Files are saved to /opt/puppetlabs/xzscanner. 

## Usage

### Manifest
Include the module:
```puppet
include xzscanner
```

Advanced usage:
```puppet
class { 'xzscanner':
  cron_hour = 12,
  cron_minute = 30,
}
```

### Task
Run a basic scan from the command line:
```bash
puppet task run xzscanner::run_scan --nodes <nodes>
```
## Reference
### Manifest Parameters
- ensure: Set to 'absent' to remove artifacts (cron/scheduled tasks, files) from nodes. (default 'present')
- scan_data_owner: User to own xzscanner files. (default 'root')
- scan_data_group: Group to own xzscanner files. (default 'root')
- cron_user: User to run the cron job for scanning. (default 'root')
- cron_hour: Hour for cron job run. (default 'absent')
- cron_month: Month for cron job run. (default 'absent')
- cron_monthday: Day of the month for cron job run. (default 'absent')
- cron_weekday: Day of the week for cron job run. (default 'absent')
- cron_minutes: Minute for cron job run. (default is a random int between 0 and 59)

## Limitations

Tested on a limited number of OS flavors. Please submit fixes if you find bugs!

## Development

Fork, develop, submit pull request.


## Contributors
- [Nick Burgan](mailto:nickb@puppet.com)

Class/fact code heavily cribbed from [os_patching](https://github.com/albatrossflavour/puppet_os_patching) by [Tony Green](mailto:tgreen@albatrossflavour.com)