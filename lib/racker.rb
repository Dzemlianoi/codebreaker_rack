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
        intro
      when '/options'
        ask_options
      when '/confirm_options'
        init_game_options
      when '/game'
        setting_game_options
        render_game_page
      when '/hint'
        hint
      when '/guess'
        guess
      else
        Rack::Response.new('Not Found', 404)
    end
  end

  def first_play?
    true
  end

  def ask_options
    @subtemplate = 'templates/options.html.erb'
    Rack::Response.new(render('intro.html.erb'))
  end

  def hint
    @game.init_started_game_options(get_cookie)
    @game.get_hint
    set_cookie(@game.to_h)
  end

  def init_game_options
    name = @request.params['name']
    difficulty = @request.params['difficulty']
    options = @game.init_game_options(name, difficulty)
    set_cookie(options)
  end

  def win
    Rack::Response.new('Win, bro', 200)
  end

  def loose
    Rack::Response.new('Loose, bro', 200)
  end

  def render_game_page
    @subtemplate = 'templates/game.html.erb'
    Rack::Response.new(render('intro.html.erb'))
  end

  def setting_game_options
    puts 'it'
    @game.init_started_game_options(get_cookie)
  end

  def guess
    @game.init_started_game_options(get_cookie)
    @game.current_code = @request.params['code']
    return win if @game.win?
    return loose if @game.attempts_left < 0
    @game.code_operations(@request.params['code'])
    set_cookie(@game.to_h)
  end

  def intro
    @subtemplate = 'templates/non_reg_main.html.erb'
    Rack::Response.new(render('intro.html.erb'))
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def set_cookie(options)
    Rack::Response.new do |response|
      response.set_cookie('game', options.to_json)
      response.redirect('/game')
    end
  end

  def get_cookie()
    JSON.parse(@request.cookies['game'])
  end
end