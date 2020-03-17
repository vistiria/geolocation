require 'spec_helpers'

describe Geolocation::IpstackService do
  describe '#build_url' do
    it 'returns proper endpiont' do
      is = Geolocation::IpstackService.new(ip: "172.217.16.4")
      expect(is.send(:build_url)).to eq("//api.ipstack.com/172.217.16.4?access_key=test_acces_key&fields=ip,latitude,longitude&language=en&output=json")
    end
  end

  describe '#process_response' do

    context 'invalid access key' do
      it 'returns proper response' do
        response = {"success":false,"error":{"code":101,"type":"invalid_access_key","info":"You have not supplied a valid API Access Key."}}.with_indifferent_access

        is = Geolocation::IpstackService.new(ip: "172.217.16.4")
        expect(is.send(:process_response, response, true, 200 )).to eq([false, 503, {:error=>"Service Unavailable"}])
      end
    end

    context 'not found' do
      it 'returns proper response' do
        response = {"success":false,"error":{"code":404,"type":"404_not_found","info":"The requested resource does not exist."}}.with_indifferent_access

        is = Geolocation::IpstackService.new(ip: "172.217.16.4")
        expect(is.send(:process_response, response, true, 200 )).to eq([false, 404, {:error=>"The requested resource does not exist."}])
      end
    end

    context 'invalid ip param' do
      it 'returns proper response' do
        response = {"ip":"i_am_not_ip","latitude":nil,"longitude":nil}.with_indifferent_access

        is = Geolocation::IpstackService.new(ip: "i_am_not_ip")
        expect(is.send(:process_response, response, true, 200 )).to eq([false, 404, {:error=>"The requested resource does not exist."}])
      end
    end

    context 'ip found' do
      it 'returns proper response' do
        response = {"ip":"1.2.3.4","latitude":-27.467580795288086,"longitude":153.02789306640625}.with_indifferent_access

        is = Geolocation::IpstackService.new(ip: "1.2.3.4")
        expect(is.send(:process_response, response, true, 200 )).to eq([true, 200, {"ip"=>"1.2.3.4", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625}])
      end
    end

    context 'service unavailable' do
      it 'returns proper response' do

        is = Geolocation::IpstackService.new(ip: "1.2.3.4")
        expect(is.send(:process_response, {}, false, 500 )).to eq([false, 503, {:error=>"Service Unavailable"}])
      end
    end

  end
end
