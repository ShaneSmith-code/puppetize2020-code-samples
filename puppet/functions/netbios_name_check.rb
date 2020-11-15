# Function to analyze a NETBIOS name and sensure it adheres to NETBIOS restrictions and best paractices
# Usage:
# $netbios_name = netbios_name_check(name)

require 'rubygems'

Puppet::Functions.create_function(:netbios_name_check) do
  dispatch :netbios_name_check do
    param 'String', :name
  end

  def netbios_name_check(name)
    if name !~ %r{[a-z]}
      'no alpha character'
    elsif name !~ %r{^[a-z]|^[0-9]}
      'missing alpha numeric starting character'
    elsif name =~ %r{-$|[.]}
      'forbidden special character usage'
    elsif name.length > 15
      'over 15 characters in length'
    else
      'pass'
    end
  end
end
