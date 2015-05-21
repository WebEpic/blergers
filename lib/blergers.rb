require 'pry'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "blergers/version"
require 'blergers/init_db'
require 'blergers/importer'

module Blergers
  class Post < ActiveRecord::Base
    has_many :post_tags
    has_many :tags, through: :post_tags

    # need to sort by date_time stamp -- oldest to newest -- 10 posts.
    def self.page(n)
      # Post.page(1)  <-- should return the last 10 posts written.
      # Post.page(2)  <-- should return the next 10 posts after above.
      Post.order(date: :desc).limit(10)
    end

    def self.page(1)
      Post.order(date: :desc).limit(10)
    end

    def self.page(2)
      Post.order(date: :desc).limit(10).offset(10)
    end

  end

  class Tag < ActiveRecord::Base
    has_many :post_tags
    has_many :posts, through: :post_tags

    # Return tags rankings -- most popular | lease popular.
    # Display like last nights score_board.
    def self.top_tags
    end
  end

  class PostTag < ActiveRecord::Base
    belongs_to :post
    belongs_to :tag
  end
end

def add_post!(post)
  puts "Importing post: #{post[:title]}"

  tag_models = post[:tags].map do |t|
    Blergers::Tag.find_or_create_by(name: t)
  end
  post[:tags] = tag_models

  post_model = Blergers::Post.create(post)
  puts "New post! #{post_model}"
end

def run!
  blog_path = '/Users/brit/projects/improvedmeans'
  toy = Blergers::Importer.new(blog_path)
  toy.import
  toy.posts.each do |post|
    add_post!(post)
  end
end

binding.pry
