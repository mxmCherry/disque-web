require 'rack/contrib'
require_relative 'disque/web/api'

use Rack::TryStatic, \
  root: File.expand_path('../public', __FILE__),
  urls: ['/'],
  try: ['index.html']

run Disque::Web::API
