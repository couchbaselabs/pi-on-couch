require "test_helper"
require "models/message"
require "services/database"

module PiOnCouch

  describe Message do
    subject { Message.new }

    before do
      Database.establish_connection "test-database"
    end

    after do
      # clean up
      Database.connection("test-database").delete
    end

    it "creates a message" do
      text = "I am a message"
      subject.create text
      subject.find_all_by_date.run.to_a.length.must_equal 1
      subject.find_all_by_date.run.first.document.properties["message"].must_equal text
    end

    it "orders messages" do
      subject.create "A"
      sleep 2 # make sure the timestamp has changed since we don't care about in secound order
      subject.create "B"
      subject.find_all_by_date.run.first.document.properties["message"].must_equal "A"
      subject.find_all_by_date.run.to_a[1].document.properties["message"].must_equal "B"
    end
  end
end
