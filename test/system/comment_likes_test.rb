require "application_system_test_case"

class CommentLikesTest < ApplicationSystemTestCase
  setup do
    @comment_like = comment_likes(:one)
  end

  test "visiting the index" do
    visit comment_likes_url
    assert_selector "h1", text: "Comment likes"
  end

  test "should create comment like" do
    visit comment_likes_url
    click_on "New comment like"

    fill_in "Comment", with: @comment_like.comment_id
    fill_in "User", with: @comment_like.user_id
    click_on "Create Comment like"

    assert_text "Comment like was successfully created"
    click_on "Back"
  end

  test "should update Comment like" do
    visit comment_like_url(@comment_like)
    click_on "Edit this comment like", match: :first

    fill_in "Comment", with: @comment_like.comment_id
    fill_in "User", with: @comment_like.user_id
    click_on "Update Comment like"

    assert_text "Comment like was successfully updated"
    click_on "Back"
  end

  test "should destroy Comment like" do
    visit comment_like_url(@comment_like)
    click_on "Destroy this comment like", match: :first

    assert_text "Comment like was successfully destroyed"
  end
end
