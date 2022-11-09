class Comment < ApplicationRecord
  belongs_to :micropost
  belongs_to :user
  has_many :comment_likes, dependent: :destroy
  has_many :replies, dependent: :destroy
end