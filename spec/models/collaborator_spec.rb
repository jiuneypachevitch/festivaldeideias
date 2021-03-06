require 'spec_helper'

describe Collaborator do

  describe "Validations/Associations" do
    subject { Collaborator.make! }
    it { should belong_to :idea }
    it { should belong_to :user }
    it { should validate_presence_of :idea_id }
    it { should validate_presence_of :user_id }
    it { should validate_uniqueness_of(:user_id).scoped_to(:idea_id) }
  end

end
