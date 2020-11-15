require 'win32/registry'

begin
  base_keyname = 'Software\Microsoft\Microsoft SQL Server'
  access = Win32::Registry::KEY_READ
  installedinstances = Win32::Registry::HKEY_LOCAL_MACHINE.open(base_keyname, access) { |reg| reg['InstalledInstances'] }
  instance_name = installedinstances[0]
  instance_version_path = 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL'
  instance_version = Win32::Registry::HKEY_LOCAL_MACHINE.open(instance_version_path, access) { |reg| reg[instance_name] }
  sql_version_path = "SOFTWARE\\Microsoft\\Microsoft SQL Server\\#{instance_version}\\Setup"
rescue
  instance_version = 'none'
end

Facter.add('sql_version') do
  confine osfamily: :windows
  setcode do
    begin
      if instance_version == 'none'
        sql_version = 'none'
      else
        sql_version_raw = Win32::Registry::HKEY_LOCAL_MACHINE.open(sql_version_path, access) { |reg| reg['Version'] }
        sql_major_version = sql_version_raw.split('.')[0]
        sql_version = case sql_major_version
                      when '15'
                        'sql 2019'
                      when '14'
                        'sql 2017'
                      when '13'
                        'sql 2016'
                      when '12'
                        'sql 2014'
                      when '11'
                        'sql 2012'
                      when '10'
                        'sql 2008'
                      else
                        'unknown'
                      end
      end
      sql_version
    rescue
      sql_version = 'unknown'
      sql_version
    end
  end
end
