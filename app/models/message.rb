module PiOnCouch
  class Message
    def initialize database
      @database = database
    end

    def find_all
      query = @database.createAllDocumentsQuery
      rows = query.run
      documents = []
      while row = rows.next
        documents << row.document if row.document.getProperties["type"] == "message"
      end
      documents
    end

    def create text
      document = @database.createDocument
      data = {
        "message" => text,
        "channels" => ["test"],
        "type" => "message"
      }
      document.putProperties data
    end
  end
end
