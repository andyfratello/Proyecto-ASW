class Like < ApplicationRecord
  belongs_to :micropost
  belongs_to :user
  has_many :comment_likes, dependent: :destroy
end
