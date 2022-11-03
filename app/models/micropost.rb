class Micropost < ApplicationRecord
  acts_as_votable
  belongs_to :user
  validates :title, presence: true
  validate :isThereAnyUrlOrText

  def isThereAnyUrlOrText
    if (url.blank? and text.blank?)
      errors[:base] << "A text or a url needs to be provided"
    elsif not (url.blank? ^text.blank?)
      errors[:base] << "A text or a url needs to be provided, not both"
    end

  end
end
