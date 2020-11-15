require 'win32/registry'

Facter.add('ag_name') do
  confine osfamily: :windows
  setcode do
    begin
      access = Win32::Registry::KEY_READ
      ag_group_key = 'Cluster\Groups'
      ag_key_value = 'Name'
      ag_result = nil
      ag_lookup = []

      cluster_check = Facter.value(:cluster_service)

      if cluster_check
        Win32::Registry::HKEY_LOCAL_MACHINE.open(ag_group_key, access) do |reg|
          reg.each_key do |sub_key|
            k = reg.open(sub_key)
            ag_lookup.push(k[ag_key_value])
          end
        end

        unless ag_lookup.nil?
          ag_lookup.each do |name|
            if name.downcase =~ %r{ag[0-1][0-9]$|ag[0-1]$|ag[0-1][0-9]-|ag[0-1]-$}
              ag_result = name
            end
          end
        end
      end

      if ag_result.nil?
        ag_result = 'none'
      end
      ag_result.downcase
    rescue
      ag_result = 'unknown'
      ag_result.downcase
    end
  end
end
