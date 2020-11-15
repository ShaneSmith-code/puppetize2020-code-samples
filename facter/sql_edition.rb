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

Facter.add('sql_edition') do
  confine osfamily: :windows
  setcode do
    begin
      if instance_version == 'none'
        sql_edition = 'none'
      else
        sql_edition_raw = Win32::Registry::HKEY_LOCAL_MACHINE.open(sql_version_path, access) { |reg| reg['Edition'] }
        sql_edition = sql_edition_raw.split(':')[0]
      end
      sql_edition
    rescue
      sql_edition = 'unknown'
      sql_edition
    end
  end
end
