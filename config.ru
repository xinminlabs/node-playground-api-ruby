require 'bundler'
Bundler.require(:default)
$LOAD_PATH << 'lib'
require 'app'

$stdout.sync = true
run App
