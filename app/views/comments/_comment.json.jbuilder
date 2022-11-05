json.extract! comment, :id, :userId, :upVotes, :text, :time, :created_at, :updated_at
json.url comment_url(comment, format: :json)
