require 'spec_helper'

module CodebreakerWeb
  RSpec.describe Racker do
    include Rack::Test::Methods

    def session
      rack.env['rack.session']
    end

    def app
      Rack::Builder.parse_file('config.ru').first
    end

    context '#statuses_return' do
      it 'unknown URL should return 404' do
        get '/unknown'
        expect(last_response.status).to eql(404)
      end

      %w(/ /options /win /stats).each do |route|
        it "#{route} should return 200" do
          get "#{route}"
          expect(last_response.status).to eql(200)
        end
      end
    end

    context '#rendering' do
      {
          '/' => 'Hi, my young Codebreaker!',
          '/options' => 'Enter your name',
          '/win' => 'You win!',
          '/stats' => 'Game statistics',
      }.each do |k,v|
        it "#{k} should render template with #{v}" do
          get k
          expect(last_response.body).to include(v)
        end
      end
    end

    context '#/' do
      it 'should continue the game is session not empty' do
        get '/'
        expect(last_response.body).not_to include('Current game')
        expect(last_response.body).to include('Try')
      end

      it 'should continue the game is session not empty' do
        env('rack.session', {game: Codebreaker::Game.new('denis', :easy)})
        get '/'
        expect(last_response.body).to include('Current game')
        expect(last_response.body).to include('Continue')
      end
    end

    context '#confirm_settings' do
      it 'game should not be empty' do
        get '/confirm_settings?name=denis&difficulty=easy'
        expect(last_request.env['rack.session'][:game]).to be_a_kind_of(Codebreaker::Game)
      end

      it 'should redirect to / if settings empty' do
        get '/confirm_settings'
        expect(last_response.headers['Location']).to eql('/')
      end

      it 'should redirect to /game if settings not empty' do
        get '/confirm_settings?name=denis&difficulty=easy'
        expect(last_response.headers['Location']).to eql('/game')
      end
    end

    context '#restart' do
      it 'should clear the session' do
        env('rack.session', {game: Codebreaker::Game.new('denis', :easy)})
        get '/restart'
        expect(last_request.env['rack.session']).to be_empty
      end

      it 'should redirect to /' do
        get '/restart'
        expect(last_response.headers['Location']).to eql('/')
      end
    end

    context '#game' do
      it 'should render the game page' do
        env('rack.session', {game: Codebreaker::Game.new('denis', :easy)})
        get '/game'
        expect(last_response.body).to include('Code inputs')
      end
    end

    context '#hint' do
      before(:each) do
        env('rack.session', {game: Codebreaker::Game.new('denis', :easy)})
        get '/hint'
      end

      it 'should decrease the number of hints' do
        expect(last_request.env['rack.session'][:game].hints_left).to eql(2)
        expect(last_request.env['rack.session'][:game].hints_array.size).to eql(1)
      end

      it 'should redirect to game' do
        expect(last_response.headers['Location']).to eql('/game')
      end
    end

    context '#guess' do
      before(:each) do
        env('rack.session', {game: Codebreaker::Game.new('denis', :easy)})
        get '/guess'
      end

      it 'should decrease the number of attempts' do
        expect(last_request.env['rack.session'][:game].attempts_left).to eql(14)
        expect(last_request.env['rack.session'][:game].attempts_array.size).to eql(1)
      end

      it 'should redirect to game' do
        expect(last_response.headers['Location']).to eql('/game')
      end

      it 'should decrease the number of attempts' do
        14.times {|i| get '/guess'}
        expect(last_response.headers['Location']).to eql('/loose')
      end
    end
  end
end