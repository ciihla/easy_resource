# frozen_string_literal: true
module EasyResource
  module HtmlTitle
    extend ActiveSupport::Concern

    included do
      include EasyResource::ProcOrObject

      helper_method :html_title
      cattr_accessor :html_title

      def html_title(key = action_name)
        proc_object(self.class.html_title[key.to_sym], view_context)
      end
    end

    module ClassMethods
      def prepare_html_title(options = {})
        self.html_title ||= {}
        options.each do |action, value|
          self.html_title[action] = value
        end
      end
    end
  end
end
