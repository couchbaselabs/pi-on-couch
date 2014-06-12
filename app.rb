require "java"
require "logger"

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

# load all vendored jar dependencies
Dir["vendor/*.jar"].each { |jar| require jar }

# load native jars for platform
if RbConfig::CONFIG["target_cpu"] =~ /x86/ && RbConfig::CONFIG["host_os"] =~ /darwin/
  require "vendor/macosx/couchbase-lite-java-native.jar"
elsif RbConfig::CONFIG["target_cpu"] =~ /arm/
  require "vendor/linux_arm/couchbase-lite-java-native.jar"
end

SYNC_URL = "http://sync.couchbasecloud.com/pi-on-couch"

$log = Logger.new(STDOUT)
$log.level = Logger::DEBUG
$ui = false # hold window ref to update

class PiOnCouch
  include_package "com.couchbase.lite"

  class Message
    def self.find_all database
      query = database.createAllDocumentsQuery
      rows = query.run
      documents = []
      while row = rows.next
        documents << row.document if row.document.getProperties["type"] == "message"
      end
      documents
    end
  end

  class ChangeListenerImpl
    include Java::com.couchbase.lite.replicator.Replication::ChangeListener
    java_signature 'void changed(ChangeEvent event)'
    def changed event
      def changed event
        replication = event.getSource();
        if replication.getLastError
          $log.warn "replication encountered an error: #{replication.getLastError}"
        else
          $log.debug "#{replication.getCompletedChangesCount} of #{replication.getChangesCount} changes replicated"
          $ui.reload_data if $ui
        end
      end
    end
  end

  def change_listener; ChangeListenerImpl.new; end

  class UI < JFrame
    def initialize database
      super "PiOnCouch"

      @database = database

      UIManager.setLookAndFeel UIManager.getSystemLookAndFeelClassName

      panel = JPanel.new
      panel_layout = BoxLayout.new panel, BoxLayout::Y_AXIS
      panel.setLayout panel_layout
      panel.setOpaque true

      input_panel = JPanel.new
      input_panel.setLayout FlowLayout.new

      setSize 800, 600
      setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
      setLocationRelativeTo nil

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
      getContentPane.add BorderLayout::NORTH, scroll_pane
      getContentPane.add BorderLayout::CENTER, panel

      setLocationByPlatform true
      input_field.requestFocus
      setLocationRelativeTo nil
      setVisible true
      reload_data

      send_btn.addActionListener do |e|
        message_text = input_field.getText()
        document = @database.createDocument
        data = {
          "message" => message_text,
          "channels" => ["test"],
          "type" => "message"
        }
        document.putProperties data
        $log.debug "creating new message: #{message_text}"
      end
    end

    def reload_data
      documents = Message.find_all @database
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

  def setup_ui
    $ui = UI.new database
  end

  # Debug!!!
  def dump_all
    Message.find_all(database).map(&:getProperties)
  end

  def initialize
    ctx = JavaContext.new
    @manager = Manager.new ctx, Manager::DEFAULT_OPTIONS
  end

  def database
    return @database if @database

    db_name = "pi-on-couch"
    return false unless Manager.isValidDatabaseName(db_name)

    @database = @manager.getDatabase(db_name)
  end

  def setup_sync
    sync_url = java.net.URL.new(java.lang.String.new(SYNC_URL.to_java_bytes).java_object)

    @pullRep = database.createPullReplication(sync_url.java_object)
    @pullRep.setContinuous(true)
    @pullRep.addChangeListener(change_listener)
    @pullRep.start

    @pushRep = database.createPushReplication(sync_url.java_object)
    @pushRep.setContinuous(true)
    @pushRep.addChangeListener(change_listener)
    @pushRep.start
  end

  def self.run
    this = new
    this.setup_sync
    this.setup_ui
    this
  end
end

PiOnCouch.run

