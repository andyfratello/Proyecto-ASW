class Comment < ApplicationRecord
  belongs_to :micropost
  belongs_to :user
  has_many :comment_likes
end
