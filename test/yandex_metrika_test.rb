require File.dirname(__FILE__) + '/test_helper.rb'

Rails.env = 'test'

class TestMixin
  class MockRequest
    attr_accessor :format
  end
  class MockResponse
    attr_accessor :body
  end

  include Insales::YandexMetrikaMixin
  attr_accessor :request, :response

  def initialize
    self.request = MockRequest.new
    self.response = MockResponse.new
  end

  # override the mixin's method
  def yandex_metrika_code options
    "Yandex Metrika"
  end

  def append_to_body regex, content
    response.body = response.body.gsub regex, content
  end
end


class YandexMetrikaTest < Test::Unit::TestCase
  def setup
    @ya = Insales::YandexMetrika.new
    @ya.tracker_id = "the tracker id"
  end

  def test_createable
    assert_not_nil(@ya)
  end

  def test_default_environments
    assert_equal(false, @ya.environments.include?('test'))
    assert_equal(false, @ya.environments.include?('development'))
    assert_equal(true, @ya.environments.include?('production'))
  end

  def test_default_formats
    assert_equal(false, @ya.formats.include?(:xml))
    assert_equal(true, @ya.formats.include?(:html))
  end

  def test_defer_load_defaults_to_true
    assert_equal(true, @ya.defer_load)
  end

  # test self.enabled
  def test_enabled_requires_tracker_id
    Insales::YandexMetrika.stubs(:tracker_id).returns(nil)
    assert_raise(Insales::YandexMetrikaConfigurationError) { Insales::YandexMetrika.enabled?(:html) }
  end

  def test_enabled_returns_false_if_current_environment_not_enabled
    Insales::YandexMetrika.stubs(:environments).returns(['production'])
    assert_equal(false, Insales::YandexMetrika.enabled?(:html))
  end

  def test_enabled_with_default_format
    Insales::YandexMetrika.stubs(:environments).returns(['test'])
    assert_equal(true, Insales::YandexMetrika.enabled?(:html))
  end

  def test_disabled_with_not_included_format
    Insales::YandexMetrika.stubs(:environments).returns(['test'])
    assert_equal(false, Insales::YandexMetrika.enabled?(:xml))
  end

  def test_enabled_with_added_format
    Insales::YandexMetrika.stubs(:environments).returns(['test'])
    Insales::YandexMetrika.stubs(:formats).returns([:xml])
    assert_equal(true, Insales::YandexMetrika.enabled?(:xml))
  end

  # Test the before_filter method does what we expect by subsituting the body tags and inserting
  # some google code for us automagically.
  def test_add_yandex_metrika_code
    # setup our test mixin
    mixin = TestMixin.new

    # bog standard body tag
    Insales::YandexMetrika.defer_load = false
    mixin.response.body = "<body><p>some text</p></body>"
    mixin.add_yandex_metrika_code
    assert_equal mixin.response.body, '<body>Yandex Metrika<p>some text</p></body>'

    Insales::YandexMetrika.defer_load = true
    mixin.response.body = "<body><p>some text</p></body>"
    mixin.add_yandex_metrika_code
    assert_equal mixin.response.body, '<body><p>some text</p>Yandex Metrika</body>'

    # body tag upper cased (ignoring this is semantically incorrect)
    Insales::YandexMetrika.defer_load = false
    mixin.response.body = "<BODY><p>some text</p></BODY>"
    mixin.add_yandex_metrika_code
    assert_equal mixin.response.body, '<BODY>Yandex Metrika<p>some text</p></BODY>'

    Insales::YandexMetrika.defer_load = true
    mixin.response.body = "<BODY><p>some text</p></BODY>"
    mixin.add_yandex_metrika_code
    assert_equal mixin.response.body, '<BODY><p>some text</p>Yandex Metrika</body>'

    # body tag has additional attributes
    Insales::YandexMetrika.defer_load = false
    mixin.response.body = '<body style="background-color:red"><p>some text</p></body>'
    mixin.add_yandex_metrika_code
    assert_equal mixin.response.body, '<body style="background-color:red">Yandex Metrika<p>some text</p></body>'

    Insales::YandexMetrika.defer_load = true
    mixin.response.body = '<body style="background-color:red"><p>some text</p></body>'
    mixin.add_yandex_metrika_code
    assert_equal mixin.response.body, '<body style="background-color:red"><p>some text</p>Yandex Metrika</body>'
  end

end
