require 'sinatra/base'
require 'yajl'

class DatapathyTestApp < Sinatra::Base

  get '/' do
    redirect '/services'
  end

  get '/services' do
    headers "Content-Type" => "application/json"
    json({
      :type => 'Service',
      :href => '/services',
      :items => [
        { :name => "Services", :href => '/services' },
        { :name => "Posts",    :href => '/posts'    }
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

