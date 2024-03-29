# @param present
#   Whether the scanner should be installed
# @param scan_data_owner
#   Owner of the generated scan results
# @param scan_data_group
#   Group of the generated scan results
# @param cron_user
# @param cron_hour
# @param cron_month
# @param cron_monthday
# @param cron_weekday
# @param cron_minute
class xzscanner (
  Enum['present', 'absent'] $ensure  = 'present',
  String $scan_data_owner            = 'root',
  String $scan_data_group            = 'root',
  String $cron_user                  = 'root',
  $cron_hour                         = absent,
  $cron_month                        = absent,
  $cron_monthday                     = absent,
  $cron_weekday                      = absent,
  $cron_minute                       = fqdn_rand(59),
) {

  # Run things/set up files, or clean up when ensure=>absent?
  $generate_scan_data_exec = $ensure ? {
    'present' => 'xzscanner generate scan data',
    default   => undef,
  }

  $fact_upload_exec = $ensure ? {
    'present' => 'xzscanner fact upload',
    default   => undef,
  }

  $ensure_file = $ensure ? {
    'present' => 'file',
    default   => 'absent',
  }

  $ensure_dir = $ensure ? {
    'present' => 'directory',
    default   => 'absent',
  }

  $puppet_bin = '/opt/puppetlabs/bin/puppet'
  $fact_upload_params = "facts upload --environment ${environment}"
  $fact_upload_cmd = "${puppet_bin} ${fact_upload_params}"
  $cache_dir = '/opt/puppetlabs/xzscanner'
  $scan_script = 'scan_data_generation.sh'
  $scan_script_mode = '0700'
  File {
    owner => $scan_data_owner,
    group => $scan_data_group,
    mode  => '0644',
  }
  $scan_bin = 'detect.sh'
  $checksum = 'a1974bfd83f404fd7f15e4122017a2cda983654fec1f37992e5679f0df1f642e'
  $scan_cmd = "${cache_dir}/${scan_script}"

  if $generate_scan_data_exec {
    exec { $generate_scan_data_exec:
      command     => $scan_cmd,
      user        => $scan_data_owner,
      group       => $scan_data_group,
      refreshonly => true,
      require     => File[$scan_cmd],
      timeout     => 0,
    }
  }

  cron { 'xzscanner - Cache scan data':
    ensure   => $ensure,
    command  => $scan_cmd,
    user     => $cron_user,
    hour     => $cron_hour,
    minute   => $cron_minute,
    month    => $cron_month,
    monthday => $cron_monthday,
    weekday  => $cron_weekday,
    require  => File[$scan_cmd],
  }

  file { $cache_dir:
    ensure => $ensure_dir,
    force  => true,
  }

  file { $scan_bin:
    ensure         => $ensure_file,
    path           => "${cache_dir}/${scan_bin}",
    source         => "puppet:///modules/xzscanner/${scan_bin}",
    mode           => $scan_script_mode,
    checksum       => 'sha256',
    checksum_value => $checksum,
  }

  $template_data = {
    'cache_dir'          => $cache_dir,
    'puppet_bin'         => $puppet_bin,
    'fact_upload_params' => $fact_upload_params,
    'scan_bin'           => $scan_bin,
  }
  file { $scan_cmd:
    ensure  => $ensure_file,
    mode    => $scan_script_mode,
    content => epp("${module_name}/${scan_script}.epp", $template_data),
    require => File[$scan_bin],
    notify  => Exec[$generate_scan_data_exec],
  }

  if $fact_upload_exec {
    exec { $fact_upload_exec:
      command     => $fact_upload_cmd,
      path        => ['/usr/bin', '/bin', '/sbin', '/usr/local/bin', $cache_dir],
      refreshonly => true,
      subscribe   => File[$scan_cmd, $cache_dir],
    }
  }
}
