# Usage:
# $reserved_ip = get_d42_ip(username, password, network_id)
require 'json'
require 'net/http'
require 'openssl'
require 'securerandom'

Puppet::Functions.create_function(:get_d42_ip) do
  dispatch :get_d42_ip do
    param 'String', :username
    param 'String', :password
    param 'String', :network_id
  end

  def get_d42_ip(username, password, network_id)
    base_url = 'https://device42.athenahealth.com//api/1.0/'
    network_path = "subnets/?network=#{network_id}"

    url = "#{base_url}#{network_path}"
    uri = URI(url)

    http = Net::HTTP.new(uri.host, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new uri.request_uri
    request.basic_auth username, password

    response = http.request request

    data = JSON.parse(response.body)
    subnet = data.fetch('subnets')

    name = 'exsre-' + SecureRandom.uuid
    reserve_uri = URI("#{base_url}suggest_ip/?subnet_id=#{subnet[0].fetch('subnet_id')}&#{subnet[0].fetch('mask_bits')}&reserve_ip=yes&name=#{name}")

    reserve_request = Net::HTTP::Get.new reserve_uri.request_uri
    reserve_request.set_content_type('application/x-www-form-urlencoded')
    reserve_request.basic_auth username, password

    reserve_response = http.request reserve_request
    reserve_data = JSON.parse(reserve_response.body)

    if reserve_response.is_a? Net::HTTPSuccess
      { 'network_lookup' => response.code,
        'reserve_lookup' => reserve_response.code,
        'subnet_mask'    => subnet[0].fetch('mask_bits'),
        'reserve_ip'     => reserve_data.fetch('ip'),
        'subnet_id'      => subnet[0].fetch('subnet_id'),
        'error'          => 'false' }
    else
      { 'network_lookup' => response.code,
        'reserve_lookup' => reserve_response.code,
        'subnet_mask'    => subnet[0].fetch('mask_bits'),
        'reserve_ip'     => reserve_data.fetch('ip'),
        'subnet_id'      => subnet[0].fetch('subnet_id'),
        'error'          => 'true' }
    end
  end
end
