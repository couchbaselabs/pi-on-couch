# make sure we can load couchbase lite
VENDOR_PATH ||= File.expand_path("../../../vendor", __FILE__)

# load all vendored jar dependencies
Dir["#{VENDOR_PATH}/*.jar"].each { |jar| require jar }

# load native jars for platform
if RbConfig::CONFIG["target_cpu"] =~ /x86/ && RbConfig::CONFIG["host_os"] =~ /darwin/
  require "#{VENDOR_PATH}/macosx/couchbase-lite-java-native.jar"
elsif RbConfig::CONFIG["target_cpu"] =~ /arm/
  require "#{VENDOR_PATH}/linux_arm/couchbase-lite-java-native.jar"
end

module PiOnCouch
  class Database

    class InvalidDatabaseName < StandardError
      def initialize name
        super "#{name} is an invalid database name"
      end
    end

    class << self
      include_package "com.couchbase.lite"

      def connection database_name = nil
        if database_name.nil?
          @connections.values.first
        else
          @connections[database_name]
        end
      end

      def establish_connection database_name
        unless Manager.is_valid_database_name database_name
          raise InvalidDatabaseName.new(database_name)
        end

        @connections ||= {}
        @manager ||= Manager.new JavaContext.new, Manager::DEFAULT_OPTIONS

        @connections[database_name] = @manager.get_database database_name
      end
    end
  end
end
