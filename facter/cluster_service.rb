Facter.add('cluster_service') do
  confine osfamily: :windows
  setcode do
    begin
      require 'win32/service'

      cluster_service = Win32::Service.exists?('ClusSvc')
      cluster_service
    rescue
      cluster_service = 'Unknown'
      cluster_service
    end
  end
end
