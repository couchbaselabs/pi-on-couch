java_import java.awt.FlowLayout
java_import java.awt.BorderLayout
java_import javax.swing.JFrame
java_import javax.swing.JTable
java_import javax.swing.JButton
java_import javax.swing.JPanel
java_import javax.swing.JTextField
java_import javax.swing.JTextArea
java_import javax.swing.JOptionPane
java_import javax.swing.UIManager
java_import javax.swing.BoxLayout
java_import javax.swing.JScrollPane
java_import javax.swing.Box

require_relative "../models/message"

module PiOnCouch
  class MessagesController < JFrame
    # callback for listening to replication successes
    def replication_success
      reload_data
    end

    def initialize
      super "PiOnCouch"

      @message = Message.new(Application.root_application.database)

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
        message_text = input_field.getText()
        @message.create message_text
        $log.debug "creating new message: #{message_text}"
      end
    end

    def reload_data
      documents = @message.find_all
      model = @table.getModel
      documents.each do |doc|
        if !@data_present.include?(doc.getProperties["_id"])
          @data_present << doc.getProperties["_id"]
          message = doc.getProperties["message"]
          if message
            model.insertRow 0, [java.lang.String.new(message.to_java_bytes)].to_java(:String)
          end
        end
      end
    end
  end
end
