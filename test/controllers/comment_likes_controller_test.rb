require "test_helper"

class CommentLikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @comment_like = comment_likes(:one)
  end

  test "should get index" do
    get comment_likes_url
    assert_response :success
  end

  test "should get new" do
    get new_comment_like_url
    assert_response :success
  end

  test "should create comment_like" do
    assert_difference("CommentLike.count") do
      post comment_likes_url, params: { comment_like: { comment_id: @comment_like.comment_id, user_id: @comment_like.user_id } }
    end

    assert_redirected_to comment_like_url(CommentLike.last)
  end

  test "should show comment_like" do
    get comment_like_url(@comment_like)
    assert_response :success
  end

  test "should get edit" do
    get edit_comment_like_url(@comment_like)
    assert_response :success
  end

  test "should update comment_like" do
    patch comment_like_url(@comment_like), params: { comment_like: { comment_id: @comment_like.comment_id, user_id: @comment_like.user_id } }
    assert_redirected_to comment_like_url(@comment_like)
  end

  test "should destroy comment_like" do
    assert_difference("CommentLike.count", -1) do
      delete comment_like_url(@comment_like)
    end

    assert_redirected_to comment_likes_url
  end
end
