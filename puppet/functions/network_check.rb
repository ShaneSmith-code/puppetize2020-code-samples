# Function takes an array of IP addresses, a network id and a subnet mask. The function will use the subnet mask and perform ANDING
# on all of the IP addresses in the array and determine if any of them exist on the network id that was passed and return true if their is a match
# Usage:
# $ip_on_network = network_check(ag_ip,"10.224.82.0","255.255.255.0")

Puppet::Functions.create_function(:network_check) do
  dispatch :network_check do
    param 'Array', :network_array
    param 'String', :host_network
    param 'String', :netmask
  end

  def network_check(network_array, host_network, netmask)
    network_configured = false
    subnet_split = netmask.split('.')
    network_results = Hash.new {}

    network_array.each do |ip_item|
      ip_split = ip_item.split('.')
      count = 0
      network_id = nil

      ip_split.each do |ip_octet|
        result = ip_octet.to_i & subnet_split[count].to_i
        network_id = "#{network_id}#{result}."
        count += 1
      end
      network_id = network_id.chomp('.')
      network_results[network_id] = ip_item
    end

    network_results.keys.each do |net_value|
      if net_value == host_network
        network_configured = true
        break
      end
    end

    { 'network_check_results'    => network_results,
      'network_configured'       => network_configured }
  rescue
    { 'network_check_results'    => network_results,
      'network_configured'       => network_configured }
  end
end
