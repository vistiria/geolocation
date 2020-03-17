require 'spec_helpers'

describe 'api' do
  before :each do
    Geolocation::Models::Location.delete_all
  end
  context 'post geolocation based on ip' do
    it "should respond with 503 when ipstack is not available" do
      expected = {"error":"Service Unavailable"}.to_json
      allow_any_instance_of(Geolocation::IpstackService).to receive(:call).and_return([false, 503, {:error=>"Service Unavailable"}])

      post '/ip/216.58.215.67'

      expect(last_response.status).to eq 503
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(ip: '216.58.215.67')).not_to exist
    end

    it "should respond with 404 when not found" do
      expected = {"error":"The requested resource does not exist."}.to_json
      allow_any_instance_of(Geolocation::IpstackService).to receive(:call).and_return([false, 404, {:error=>"The requested resource does not exist."}])

      post '/ip/216.58.215.67'

      expect(last_response.status).to eq 404
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(ip: '216.58.215.67')).not_to exist
    end

    it "should respond with 201 when location created" do
      expected = {"ip":"216.58.215.67","host":nil, "latitude":-27.467580795288086,"longitude":153.02789306640625}.to_json
      allow_any_instance_of(Geolocation::IpstackService).to receive(:call).and_return([true, 200, {"ip"=>"216.58.215.67", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625}])

      post '/ip/216.58.215.67'

      expect(last_response.status).to eq 201
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(ip: '216.58.215.67')).to exist
    end

    it "should respond with 422 when invalid ip" do
      expected = {"error":"provided ip: i_am_invalid is not valid IPv4 address"}.to_json

      post '/ip/i_am_invalid'

      expect(last_response.status).to eq 422
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(ip: 'i_am_invalid')).not_to exist
    end

    it "should respond with 422 when geolocation already exists" do
      Geolocation::Models::Location.create!({ip:"216.58.215.67", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})
      expected = {"error":"geolocation data already exists"}.to_json

      post '/ip/216.58.215.67'

      expect(last_response.status).to eq 422
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(ip: '216.58.215.67').count).to eq 1
    end
  end

  context 'post geolocation based on url' do
    it "should respond with 503 when ipstack is not available" do
      expected = {"error":"Service Unavailable"}.to_json
      allow_any_instance_of(Geolocation::IpstackService).to receive(:call).and_return([false, 503, {:error=>"Service Unavailable"}])

      post '/url/www.google.pl'

      expect(last_response.status).to eq 503
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(host: 'google.pl')).not_to exist
    end

    it "should respond with 404 when not found" do
      expected = {"error":"The requested resource does not exist."}.to_json
      allow_any_instance_of(Geolocation::IpstackService).to receive(:call).and_return([false, 404, {:error=>"The requested resource does not exist."}])

      post '/url/www.google.pl'

      expect(last_response.status).to eq 404
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(host: 'google.pl')).not_to exist
    end

    it "should respond with 201 when location created" do
      expected = {"ip":"216.58.215.67","host":"google.com", "latitude":-27.467580795288086,"longitude":153.02789306640625}.to_json
      allow_any_instance_of(Geolocation::IpstackService).to receive(:call).and_return([true, 200, {"ip"=>"216.58.215.67", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625}])

      post '/url/www.google.com'

      expect(last_response.status).to eq 201
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(host: 'google.com')).to exist
    end

    it "should respond with 201 when location created and when escaped uri is provided" do
      expected = {"ip":"216.58.215.67","host":"wikipedia.org", "latitude":-27.467580795288086,"longitude":153.02789306640625}.to_json
      allow_any_instance_of(Geolocation::IpstackService).to receive(:call).and_return([true, 200, {"ip"=>"216.58.215.67", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625}])

      post '/url/http%3A%2F%2Fwww.wikipedia.org%2Fwiki%2FURL'

      expect(last_response.status).to eq 201
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(host: 'wikipedia.org')).to exist
    end

    it "should respond with 422 when invalid url" do
      expected = {"error":"provided url: i_am_invalid is not valid"}.to_json

      post '/url/i_am_invalid'

      expect(last_response.status).to eq 422
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(ip: 'i_am_invalid')).not_to exist
    end

    it "should respond with 422 when geolocation already exists" do
      Geolocation::Models::Location.create!({ip: "216.58.215.67", host: "google.com", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})
      expected = {"error":"geolocation data already exists"}.to_json

      post '/url/google.com'

      expect(last_response.status).to eq 422
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(ip: '216.58.215.67', host: "google.com").count).to eq 1
    end

    it "should respond with 201 when geolocation with ip, but without host already exists" do
      Geolocation::Models::Location.create!({ip: "216.58.215.67", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})
      expected = {"ip":"216.58.215.67","host":"google.com","latitude":-27.467580795288086,"longitude":153.02789306640625}.to_json
      allow_any_instance_of(Geolocation::Server::Api).to receive(:check_if_valid_url).and_return(["216.58.215.67", "google.com"])
      allow_any_instance_of(Geolocation::IpstackService).to receive(:call).and_return([true, 200, {"ip"=>"216.58.215.67", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625}])

      post '/url/google.com'

      expect(last_response.status).to eq 201
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.where(ip: '216.58.215.67', host: "google.com").count).to eq 1
      expect(Geolocation::Models::Location.where(host: "google.com").count).to eq 1
      expect(Geolocation::Models::Location.where(ip: '216.58.215.67').count).to eq 1
    end
  end

  context 'get geolocation based on ip' do
    it "should respond with 404 when there isn't one" do
      expected = {"error":"geolocation data does not exist"}.to_json

      get '/ip/216.58.215.67'

      expect(last_response.status).to eq 404
      expect(last_response.body).to eq expected
    end

    it "should respond with 422 when invalid ip" do
      expected = {"error":"provided ip: i_am_invalid is not valid IPv4 address"}.to_json

      get '/ip/i_am_invalid'

      expect(last_response.status).to eq 422
      expect(last_response.body).to eq expected
    end

    it "should respond with 200 when found" do
      Geolocation::Models::Location.create!({ip: "216.58.215.67", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})
      expected = {"ip":"216.58.215.67","host":nil,"latitude":-27.467580795288086,"longitude":153.02789306640625}.to_json

      get '/ip/216.58.215.67'

      expect(last_response.status).to eq 200
      expect(last_response.body).to eq expected
    end
  end

  context 'get geolocation based on url' do
    it "should respond with 404 when there isn't one" do
      expected = {"error":"geolocation data does not exist"}.to_json

      get '/url/www.google.com'

      expect(last_response.status).to eq 404
      expect(last_response.body).to eq expected
    end

    it "should respond with 422 when invalid url" do
      expected = {"error":"provided url: i_am_invalid is not valid"}.to_json

      get '/url/i_am_invalid'

      expect(last_response.status).to eq 422
      expect(last_response.body).to eq expected
    end

    it "should respond with 200 when found by host" do
      Geolocation::Models::Location.create!({ip: "216.58.215.67", host: "google.com", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})
      expected = {"ip":"216.58.215.67","host": "google.com", "latitude":-27.467580795288086,"longitude":153.02789306640625}.to_json

      get '/url/www.google.com'

      expect(last_response.status).to eq 200
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.count).to eq 1
    end

    it "should respond with 200 when found by host and when escaped uri is provided" do
      Geolocation::Models::Location.create!({ip: "216.58.215.67", host: "wikipedia.org", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})
      expected = {"ip":"216.58.215.67","host": "wikipedia.org", "latitude":-27.467580795288086,"longitude":153.02789306640625}.to_json

      get '/url/http%3A%2F%2Fwww.wikipedia.org%2Fwiki%2FURL'

      expect(last_response.status).to eq 200
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.count).to eq 1
    end

    it "should respond with 200 when found by ip" do
      Geolocation::Models::Location.create!({ip: "216.58.215.67", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})
      expected = {"ip":"216.58.215.67","host": "google.com", "latitude":-27.467580795288086,"longitude":153.02789306640625}.to_json
      allow_any_instance_of(Geolocation::Server::Api).to receive(:check_if_valid_url).and_return(["216.58.215.67", "google.com"])

      get '/url/www.google.com'

      expect(last_response.status).to eq 200
      expect(last_response.body).to eq expected
      expect(Geolocation::Models::Location.count).to eq 1
      expect(Geolocation::Models::Location.where(ip: '216.58.215.67', host: "google.com").count).to eq 1
    end
  end

  context 'delete geolocation based on ip' do
    it "should respond with 404 when there isn't one" do
      expected = {"error":"geolocation data does not exist"}.to_json

      delete '/ip/216.58.215.67'

      expect(last_response.status).to eq 404
      expect(last_response.body).to eq expected
    end

    it "should respond with 422 when invalid ip" do
      expected = {"error":"provided ip: i_am_invalid is not valid IPv4 address"}.to_json

      delete '/ip/i_am_invalid'

      expect(last_response.status).to eq 422
      expect(last_response.body).to eq expected
    end

    it "should respond with 204 and remove geolocation when there is one" do
      Geolocation::Models::Location.create!({ip: "216.58.215.67", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})

      delete '/ip/216.58.215.67'

      expect(last_response.status).to eq 204
      expect(last_response.body).to eq ""
      expect(Geolocation::Models::Location.count).to eq 0
    end
  end

  context 'delete geolocation based on url' do
    it "should respond with 404 when there isn't one" do
      expected = {"error":"geolocation data does not exist"}.to_json

      delete '/url/www.google.pl'

      expect(last_response.status).to eq 404
      expect(last_response.body).to eq expected
    end

    it "should respond with 422 when invalid url" do
      expected = {"error":"provided url: i_am_invalid is not valid"}.to_json

      delete '/url/i_am_invalid'

      expect(last_response.status).to eq 422
      expect(last_response.body).to eq expected
    end

    it "should respond with 204 and remove geolocation when there is one with matching host" do
      Geolocation::Models::Location.create!({ip: "216.58.215.67", host: "google.com", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})

      delete '/url/www.google.com'

      expect(last_response.status).to eq 204
      expect(last_response.body).to eq ""
      expect(Geolocation::Models::Location.count).to eq 0
    end

    it "should respond with 204 and remove geolocation when there is one with matching host and when escaped uri is provided" do
      Geolocation::Models::Location.create!({ip: "216.58.215.67", host: "wikipedia.org", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})
      allow_any_instance_of(Geolocation::Server::Api).to receive(:check_if_valid_url).and_return(["216.58.215.67", "wikipedia.org"])

      delete '/url/http%3A%2F%2Fwww.wikipedia.org%2Fwiki%2FURL'

      expect(last_response.status).to eq 204
      expect(last_response.body).to eq ""
      expect(Geolocation::Models::Location.count).to eq 0
    end

    it "should respond with 204 and remove geolocation when there is one with matching ip" do
      Geolocation::Models::Location.create!({ip: "216.58.215.67", "latitude"=>-27.467580795288086, "longitude"=>153.02789306640625})
      allow_any_instance_of(Geolocation::Server::Api).to receive(:check_if_valid_url).and_return(["216.58.215.67", "google.com"])

      delete '/url/www.google.com'

      expect(last_response.status).to eq 204
      expect(last_response.body).to eq ""
      expect(Geolocation::Models::Location.count).to eq 0
    end
  end
end
