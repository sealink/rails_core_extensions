# Methods backported from Rails 4:
# https://github.com/rails/rails/commit/13b3c77e393b8fb02588f39e6bfa10c832e251ff
module ActiveRecord4DynamicFindersBackport
  # Finds the first record matching the specified conditions. There
  # is no implied ording so if order matters, you should specify it
  # yourself.
  #
  # If no record is found, returns <tt>nil</tt>.
  #
  #   Post.find_by name: 'Spartacus', rating: 4
  #   Post.find_by "published_at < ?", 2.weeks.ago
  #
  def find_by(*args)
    where(*args).first
  end

  # Like <tt>find_by</tt>, except that if no record is found, raises
  # an <tt>ActiveRecord::RecordNotFound</tt> error.
  def find_by!(*args)
    where(*args).first!
  end
end
