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

    context '#/' do
      it 'should render main template' do
        get '/'
        expect(last_response.body).to include('Hi, my young Codebreaker!')
      end
    end

    context '#/options' do
      before do
        get '/options'
      end

      it 'expected to receive render_with_template' do
        expect_any_instance_of(Racker).to receive(:render_with_template).with('main')
      end

      it 'difficulties should not be empty' do

      end

      it 'should render options template' do
        expect(last_response.body).to include('Enter your name')
      end
    end
  end
end