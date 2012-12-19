class Collaboration < ActiveRecord::Base
  belongs_to :idea
  belongs_to :user
  belongs_to :topic, class_name: "Collaboration", foreign_key: :parent_id
  has_many :answers, class_name: "Collaboration", foreign_key: :parent_id, dependent: :destroy
  validates_presence_of :idea_id, :user_id, :description
  attr_accessible :description, :parent_id, :idea_id, :user_id
  
  scope :topics, where("parent_id IS NULL").includes(:answers)
  
  after_create :update_idea_and_collaborators
  def update_idea_and_collaborators
    self.idea.update_attribute :collaboration_count, self.idea.collaborations.count
    self.idea.collaborators.create user: self.user
  end
  
  def is_topic?
    topic.nil?
  end
  
end
