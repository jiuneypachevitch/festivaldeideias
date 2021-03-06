# coding: utf-8

require 'spec_helper'

describe Audit do

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper
  
  describe "Validations/Associations" do
    it { should belong_to :user }
    it { should belong_to :idea }
    it { should belong_to :actual_user }
  end
  
  describe ".audited_changes" do
    # Testing that it is serialized
    subject { Audit.make!(audited_changes: {likes: [51, 52]}) }
    its(:audited_changes) { should == {likes: [51, 52]} }
  end

  describe ".notification_texts" do
    # Testing that it is serialized
    subject { Audit.make!(notification_texts: {collaborators: "collaborators", creator: "creator"}) }
    its(:notification_texts) { should == {collaborators: "collaborators", creator: "creator"} }
  end

  # IMPORTANT NOTICE for developers: this method is called by migration StoreAuditsTimelineData.
  # If you remove it or change its behaviour, please edit the migration as well
  describe ".set_timeline_and_notifications_data!" do
    subject do
      @audit = Audit.make!(audited_changes: {likes: [51, 52]}, timeline_type: nil, actual_user: nil, text: nil, notification_texts: nil)
      @audit.set_timeline_and_notifications_data!
      @audit
    end
    its(:text) { should == @audit.generated_texts[0] }
    its(:notification_texts) { should == @audit.generated_texts[1] }
    its(:timeline_type) { should == @audit.generated_timeline_type }
    its(:actual_user_id) { should == @audit.generated_actual_user_id }
    
    it "should display text when an idea was created" do
      audit = Audit.make!(action: "create", audited_changes: { "description" => "new", "accepted" => nil, "parent_id" => nil })
      audit.set_timeline_and_notifications_data!
      timeline_text = I18n.t("audit.create", user: audit.user.name, user_path: user_path(audit.user), idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea))
      notification_texts = nil
      audit.timeline_type.should == "idea_created"
      audit.text.should == timeline_text
      audit.notification_texts.should == notification_texts
    end
        
    it "should display text when an idea was edited by its creator" do
      audit = Audit.make!(action: "update", audited_changes: { "description" => ["old", "new"] })
      audit.set_timeline_and_notifications_data!
      timeline_text = I18n.t("audit.edit", user: audit.user.name, user_path: user_path(audit.user), idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea))
      notification_texts = {
        collaborators: I18n.t("audit.notification.edit.collaborators", user: audit.user.name, user_path: user_path(audit.user), idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea))
      }
      audit.timeline_type.should == "edited_by_creator"
      audit.text.should == timeline_text
      audit.notification_texts.should == notification_texts
    end
    
    it "should display text when a collaboration is created" do
      @idea = Idea.make!
      Collaboration.make!(idea: @idea)
      audit = Audit.make!(idea: @idea, action: "update", audited_changes: { "collaboration_count" => [10, 20] })
      audit.set_timeline_and_notifications_data!
      timeline_text = I18n.t("audit.collaboration_created", user: audit.idea.collaborations.last.user.name, user_path: user_path(audit.idea.collaborations.last.user), idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea))
      notification_texts = {
        creator: I18n.t("audit.notification.collaboration_created.creator", user: audit.idea.collaborations.last.user.name, user_path: user_path(audit.idea.collaborations.last.user), idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea)),
        collaborators: I18n.t("audit.notification.collaboration_created.collaborators", user: audit.idea.collaborations.last.user.name, user_path: user_path(audit.idea.collaborations.last.user), idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea))
      }
      audit.timeline_type.should == "collaboration_created"
      audit.text.should == timeline_text
      audit.notification_texts.should == notification_texts
    end
    
    it "should display text when an idea's likes count was updated" do
      audit = Audit.make!(action: "update", audited_changes: { "likes" => [10, 20] })
      audit.set_timeline_and_notifications_data!
      timeline_text = I18n.t("audit.likes", idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea), likes: pluralize(20, "pessoa"))
      notification_texts = {
        creator: I18n.t("audit.notification.likes.creator", idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea), likes: pluralize(20, "pessoa")),
        collaborators: I18n.t("audit.notification.likes.collaborators", idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea), likes: pluralize(20, "pessoa"))
      }
      audit.timeline_type.should == "likes_updated"
      audit.text.should == timeline_text
      audit.notification_texts.should == notification_texts
    end
    
    it "should display text when an idea's comment count was updated" do
      audit = Audit.make!(action: "update", audited_changes: { "comment_count" => [10, 20] })
      audit.set_timeline_and_notifications_data!
      timeline_text = I18n.t("audit.comments", idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea), comments: pluralize(20, "comentário"))
      notification_texts = {
        creator: I18n.t("audit.notification.comments.creator", idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea), comments: pluralize(20, "comentário")),
        collaborators: I18n.t("audit.notification.comments.collaborators", idea: audit.idea.title, idea_path: category_idea_path(audit.idea.category, audit.idea), comments: pluralize(20, "comentário"))
      }
      audit.timeline_type.should == "comments_updated"
      audit.text.should == timeline_text
      audit.notification_texts.should == notification_texts
    end
    
    it "should return ignore if the idea was destroyed" do
      audit = Audit.make!(action: "destroy")
      audit.set_timeline_and_notifications_data!
      audit.timeline_type.should == "ignore"
      audit.text.should == nil
      audit.notification_texts.should == nil
    end
    
    it "should return ignore if its idea does not exist anymore" do
      idea = Idea.make!
      audit = Audit.make!(idea: idea, action: "update", audited_changes: { "description" => ["old", "new"] })
      idea.destroy
      audit.reload
      audit.set_timeline_and_notifications_data!
      audit.timeline_type.should == "ignore"
      audit.text.should == nil
      audit.notification_texts.should == nil
    end
    
    it "should return ignore if the comment_count changed to zero" do
      audit = Audit.make!(action: "update", audited_changes: { "comment_count" => [10, 0] })
      audit.set_timeline_and_notifications_data!
      audit.timeline_type.should == "ignore"
      audit.text.should == nil
      audit.notification_texts.should == nil
    end

  end
  
  describe ".generated_actual_user" do
    describe "with audit's user" do
      subject do
        @user = User.make!
        @idea = Idea.make!
        Audit.make!(user: @user, idea: @idea)
      end
      its(:generated_actual_user_id) { should == @user.id }
    end
    describe "with ideas's user" do
      subject do
        @idea = Idea.make!
        Audit.make!(user: nil, idea: @idea)
      end
      its(:generated_actual_user_id) { should == @idea.user.id }
    end
    describe "with ideas's last collaboration user" do
      subject do
        @user = User.make!
        @idea = Idea.make!
        Collaboration.make!(idea: @idea)
        @collaboration = Collaboration.make!(idea: @idea)
        Audit.make!(user: @user, idea: @idea, timeline_type: "collaboration_created")
      end
      its(:generated_actual_user_id) { should == @collaboration.user.id }
    end
    ["likes_updated", "comments_updated"].each do |timeline_type|
      describe "with ideas's user, even when we have an user, for #{timeline_type}" do
        subject do
          @user = User.make!
          @idea = Idea.make!
          Audit.make!(user: @user, idea: @idea, timeline_type: timeline_type)
        end
        its(:generated_actual_user_id) { should == @idea.user.id }
      end
    end
  end
  
  describe ".users_to_notify" do
    before do
      @lonely_idea = Idea.make!
      @idea = Idea.make!
      @collaboration_1 = Collaboration.make!(idea: @idea)
      @collaboration_2 = Collaboration.make!(idea: @idea)
    end
    describe "activity in an idea with no collaborators" do
      subject { Audit.make!(idea: @lonely_idea) }
      its(:users_to_notify) { should == [@lonely_idea.user] }
    end
    describe "activity in an idea with collaborators" do
      subject { Audit.make!(idea: @idea) }
      its(:users_to_notify) { should == [@idea.user, @collaboration_1.user, @collaboration_2.user] }
    end
  end
  
  describe ".notification_subject" do
    describe "idea created" do
      subject { @audit = Audit.make!(timeline_type: "idea_created") }
      its(:notification_subject) { should == "Tem ideia nova no FdI" }
    end
    describe "edited by creator" do
      subject { @audit = Audit.make!(timeline_type: "edited_by_creator") }
      its(:notification_subject) { should == "Tem novidades na ideia #{@audit.idea.title}" }
    end
    describe "likes updated" do
      subject { @audit = Audit.make!(timeline_type: "likes_updated") }
      its(:notification_subject) { should == "Tem gente curtindo a ideia #{@audit.idea.title}" }
    end
    describe "comments updated" do
      subject { @audit = Audit.make!(timeline_type: "comments_updated") }
      its(:notification_subject) { should == "Novos comentários na ideia #{@audit.idea.title}" }
    end
    describe "collaboration created" do
      subject do
        @idea = Idea.make!
        @audit = Audit.make!(idea: @idea, timeline_type: "collaboration_created")
      end
      its(:notification_subject) { should == "Colaboração enviada para a ideia #{@audit.idea.title}" }
    end
  end

end
