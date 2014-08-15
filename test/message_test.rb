require "test_helper"
require "models/message"


module PiOnCouch
  # fake out a quick root application class to get us a database to work with
  # TODO this should be move somewhere central
  class Application
    include_package "com.couchbase.lite"
    def self.root_application; new; end

    def database
      manager = Manager.new JavaContext.new, Manager::DEFAULT_OPTIONS

      db_name = "test-database"
      return false unless Manager.isValidDatabaseName(db_name)

      manager.getDatabase(db_name)
    end
  end

  describe Message do
    subject { Message.new }

    after do
      # clean up
      Application.root_application.database.delete
    end

    it "creates a message" do
      subject.create "I am a message"
      subject.find_all.length.must_equal 1
    end
  end
end
