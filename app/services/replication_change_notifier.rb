module PiOnCouch
  class ReplicationChangeNotifier
    def initialize
      @replication_success_listeners = []
    end

    include Java::com.couchbase.lite.replicator.Replication::ChangeListener
    java_signature 'void changed(ChangeEvent event)'
    def changed event
      replication = event.source
      if replication.last_error
        $log.warn "replication encountered an error: #{replication.last_error}"
      else
        $log.debug "#{replication.getCompletedChangesCount} of #{replication.changes_count} changes replicated"
        @replication_success_listeners.each { |listener| listener.replication_success }
      end
    end

    def add_replication_success_listener listener
      @replication_success_listeners << listener
    end
  end
end
