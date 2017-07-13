ENV['Rails.env'] = 'test'

require 'rubygems'
require 'test/unit'
require 'mocha/test_unit'

require File.expand_path(File.dirname(__FILE__) + '/../lib/insales/yandex_metrika.rb')

