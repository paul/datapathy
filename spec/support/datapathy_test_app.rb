require 'sinatra/base'
require 'yajl'

class DatapathyTestApp < Sinatra::Base

  get '/' do
    redirect '/services'
  end

  get '/services' do
    headers "Content-Type" => "application/json"
    json({
      :href => '/services',
      :members => [
        { :name => "Services", :href => '/services' },
        { :name => "Posts",    :href => '/posts'    }
      ]
    })
  end

  get "/posts" do
    headers "Content-Type" => "application/json"
    json({
      :href => '/my_posts',
      :members => [
        {:href => '/my_posts/1', :title => 'standard resource location'}
      ]
    })
  end


  get "/my_posts" do # Test services uri override
    headers "Content-Type" => "application/json"
    json({
      :href => '/my_posts',
      :members => [
        {:href => '/my_posts/1', :title => 'Non-standard resource'}
      ]
    })
  end

  protected


  def json(obj)
    Yajl::Encoder.encode(obj, :pretty => true)
  end


  # start the server if ruby file executed directly
  run! if __FILE__ == $0
end

