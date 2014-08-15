require 'minitest/autorun'

require "java"

VENDOR_PATH = File.expand_path("../../vendor", __FILE__)

# load all vendored jar dependencies
Dir["#{VENDOR_PATH}/*.jar"].each { |jar| require jar }

# load native jars for platform
if RbConfig::CONFIG["target_cpu"] =~ /x86/ && RbConfig::CONFIG["host_os"] =~ /darwin/
  require "#{VENDOR_PATH}/macosx/couchbase-lite-java-native.jar"
elsif RbConfig::CONFIG["target_cpu"] =~ /arm/
  require "#{VENDOR_PATH}/linux_arm/couchbase-lite-java-native.jar"
end

