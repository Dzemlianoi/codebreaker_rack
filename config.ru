require './lib/racker'
use Rack::Static, :urls => ['/assets'], :root => 'public'
run Racker