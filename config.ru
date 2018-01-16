$LOAD_PATH.push 'lib'

require 'rack/contrib'
require 'disque/web/api'

use Rack::TryStatic, \
  root: File.expand_path('../public', __FILE__),
  urls: ['/'],
  try: ['index.html']

run Disque::Web::Api
