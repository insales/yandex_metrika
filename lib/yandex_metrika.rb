require 'insales/yandex_metrika'

ActiveSupport.on_load(:action_controller) do
  ActionController::Base.send :include, Insales::YandexMetrikaMixin
end
