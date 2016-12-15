require './lib/codebreaker_web'
use Rack::Static, :urls => ['/assets'], :root => 'public'
run CodebreakerWeb::Racker