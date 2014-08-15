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

require "controllers/messages_controller"
require "services/replication_change_notifier"

module PiOnCouch
  class Application
    include_package "com.couchbase.lite"

    class << self
      attr_accessor :root_application
    end

    def initialize sync_url
      sync_url_string = java.lang.String.new(sync_url.to_java_bytes).java_object
      sync_url = java.net.URL.new(sync_url_string).java_object

      # store reference to root application
      Application.root_application = self

      @messages_controller = MessagesController.new

      setup_sync sync_url
    end

    def manager
      @manager ||= Manager.new JavaContext.new, Manager::DEFAULT_OPTIONS
    end

    def database
      return @database if @database

      db_name = "pi-on-couch"
      return false unless Manager.isValidDatabaseName(db_name)

      @database = manager.getDatabase(db_name)
    end

    def setup_sync sync_url
      pullRep = database.create_pull_replication(sync_url)
      pullRep.continuous = true

      pull_listener = ReplicationChangeNotifier.new
      pull_listener.add_replication_success_listener @messages_controller

      pullRep.add_change_listener pull_listener
      pullRep.start

      pushRep = database.create_push_replication(sync_url)
      pushRep.continuous = true

      push_listener = ReplicationChangeNotifier.new
      pushRep.add_change_listener push_listener
      pushRep.start
    end
  end
end
