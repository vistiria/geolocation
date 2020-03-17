Geolocation API
=============
##### Version: v1.0

Simple API to store geolocation data.
Based on IPv4 or url, you can get, post and delete geolocation data.

Prerequests
-------------
Ruby: ruby-2.6.3
MongoDB

Initial local setup for Linux
-------------

Install MongoDB, you can use documentation:

https://docs.mongodb.com/manual/installation/

make sure that the mongod process is running
e.g. for systemctl
```
sudo systemctl status mongod
```
Clone repositiry and set the project to be up and running
```
# clone repository
git clone https://github.com/iresine/geolocation
cd geolocation/

# make sure you have ruby-2.6.3 ruby version
# you can use rvm https://rvm.io/ to install ruby and manage versions

# install dependencies
gem install bundler
bundle install

# set API_ACCESS_KEY environment variable
# it's available when you are registered to ipstack: https://ipstack.com/quickstart
export API_ACCESS_KEY=<Your ipstack API Access Key>

# start service
# e.g. starting on 8080 port
./bin/geolocation_api -p 8080
```

API endpoints
----------------
swagger API endpoints documentation:
swagger/geolocation.yaml
you can open this file in online editor: https://editor.swagger.io/

Example of curl commands
-------------
```
curl -X POST "http://localhost:8080/geolocation/v1.0/url/http%3A%2F%2Fwww.wikipedia.org%2Fwiki%2FURL" -v -H "accept: application/json"
# {"ip":"91.198.174.192","host":"wikipedia.org","latitude":52.309051513671875,"longitude":4.940189838409424}

curl -X POST "http://localhost:8080/geolocation/v1.0/ip/192.30.252.153" -v -H "accept: application/json"
# {"ip":"192.30.252.153","host":null,"latitude":37.76784896850586,"longitude":-122.39286041259766}

curl -X GET "http://localhost:8080/geolocation/v1.0/url/http%3A%2F%2Fwww.wikipedia.org%2Fwiki%2FURL" -v -H "accept: application/json"
# {"ip":"91.198.174.192","host":"wikipedia.org","latitude":52.309051513671875,"longitude":4.940189838409424}

curl -X GET "http://localhost:8080/geolocation/v1.0/ip/192.30.252.153" -v -H "accept: application/json"
# {"ip":"192.30.252.153","host":null,"latitude":37.76784896850586,"longitude":-122.39286041259766}

curl -X DELETE "http://localhost:8080/geolocation/v1.0/url/http%3A%2F%2Fwww.wikipedia.org%2Fwiki%2FURL" -v
curl -X DELETE "http://localhost:8080/geolocation/v1.0/ip/192.30.252.153" -v
```

How to run tests
----------------
```
bundle exec rspec
```

Problems
--------
* URL(host) is identified by one IP address, many IP adresses per url(host) are not supported
* Data in database can be outdated for urls - in case IP address have changed for particular url(host)
