# Function takes a cluster name value and attempts to create a NetBios compliant name for the Availability Group listener
# Usage:
# $ag_listener_name = create_ag_listener_name(cluster)

Puppet::Functions.create_function(:create_ag_listener_name) do
  dispatch :create_ag_listener_name do
    param 'String', :cluster_name
  end

  def create_ag_listener_name(cluster_name)
    listener_name = cluster_name.sub('-cl', '-ag01')

    # Attempt to build compliant AG Listener Name
    if listener_name.length > 15
      listener_name = listener_name.sub('db', '')
    end

    if listener_name.length > 15
      listener_name = listener_name.sub('ag01', 'ag1')
    end

    if listener_name.length > 15
      listener_name = listener_name.sub('-', '')
    end

    if listener_name.length > 15
      listener_name = 'none'
    end

    listener_name
  end
end
