require "codebreaker_web/version"
require 'codebreaker'
require 'erb'
require 'json'


module CodebreakerWeb
  class Racker
    def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @request = Rack::Request.new(env)
    end

    def response
      @game = ::Codebreaker::Game.new
      case @request.path
        when '/'
          render_with_template('main')
        when '/options'
          render_with_template('options')
        when '/confirm_options'
          init_game_options
        when '/game'
          setting_game_options
          render_with_template('game')
        when '/hint'
          hint
        when '/guess'
          guess
        when '/win'
          return redirect unless game_started?
          render_with_template('win')
        when '/loose'
          return redirect unless game_started?
          render_with_template('loose')
        when '/restart'
          return redirect unless game_started?
          restart
        when '/save'
          return redirect unless game_started?
          save_result
        else
          Rack::Response.new('Not Found', 404)
      end
    end

    def render_with_template(subtemplate = nil, template = 'intro')
      @subtemplate = "templates/#{subtemplate}.html.erb" unless subtemplate.nil?
      Rack::Response.new(render("#{template}.html.erb"))
    end

    def init_game_options
      return redirect unless @request.params.key?('name')
      name = @request.params['name']
      difficulty = @request.params['difficulty']
      options = @game.init_game_options(name, difficulty)
      set_cookie(options)
    end

    def setting_game_options
      @game.init_started_game_options(get_cookie)
    end

    def hint
      return redirect unless game_started?
      @game.init_started_game_options(get_cookie)
      @game.get_hint
      set_cookie(@game.to_h)
    end

    def guess
      return redirect unless game_started?
      setting_game_options
      @game.current_code = @request.params['code']
      return redirect('win') if @game.win?
      return redirect('loose') if @game.loose?
      @game.code_operations(@request.params['code'])
      set_cookie(@game.to_h)
    end

    def restart
      Rack::Response.new do |response|
        response.delete_cookie('game')
        response.redirect('/')
      end
    end

    def save_result
      return redirect unless game_started?
      ::Codebreaker::Loader.save('stats', get_cookie)
      restart
    end

    private

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

    def redirect(where = '')
      Rack::Response.new do |response|
        response.redirect("/#{where}")
      end
    end

    def game_started?
      @request.cookies.key?('game')
    end
  end
end
