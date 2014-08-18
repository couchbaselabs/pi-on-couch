require "services/database"

module PiOnCouch
  class Message

    VIEW_NAME = "messages-view"
    DOC_TYPE = "message"

    include_package "com.couchbase.lite"

    class MessageMapper
      include Java::com.couchbase.lite.Mapper
      java_signature "void map(Map<String, Object> document, Emitter emitter)"
      def map document, emitter
        if document.get("type") == DOC_TYPE
          emitter.emit(document.get("created_at"), document)
        end
      end
    end

    def find_all_by_date
      view = database.get_view(VIEW_NAME)
      view.set_map(MessageMapper.new, nil) if view.get_map.nil?
      view.create_query
    end

    def create text
      document = database.create_document
      data = {
        "message" => text,
        "channels" => ["all"],
        "type" => DOC_TYPE,
        "created_at" =>  Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }
      document.put_properties data
    end

    private
    def database
      Database.connection
    end
  end
end
