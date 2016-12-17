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
        when '/'  then render_with_template('main')
        when '/options'
          @difficulties = ::Codebreaker::Loader.load('difficulties')
          render_with_template('options')
        when '/confirm_settings' then confirm_settings
        when '/game' then render_with_template('game')
        when '/hint'  then hint
        when '/guess' then guess
        when '/win'  then render_with_template('win')
        when '/loose' then render_with_template('loose')
        when '/save'  then save_result
        when '/stats' then stats
        when '/restart' then restart
        else Rack::Response.new('Not Found', 404)
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
      @stats = ::Codebreaker::Loader.load('stats')
      @stats.push(game.to_h)
      ::Codebreaker::Loader.save('stats', @stats)
      restart
    end

    def stats
      @stats = ::Codebreaker::Loader.load('stats')
      return render_with_template('no_stats') if @stats.empty?
      render_with_template('stats')
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
