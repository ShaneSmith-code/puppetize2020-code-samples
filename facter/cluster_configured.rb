Facter.add('cluster_configured') do
  confine osfamily: :windows
  setcode do
    begin
      require 'win32/registry'
      reg_type = Win32::Registry::KEY_READ
      Win32::Registry::HKEY_LOCAL_MACHINE.open(\
        'Cluster', reg_type
      ) { |reg| reg['ClusterName'] }
    rescue
      'none'
    end
  end
end
