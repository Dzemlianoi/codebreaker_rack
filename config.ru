require './lib/codebreaker_web'
use Rack::Reloader
use Rack::Static, :urls => ['/assets'], :root => 'public'
use Rack::Session::Cookie, :key => 'rack.session',
    :secret => '123456'
run CodebreakerWeb::Racker
