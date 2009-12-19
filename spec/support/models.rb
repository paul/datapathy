
class Article
  include Datapathy::Model

  persists :id, :title, :text, :published_at

  def summary
    text[0,30]
  end

  # used to test querying on a method
  def has_title?(title)
    self.title == title
  end

end

class Person
  include Datapathy::Model

  persists :id, :name

  validates_presence_of :name

end
