require "roda"

module Ns
  class AppHtml < Roda
    plugin :render, engine: 'haml', views: 'html/views'
    plugin :static, %w(/images /css /js), root: 'html/public'

      route do |r|
        r.root {
          @body_class = '.container'
          view 'index'
        }
        r.get('ref_diagram'){
          view 'ref_diagram'
        }
        r.get('percent_diagram'){
          view 'percent_diagram'
        }

      end
  end
end