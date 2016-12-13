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
    @game = Codebreaker::Game.new
    case @request.path
      when '/'
        intro if first_play?
      when '/options'
        return set_options unless @request.params['name'].nil?
        @subtemplate = 'templates/options.html.erb'
        Rack::Response.new(render('intro.html.erb'))
      when '/game'
        Rack::Response.new(@request.cookies['game'])
      else
        Rack::Response.new('Not Found', 404)
    end
  end

  def set_options
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

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end