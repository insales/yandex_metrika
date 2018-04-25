require 'rails'

module Insales # :nodoc:
  # This module gets mixed in to ActionController::Base
  module YandexMetrikaMixin
    # The javascript code to enable Google Analytics on the current page.
    # Normally you won't need to call this directly; the +add_yandex_metrika_code+
    # after filter will insert it for you.
    def yandex_metrika_code(options = {})
      YandexMetrika.yandex_metrika_code(options) if YandexMetrika.enabled?(request.format)
    end

    # An after_filter to automatically add the analytics code.
    # If you intend to use the link_to_tracked view helpers, you need to set Insales::YandexMetrika.defer_load = false
    # to load the code at the top of the page
    def add_yandex_metrika_code(options = {})
      if YandexMetrika.defer_load
        append_to_body(/<\/body>/i, "#{yandex_metrika_code(options)}</body>")
      else
        append_to_body(/(<body[^>]*>)/i, "\\1#{yandex_metrika_code(options)}")
      end
    end
  end

  class YandexMetrikaConfigurationError < StandardError; end

  # The core functionality to connect a Rails application
  # to a Yandex Metrika installation.
  class YandexMetrika

    ECOMMERCE_DATA_CONTAINER = "dataLayer"

    @@tracker_id = nil
    ##
    # :singleton-method:
    # Specify the Yandex Metrika ID for this web site. This can be found
    # as the value of Ya.Metrika
    cattr_accessor :tracker_id

    @@environments = ['production']
    ##
    # :singleton-method:
    # The environments in which to enable the Yandex Metrika code. Defaults
    # to 'production' only. Supply an array of environment names to change this.
    cattr_accessor :environments

    @@formats = [:html, :all]
    ##
    # :singleton-method:
    # The request formats where tracking code should be added. Defaults to +[:html, :all]+. The entry for
    # +:all+ is necessary to make Yandex recognize that tracking is installed on a
    # site; it is not the same as responding to all requests. Supply an array
    # of formats to change this.
    cattr_accessor :formats

    @@defer_load = true
    ##
    # :singleton-method:
    # Set this to true (the default) if you want to load the Metrika javascript at
    # the bottom of page. Set this to false if you want to load the Metrika
    # javascript at the top of the page. The page will render faster if you set this to
    # true
    cattr_accessor :defer_load

    # Return true if the Yandex.Metrika system is enabled and configured
    # correctly for the specified format
    def self.enabled?(format)
      raise Insales::YandexMetrikaConfigurationError if tracker_id.blank?
      environments.include?(Rails.env) && formats.include?(format && format.to_sym)
    end

    # Construct the javascript code to be inserted on the calling page.
    def self.yandex_metrika_code(options={})
      counter(options[:product_detail_options] || options)
    end

    def self.counter(options)
      additional_javascript = options.delete(:additional_javascript)
      code = <<-HTML
<!-- Yandex.Metrika counter -->

<script type="text/javascript">
(function (d, w, c) {
    (w[c] = w[c] || []).push(function() {
        try {
            w.yaCounter#{tracker_id} = new Ya.Metrika(
                   {id:#{tracker_id},
                    webvisor:true,
                    clickmap:true,
                    ecommerce:#{ECOMMERCE_DATA_CONTAINER},
                    trackLinks:true,
                    accurateTrackBounce:true}
                  );
        } catch(e) { }
    });

    var n = d.getElementsByTagName("script")[0],
        s = d.createElement("script"),
        f = function () { n.parentNode.insertBefore(s, n); };
    s.type = "text/javascript";
    s.async = true;
    s.src = "https://mc.yandex.ru/metrika/watch.js";

    if (w.opera == "[object Opera]") {
        d.addEventListener("DOMContentLoaded", f, false);
    } else { f(); }
})(document, window, "yandex_metrika_callbacks");
</script>
<script type="text/javascript">
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push(#{options.to_json});
  #{additional_javascript}
</script>
<noscript><div><img src="https://mc.yandex.ru/watch/#{tracker_id}" style="position:absolute; left:-9999px;" alt="" /></div></noscript>
<!-- /Yandex.Metrika counter -->
HTML

    end
  end
end
