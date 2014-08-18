require "java"

require "services/database"
require "controllers/messages_controller"
require "services/replication_change_notifier"

module PiOnCouch
  class Application
    def initialize sync_url
      Database.establish_connection "messages"

      @messages_controller = MessagesController.new

      setup_sync sync_url
    end

    def setup_sync sync_url
      database = Database.connection
      url = java.net.URL.new(sync_url)

      pull_rep = database.create_pull_replication(url)
      pull_rep.continuous = true

      pull_listener = ReplicationChangeNotifier.new
      pull_rep.add_change_listener pull_listener
      pull_rep.start

      push_rep = database.create_push_replication(url)
      push_rep.continuous = true

      push_listener = ReplicationChangeNotifier.new
      push_rep.add_change_listener push_listener
      push_rep.start
    end
  end
end
