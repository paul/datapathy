
class Article
  include Datapathy::Model

  persists :id, :title, :text

  def summary
    text[0,30]
  end

end

