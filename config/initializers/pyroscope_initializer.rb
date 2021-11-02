require "pyroscope"

Pyroscope.configure do |config|
  config.app_name = "abalone.ruby.server" # replace this with some name for your application
  config.server_address = "http://localhost:4040" # replace this with the address of your pyroscope server
end
