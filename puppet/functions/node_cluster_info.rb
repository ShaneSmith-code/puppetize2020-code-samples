# Usage:
# $cluster_available = node_cluster_info($clustername, $domain)

require 'rubygems'
require 'resolv'

Puppet::Functions.create_function(:node_cluster_info) do
  dispatch :node_cluster_info do
    param 'String', :clustername
    param 'String', :domain_suffix
  end

  def node_cluster_info(clustername, domain_suffix)
    retry_count = 10

    begin
      cluster_name_split = clustername.split('-')
      a_node_name = cluster_name_split[0] + 'a'
      cluster_lookup = Resolv.getaddress(clustername + '.' + domain_suffix)
      a_node_ip = Resolv.getaddress(a_node_name + '.' + domain_suffix)

      { 'cluster_name'       => clustername,
        'primary_cluster_ip' => cluster_lookup,
        'a_node_name'        => a_node_name,
        'a_node_ip'          => a_node_ip }
    rescue
      retry_count -= 1
      if retry_count > 0
        sleep(60)
        retry
      else
        { 'cluster_name' => clustername,
          'primary_cluster_ip' => 'none',
          'a_node_name'        => 'none',
          'a_node_ip'          => 'none' }
      end
    end
  end
end
