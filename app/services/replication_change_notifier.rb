module PiOnCouch
  class ReplicationChangeNotifier
    def initialize
      @replication_success_listeners = []
    end

    include Java::com.couchbase.lite.replicator.Replication::ChangeListener
    java_signature 'void changed(ChangeEvent event)'
    def changed event
      replication = event.getSource
      if replication.getLastError
        $log.warn "replication encountered an error: #{replication.getLastError}"
      else
        $log.debug "#{replication.getCompletedChangesCount} of #{replication.getChangesCount} changes replicated"
        @replication_success_listeners.each { |l| l.replication_success }
      end
    end

    def register_replication_success_listener listener
      @replication_success_listeners << listener
    end
  end
end
