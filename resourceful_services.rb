
datapathy = Datapathy::Connection.new("http://api.ls.com") do |conn|
  conn.add_authenticator LivingSocial::Authenticator.new("token", AUTH_TOKEN)
end

post = datapathy.resource("/posts/1")
post = datapathy.discover("LatestPost")

posts = datapathy.collection("/posts")
posts = datapathy.discover_collection("AllPosts")

posts.members # Triggers http request
# GET /posts
#
# {
#   href: "/posts",
#   _type: "Collection",
#   version: "...",
#   members: [
#     {
#       _type: "Post",
#       href: "/posts/stuff",
#       title: "Stuff",
#       body: "Stuff is cool!",
#       author_href: "api.people.ls.com/people/paul",
#       comments_href: "/posts/stuff/comments"
#     },
#     // ..
#   ]
# }

post = posts.detect { |p| p.title == "Stuff" }

class Post
  include Datapathy::Model

  service_name "AllPosts"
  # OR
  service_uri  "http://api.ls.com/posts{?author_href,q}"

  persists :title, :body, :author_href, :comments_href

  links :author
  links :comments

end

post  = Post.detect { |p| p.author == some_author }   # GET /posts?author_href=/authors/1234
posts = Post.select { |p| p.q == "Stuff" }            # GET /posts?q=Stuff
posts = Post.select { |p| p.title == "Stuff" }        # GET /posts   (since `title` isn't a available query param, fall back to Enumerable#select)

