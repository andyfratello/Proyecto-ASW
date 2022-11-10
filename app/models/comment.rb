class Comment < ApplicationRecord
  belongs_to :micropost
  belongs_to :user
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :comments, foreign_key: :parent_id, dependent: :destroy
  has_many :comment_likes, dependent: :destroy
end