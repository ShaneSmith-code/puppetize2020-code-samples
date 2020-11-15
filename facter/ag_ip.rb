require 'win32/registry'

Facter.add('ag_ip') do
  confine osfamily: :windows
  setcode do
    begin
      access = Win32::Registry::KEY_READ
      ag_key_value = 'Name'
      ag_listener_key = 'Cluster\Resources'
      basic_ip_regex = Regexp.new('^[0-9]*[.][0-9]*[.][0-9]*[.][0-9]*$')
      ag_listeners = []
      ag_listener_lookup = []

      cluster_check = Facter.value(:cluster_service)

      if cluster_check
        ag_result = Facter.value(:ag_name)

        unless ag_result.nil?
          listener_regex = Regexp.new(ag_result + '_')

          Win32::Registry::HKEY_LOCAL_MACHINE.open(ag_listener_key, access) do |reg|
            reg.each_key do |sub_key|
              k = reg.open(sub_key)
              ag_listener_lookup.push(k[ag_key_value])
            end
          end

          ag_listener_lookup.each do |name|
            next unless name.downcase =~ listener_regex
            temp = name.split('_', 2)
            if temp[1] =~ basic_ip_regex
              ag_listeners.push(temp[1])
            end
          end
        end
      end

      if ag_listeners.empty?
        ag_listeners.push('none')
      end

      ag_listeners
    rescue
      ag_listeners = ['unknown']
      ag_listeners
    end
  end
end
