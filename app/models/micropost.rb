class Micropost < ApplicationRecord
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
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
