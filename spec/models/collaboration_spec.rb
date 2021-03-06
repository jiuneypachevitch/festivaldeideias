require 'spec_helper'

describe Collaboration do

  describe "Validations/Associations" do
    it { should belong_to :idea }
    it { should belong_to :user }
    it { should belong_to :topic }
    it { should have_many(:answers).dependent(:destroy) }
    it { should validate_presence_of :idea_id }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :description }
  end

end
