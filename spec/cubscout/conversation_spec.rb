RSpec.describe Cubscout::Conversation do
  describe ".all" do
    it "gets all conversations" do
      stub_request(:get, %r{https://api.helpscout.net/v2/conversations\?page=*}).
        to_return(status: 200, body: File.read("#{__dir__}/../support/conversations.json"))

      convos = Cubscout::Conversation.all

      expect(convos.size).to eq 6
      expect(convos.first.class).to eq Cubscout::Conversation
    end

    it "gets one page of conversations" do
      stub_request(:get, %r{https://api.helpscout.net/v2/conversations\?page=1}).
        to_return(status: 200, body: File.read("#{__dir__}/../support/conversations.json"))

      convos = Cubscout::Conversation.all(page: 1)

      expect(convos.size).to eq 2
    end

    it "gets a filtered list of conversations" do
      stub_request(:get, %r{https://api.helpscout.net/v2/conversations\?page=1&status=active&tag=red,blue}).
        to_return(status: 200, body: File.read("#{__dir__}/../support/conversations.json"))

      convos = Cubscout::Conversation.all(page: 1, status: "active", tag: "red,blue")

      expect(convos.size).to eq 2
    end
  end

  describe ".find" do
    it "gets one conversation" do
      stub_request(:get, %r{https://api.helpscout.net/v2/conversations/\d+}).
        to_return(status: 200, body: File.read("#{__dir__}/../support/conversation.json"))

      convo = Cubscout::Conversation.find(123)

      expect(convo.class).to eq Cubscout::Conversation
    end

    it "gets one conversation with threads" do
      stub_request(:get, %r{https://api.helpscout.net/v2/conversations/\d+\?embed=threads}).
        to_return(status: 200, body: File.read("#{__dir__}/../support/conversation_with_threads.json"))

      convo = Cubscout::Conversation.find(123, embed: "threads")

      expect(convo.class).to eq Cubscout::Conversation
      expect(convo.threads.size).to eq 3
    end

    it "attributes are readable as both camel case and snake case" do
      stub_request(:get, %r{https://api.helpscout.net/v2/conversations/\d+}).
        to_return(status: 200, body: File.read("#{__dir__}/../support/conversation.json"))

      convo = Cubscout::Conversation.find(123)

      expect(convo.mailboxId).to eq 121212
      expect(convo.mailbox_id).to eq 121212
    end
  end

  describe ".threads" do
    it "gets the threads by conversation id" do
      stub_request(:get, %r{https://api.helpscout.net/v2/conversations/\d+/threads}).
        to_return(status: 200, body: File.read("#{__dir__}/../support/threads.json"))

      threads = Cubscout::Conversation.threads(123)

      expect(threads.size).to eq 3
      expect(threads.first.class).to eq Cubscout::Object
    end
  end

  describe ".create_note" do
    it "requires text" do
      expect { Cubscout::Conversation.create_note(123) }.to raise_exception ArgumentError
    end

    it "creates a text note on a conversation" do
      stub_request(:post, %r{https://api.helpscout.net/v2/conversations/\d+/notes}).
        to_return(status: 201)

      expect {
        Cubscout::Conversation.create_note(123, text: "new note")
      }.not_to raise_exception
    end
  end

  describe ".update" do
    it "requires op" do
      expect { Cubscout::Conversation.update(123, path: "/status") }.to raise_exception ArgumentError
    end

    it "requires path" do
      expect { Cubscout::Conversation.update(123, op: "replace") }.to raise_exception ArgumentError
    end

    describe "operations" do
      before do
        stub_request(:patch, %r{https://api.helpscout.net/v2/conversations/\d+}).
          to_return(status: 204)
      end

      it "modifies the subject" do
        expect {
          Cubscout::Conversation.update(123, op: "replace", path: "/subject", value: "[REDACTED]")
        }.not_to raise_exception
      end

      it "modifies the customer" do
        expect {
          Cubscout::Conversation.update(123, op: "replace", path: "/primaryCustomer.id", value: 254)
        }.not_to raise_exception
      end

      it "publishes draft" do
        expect {
          Cubscout::Conversation.update(123, op: "replace", path: "/draft", value: true)
        }.not_to raise_exception
      end

      it "moves to another mailbox" do
        expect {
          Cubscout::Conversation.update(123, op: "move", path: "/mailboxId", value: 5568)
        }.not_to raise_exception
      end

      it "changes status" do
        expect {
          Cubscout::Conversation.update(123, op: "replace", path: "/status", value: "pending")
        }.not_to raise_exception
      end

      it "replace assignee" do
        expect {
          Cubscout::Conversation.update(123, op: "replace", path: "/assignTo", value: 556)
        }.not_to raise_exception
      end

      it "removes assignee" do
        expect {
          Cubscout::Conversation.update(123, op: "remove", path: "/assignTo", value: 556)
        }.not_to raise_exception
      end
    end
  end

  describe "#assignee" do
    it "returns the user assigned to the conversation with only the attributes in conversation payload" do
      user = Cubscout::Conversation.new(id: 123, assignee: {id: 55667, first: "Jules"}).assignee

      expect(user.class).to eq Cubscout::User
      expect(user.first_name).to eq "Jules"
    end

    it "returns the user assigned to the conversation by fetching helpscout" do
      stub_request(:get, %r{https://api.helpscout.net/v2/users/\d+}).
        to_return(status: 200, body: File.read("#{__dir__}/../support/user.json"))

      user = Cubscout::Conversation.new(id: 123, assignee: {id: 55667}).assignee(fetch: true)

      expect(user.class).to eq Cubscout::User
      expect(user.role).to eq "owner"
    end
  end

  describe "#threads" do
    it "gets the threads of a conversation by fetching Helpscout" do
      stub_request(:get, %r{https://api.helpscout.net/v2/conversations/\d+/threads}).
        to_return(status: 200, body: File.read("#{__dir__}/../support/threads.json"))

      threads = Cubscout::Conversation.new(id: 123).threads(fetch: true)

      expect(threads.size).to eq 3
      expect(threads.first.class).to eq Cubscout::Object
    end

    it "gets the threads of a conversation by embedding them in conversation" do
      stub_request(:get, %r{https://api.helpscout.net/v2/conversations/\d+\?embed=threads}).
        to_return(status: 200, body: File.read("#{__dir__}/../support/conversation_with_threads.json"))

      threads = Cubscout::Conversation.find(123, embed: "threads").threads

      expect(threads.size).to eq 3
      expect(threads.first.class).to eq Cubscout::Object
    end
  end

  describe "#create_note" do
    it "creates a text note on a conversation" do
      stub_request(:post, %r{https://api.helpscout.net/v2/conversations/\d+/notes}).
        to_return(status: 201)

      expect {
        Cubscout::Conversation.new(id: 123).create_note(text: "new note")
      }.not_to raise_exception
    end
  end

  describe "#update" do
    it "requires op" do
      expect { Cubscout::Conversation.new(id: 123).update(path: "/status") }.to raise_exception ArgumentError
    end

    it "requires path" do
      expect { Cubscout::Conversation.new(id: 123).update(op: "replace") }.to raise_exception ArgumentError
    end

    describe "operations" do
      before do
        stub_request(:patch, %r{https://api.helpscout.net/v2/conversations/\d+}).
          to_return(status: 204)
      end

      it "modifies the subject" do
        expect {
          Cubscout::Conversation.new(id: 123).update(op: "replace", path: "/subject", value: "[REDACTED]")
        }.not_to raise_exception
      end

      it "modifies the customer" do
        expect {
          Cubscout::Conversation.new(id: 123).update(op: "replace", path: "/primaryCustomer.id", value: 254)
        }.not_to raise_exception
      end

      it "publishes draft" do
        expect {
          Cubscout::Conversation.new(id: 123).update(op: "replace", path: "/draft", value: true)
        }.not_to raise_exception
      end

      it "moves to another mailbox" do
        expect {
          Cubscout::Conversation.new(id: 123).update(op: "move", path: "/mailboxId", value: 5568)
        }.not_to raise_exception
      end

      it "changes status" do
        expect {
          Cubscout::Conversation.new(id: 123).update(op: "replace", path: "/status", value: "pending")
        }.not_to raise_exception
      end

      it "replace assignee" do
        expect {
          Cubscout::Conversation.new(id: 123).update(op: "replace", path: "/assignTo", value: 556)
        }.not_to raise_exception
      end

      it "removes assignee" do
        expect {
          Cubscout::Conversation.new(id: 123).update(op: "remove", path: "/assignTo", value: 556)
        }.not_to raise_exception
      end
    end
  end
end
