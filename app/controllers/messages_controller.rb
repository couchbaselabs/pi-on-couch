require "models/message"

module PiOnCouch

  class MessagesController < javax.swing.JFrame
    include_package "java.awt"
    include_package "javax.swing"

    # callback for listening to replication successes
    def replication_success
      reload_data
    end

    def initialize
      super "PiOnCouch"

      @message = Message.new

      UIManager.look_and_feel = UIManager.system_look_and_feel_class_name

      panel = JPanel.new
      panel.layout = BoxLayout.new(panel, BoxLayout::Y_AXIS)
      panel.opaque = true

      input_panel = JPanel.new
      input_panel.layout = FlowLayout.new

      self.setSize 400, 500
      self.default_close_operation = JFrame::EXIT_ON_CLOSE
      self.location_relative_to = nil

      send_btn = JButton.new "Send"
      input_field = JTextField.new 20

      column_names = java.util.Vector.new ["Messages"]
      @data = java.util.Vector.new
      @table = JTable.new @data, column_names
      @data_present = []

      input_panel.add input_field
      input_panel.add send_btn
      panel.add input_panel
      scroll_pane = JScrollPane.new(@table)
      content_pane.add BorderLayout::NORTH, scroll_pane
      content_pane.add BorderLayout::CENTER, panel

      self.location_by_platform = true
      input_field.requestFocus
      self.visible = true
      self.resizable = false
      reload_data

      send_btn.add_action_listener do |e|
        @message.create input_field.text
        $log.debug "creating new message: #{input_field.text}"
      end
    end

    def reload_data
      documents = @message.find_all
      model = @table.getModel
      documents.each do |doc|
        if !@data_present.include?(doc.getProperties["_id"])
          @data_present << doc.properties["_id"]
          message = doc.properties["message"]
          if message
            model.insertRow 0, [java.lang.String.new(message.to_java_bytes)].to_java(:String)
          end
        end
      end
    end
  end
end
