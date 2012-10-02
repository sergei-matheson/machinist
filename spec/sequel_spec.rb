require File.dirname(__FILE__) + '/spec_helper'
require 'support/sequel_environment'

describe Machinist::Sequel do
  include SequelEnvironment

  before(:each) do
    empty_database!
  end

  context "make" do
    it "returns an unsaved object" do
      SequelEnvironment::Post.blueprint { }
      post = SequelEnvironment::Post.make
      post.should be_a(SequelEnvironment::Post)
      post.should be_new
    end
  end

  context "make!" do
    it "makes and saves objects" do
      SequelEnvironment::Post.blueprint { }
      post = SequelEnvironment::Post.make!
      post.should be_a(SequelEnvironment::Post)
      post.should_not be_new
    end

    it "raises an exception for an invalid object" do
      SequelEnvironment::User.blueprint { }
      lambda {
        SequelEnvironment::User.make!(:username => "")
      }.should raise_error(Sequel::ValidationFailed)
    end
  end

  context "associations support" do
    it "handles many_to_one associations" do
      SequelEnvironment::User.blueprint do
        username { "user_#{sn}" }
      end
      SequelEnvironment::Post.blueprint do
        author
      end
      post = SequelEnvironment::Post.make!
      post.should be_a(SequelEnvironment::Post)
      post.should_not be_new
      post.author.should be_a(SequelEnvironment::User)
      post.author.should_not be_new
    end

    it "handles one_to_many associations" do
      SequelEnvironment::Post.blueprint do
        comments(3)
      end
      SequelEnvironment::Comment.blueprint { }
      post = SequelEnvironment::Post.make!
      post.should be_a(SequelEnvironment::Post)
      post.should_not be_new
      post.should have(3).comments
      post.comments.each do |comment|
        comment.should be_a(SequelEnvironment::Comment)
        comment.should_not be_new
      end
    end

    it "handles many_to_many associations" do
      SequelEnvironment::Post.blueprint do
        tags(3)
      end
      SequelEnvironment::Tag.blueprint do
        name { "tag_#{sn}" }
      end
      post = SequelEnvironment::Post.make!
      post.should be_a(SequelEnvironment::Post)
      post.should_not be_new
      post.should have(3).tags
      post.tags.each do |tag|
        tag.should be_a(SequelEnvironment::Tag)
        tag.should_not be_new
      end
    end

    it "handles overriding associations" do
      SequelEnvironment::User.blueprint do
        username { "user_#{sn}" }
      end
      SequelEnvironment::Post.blueprint do
        author { SequelEnvironment::User.make(:username => "post_author_#{sn}") }
      end
      post = SequelEnvironment::Post.make!
      post.should be_a(SequelEnvironment::Post)
      post.should_not be_new
      post.author.should be_a(SequelEnvironment::User)
      post.author.should_not be_new
      post.author.username.should =~ /^post_author_\d+$/
    end
  end

  context "error handling" do
    it "raises an exception for an attribute with no value" do
      SequelEnvironment::User.blueprint { username }
      lambda {
        SequelEnvironment::User.make
      }.should raise_error(ArgumentError)
    end
  end

end
