json.extract! reply, :id, :comment_id, :user_id, :text, :created_at, :updated_at
json.url reply_url(reply, format: :json)
