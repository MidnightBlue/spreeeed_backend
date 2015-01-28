module SpreeeedBackend
  module ApplicationHelper

    def parent_layout(layout)
      # http://m.onkey.org/nested-layouts-in-rails-3
      @view_flow.set(:layout, output_buffer)
      self.output_buffer = render(:file => "layouts/#{layout}")
    end

  end
end
