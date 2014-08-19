require "java"

require "services/database"
require "controllers/messages_controller"

module PiOnCouch
  class Application
    include_package "com.couchbase.lite.replicator"

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

      replication_listener = Replication::ChangeListener.new
      class << replication_listener
        java_signature 'void changed(ChangeEvent event)'
        def changed event
          replication = event.source
          if replication.last_error
            $log.warn "replication encountered an error: #{replication.last_error}"
          else
            $log.debug "#{replication.getCompletedChangesCount} of #{replication.changes_count} changes replicated"
          end
        end
      end

      pull_rep.add_change_listener replication_listener
      pull_rep.start

      push_rep = database.create_push_replication(url)
      push_rep.continuous = true

      push_rep.add_change_listener replication_listener
      push_rep.start
    end
  end
end
