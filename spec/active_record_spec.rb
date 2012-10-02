require File.dirname(__FILE__) + '/spec_helper'
require 'support/active_record_environment'

describe Machinist::ActiveRecord do
  include ActiveRecordEnvironment

  before(:each) do
    empty_database!
  end

  context "make" do
    it "returns an unsaved object" do
      ActiveRecordEnvironment::Post.blueprint { }
      post = ActiveRecordEnvironment::Post.make
      post.should be_a(ActiveRecordEnvironment::Post)
      post.should be_new_record
    end
  end

  context "make!" do
    it "makes and saves objects" do
      ActiveRecordEnvironment::Post.blueprint { }
      post = ActiveRecordEnvironment::Post.make!
      post.should be_a(ActiveRecordEnvironment::Post)
      post.should_not be_new_record
    end

    it "raises an exception for an invalid object" do
      ActiveRecordEnvironment::User.blueprint { }
      lambda {
        ActiveRecordEnvironment::User.make!(:username => "")
      }.should raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "associations support" do
    it "handles belongs_to associations" do
      ActiveRecordEnvironment::User.blueprint do
        username { "user_#{sn}" }
      end
      ActiveRecordEnvironment::Post.blueprint do
        author
      end
      post = ActiveRecordEnvironment::Post.make!
      post.should be_a(ActiveRecordEnvironment::Post)
      post.should_not be_new_record
      post.author.should be_a(ActiveRecordEnvironment::User)
      post.author.should_not be_new_record
    end

    it "handles has_many associations" do
      ActiveRecordEnvironment::Post.blueprint do
        comments(3)
      end
      ActiveRecordEnvironment::Comment.blueprint { }
      post = ActiveRecordEnvironment::Post.make!
      post.should be_a(ActiveRecordEnvironment::Post)
      post.should_not be_new_record
      post.should have(3).comments
      post.comments.each do |comment|
        comment.should be_a(ActiveRecordEnvironment::Comment)
        comment.should_not be_new_record
      end
    end

    it "handles habtm associations" do
      ActiveRecordEnvironment::Post.blueprint do
        tags(3)
      end
      ActiveRecordEnvironment::Tag.blueprint do
        name { "tag_#{sn}" }
      end
      post = ActiveRecordEnvironment::Post.make!
      post.should be_a(ActiveRecordEnvironment::Post)
      post.should_not be_new_record
      post.should have(3).tags
      post.tags.each do |tag|
        tag.should be_a(ActiveRecordEnvironment::Tag)
        tag.should_not be_new_record
      end
    end

    it "handles overriding associations" do
      ActiveRecordEnvironment::User.blueprint do
        username { "user_#{sn}" }
      end
      ActiveRecordEnvironment::Post.blueprint do
        author { ActiveRecordEnvironment::User.make(:username => "post_author_#{sn}") }
      end
      post = ActiveRecordEnvironment::Post.make!
      post.should be_a(ActiveRecordEnvironment::Post)
      post.should_not be_new_record
      post.author.should be_a(ActiveRecordEnvironment::User)
      post.author.should_not be_new_record
      post.author.username.should =~ /^post_author_\d+$/
    end
  end

  context "error handling" do
    it "raises an exception for an attribute with no value" do
      ActiveRecordEnvironment::User.blueprint { username }
      lambda {
        ActiveRecordEnvironment::User.make
      }.should raise_error(ArgumentError)
    end
  end

end
