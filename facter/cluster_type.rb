require 'win32/registry'

Facter.add('cluster_type') do
  confine osfamily: :windows
  setcode do
    begin
      access = Win32::Registry::KEY_READ
      node_key_value = 'NodeName'
      node_listener_key = 'Cluster\Nodes'
      node_names = []
      cluster_type = ''

      cluster_check = Facter.value(:cluster_service)

      if cluster_check
        Win32::Registry::HKEY_LOCAL_MACHINE.open(node_listener_key, access) do |reg|
          reg.each_key do |sub_key|
            k = reg.open(sub_key)
            node_names.push(k[node_key_value])
          end
        end

        node_names.map!(&:downcase)
        node_names = node_names.sort

        unless node_names.empty?
          node_names.each do |name|
            last_index = name.length - 1
            node_letter = name[last_index]
            cluster_type.concat(node_letter)
          end
        end
      end

      if cluster_type.empty?
        cluster_type = 'none'
      end
      cluster_type.downcase
    rescue
      cluster_type = 'unknown'
      cluster_type.downcase
    end
  end
end
