Facter.add('xzscanner') do
  confine { Facter.value(:kernel) == 'Linux' }
  setcode do
    errors = []
    warnings = {}
    last_runtime = ''
    data = {}

    cache_dir = '/opt/puppetlabs/xzscanner'
    scan_file = cache_dir + '/vulnerable_status'
    vulnerable = 'unknown'

    if File.file?(scan_file)
      last_runtime = File.mtime(scan_file)
      if (Time.now - last_runtime) / (24 * 3600) > 10
        warnings['scan_file_time'] = 'Scan file has not been updated in 10 days'
      end

      vulnerable = File.read(scan_file).strip.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    else
      warnings['scan_file'] = 'Scan file not found'
    end

    error_file = cache_dir + '/scan_errors'
    if File.file?(error_file)
      errors = File.readlines(error_file).map { |l| l.strip.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') }.reject { |l| l.empty? }
    end

    data['vulnerable'] = vulnerable
    data['warnings'] = warnings
    data['errors'] = errors
    data['last_scan'] = last_runtime
    data
  end
end
