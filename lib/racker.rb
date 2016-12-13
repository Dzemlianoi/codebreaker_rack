require 'erb'
require 'yaml'
require 'json'
require_relative 'loader'
require_relative 'game'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case @request.path
      when '/'
        intro if first_play?
      when '/options'
        @game = Codebreaker::Game.new
        @subtemplate = 'templates/options.html.erb'
        Rack::Response.new(render('intro.html.erb'))
      when '/game'
        return Rack::response.new{|redirect| redirect.redirect('/options')} if @request.params['name'].nil?
        @subtemplate = 'templates/game.html.erb'
        Rack::Response.new(render('intro.html.erb'))
      else
        Rack::Response.new('Not Found', 404)
    end
  end

  def game_options
    name = @request.params['name']
    difficulty = @request.params['difficulty']
    options = @game.asign_game_options(name, difficulty)
    Rack::Response.new do |response|
      response.set_cookie('game', options.to_json)
      response.redirect('/game')
    end
  end

  def intro
    @subtemplate = 'templates/non_reg_main.html.erb'
    Rack::Response.new(render('intro.html.erb'))
  end

  def first_play?
    true
  end

  def asign_options
    @options = JSON.parse(@request['params'])
    @game.asign_start_game_options
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end