require "spec_helper"

describe NotificationsMailer do
  describe "first" do
    let(:mail) { NotificationsMailer.first } #This needs a factory
    # let(:email) { MessageMailer.first(FactoryGirl::build(:debt))}
    
    it 'fails if user or debtor is missing' do
      pending
    end

    it "renders the headers" do
      mail.subject.should eq("First")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "second" do
    let(:mail) { NotificationsMailer.second }

    it "renders the headers" do
      mail.subject.should eq("Second")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "third" do
    let(:mail) { NotificationsMailer.third }

    it "renders the headers" do
      mail.subject.should eq("Third")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
