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
      case @request.path
        when '/'
          render_with_template('main')
        when '/options'
          @difficulties = ::Codebreaker::Loader.load('difficulties')
          render_with_template('options')
        when '/confirm_settings'
          confirm_settings
        when '/game'
          render_with_template('game')
        when '/hint'
          hint
        when '/guess'
          guess
        when '/win'
          render_with_template('win')
        when '/loose'
          render_with_template('loose')
        when '/save'
          protected_game_actions('save_result')
        when '/restart'
          restart
        else
          Rack::Response.new('Not Found', 404)
      end
    end

    def confirm_settings
      return redirect unless @request.params.key?('name')
      name = @request.params['name']
      difficulty = @request.params['difficulty']
      @request.session[:game] = ::Codebreaker::Game.new(name,difficulty)
      redirect('game')
    end

    def hint
      game.get_hint
      redirect('game')
    end

    def guess
      return redirect('win') if game.win?(@request.params['code'])
      game.code_operations @request.params['code']
      return redirect('loose')  if game.loose?
      redirect('game')
    end

    def save_result
      ::Codebreaker::Loader.save('stats', game.to_h)
      restart
    end

    private

    def game
      @request.session[:game]
    end

    def render(template)
      path = File.expand_path("../views/#{template}", __FILE__)
      ERB.new(File.read(path)).result(binding)
    end

    def render_with_template (subtemplate = nil, template = 'intro')
      @subtemplate = "templates/#{subtemplate}.html.erb" unless subtemplate.nil?
      Rack::Response.new(render("#{template}.html.erb"))
    end

    def restart
      @request.session.clear
      redirect
    end

    def redirect(where = '')
      Rack::Response.new do |response|
        response.redirect("/#{where}")
      end
    end

    def game_started?
      @request.session.key?(:game)
    end
  end
end
