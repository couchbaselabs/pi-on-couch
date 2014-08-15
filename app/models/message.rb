module PiOnCouch
  class Message
    def find_all
      query = database.create_all_documents_query
      rows = query.run
      documents = []
      while row = rows.next
        documents << row.document if row.document.properties["type"] == "message"
      end
      documents
    end

    def create text
      document = database.create_document
      data = {
        "message" => text,
        "channels" => ["test"],
        "type" => "message"
      }
      document.put_properties data
    end

    private
    def database
      @database ||= Application.root_application.database
    end
  end
end
