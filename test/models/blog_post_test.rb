require "test_helper"

class BlogPostTest < ActiveSupport::TestCase
  # --- Validations ---

  test "is valid with title and body" do
    post = BlogPost.new(title: "Hello", body: "World")
    assert post.valid?
  end

  test "is invalid without a title" do
    post = BlogPost.new(body: "World")
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "is invalid without a body" do
    post = BlogPost.new(title: "Hello")
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  # --- Instance methods ---

  test "#draft? returns true when published_at is nil" do
    assert blog_posts(:draft).draft?
  end

  test "#draft? returns false when published_at is set" do
    assert_not blog_posts(:published).draft?
  end

  test "#published? returns true when published_at is in the past" do
    assert blog_posts(:published).published?
  end

  test "#published? returns false for a draft" do
    assert_not blog_posts(:draft).published?
  end

  test "#published? returns false for a scheduled post" do
    assert_not blog_posts(:scheduled).published?
  end

  test "#scheduled? returns true when published_at is in the future" do
    assert blog_posts(:scheduled).scheduled?
  end

  test "#scheduled? returns false for a draft" do
    assert_not blog_posts(:draft).scheduled?
  end

  test "#scheduled? returns false for a published post" do
    assert_not blog_posts(:published).scheduled?
  end

  # --- Scopes ---

  test ".draft scope returns only posts without published_at" do
    assert_includes BlogPost.draft, blog_posts(:draft)
    assert_not_includes BlogPost.draft, blog_posts(:published)
    assert_not_includes BlogPost.draft, blog_posts(:scheduled)
  end

  test ".published scope returns only posts with published_at in the past" do
    assert_includes BlogPost.published, blog_posts(:published)
    assert_not_includes BlogPost.published, blog_posts(:draft)
    assert_not_includes BlogPost.published, blog_posts(:scheduled)
  end

  test ".scheduled scope returns only posts with published_at in the future" do
    assert_includes BlogPost.scheduled, blog_posts(:scheduled)
    assert_not_includes BlogPost.scheduled, blog_posts(:draft)
    assert_not_includes BlogPost.scheduled, blog_posts(:published)
  end

  test ".sorted orders by published_at descending" do
    sorted = BlogPost.sorted.to_a
    dates = sorted.map(&:published_at).compact
    assert_equal dates, dates.sort.reverse
  end
end
