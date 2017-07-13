spec = Gem::Specification.new do |s|
  s.name              = 'yandex_metrika'
  s.version           = '1.0.0'
  s.date              = "2009-09-12"
  s.has_rdoc          = true
  s.summary           = "[Rails] Easily enable Yandex Metrika support in your Rails application."

  s.description = 'By default this gem will output yandex.metrika code for' +
                  "every page automatically, if it's configured correctly." +
                  "This is done by adding:\n" +
                  "Insales::YandexMetrika.tracker_id = '227250'\n"
                  'to your `config/environment.rb`, inserting your own tracker id.'
                  'This can be discovered by looking at the value assigned to +Ya.Metrika+' +
                  'in the Javascript code.'
  
  s.files = %w( CREDITS MIT-LICENSE README.rdoc Rakefile rails/init.rb
                test/yandex_metrika_test.rb
                test/test_helper.rb
                lib/insales.rb
                lib/insales/yandex_metrika.rb)

  s.add_dependency 'actionpack'
  s.add_dependency 'active_support'
end
