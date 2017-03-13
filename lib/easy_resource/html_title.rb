# frozen_string_literal: true
module EasyResource
  module HtmlTitle
    extend ActiveSupport::Concern

    included do
      include EasyResource::ProcOrObject

      helper_method :html_title
      class_attribute :html_title, instance_accessor: false, instance_predicate: false
    end

    module ClassMethods
      def prepare_html_title(options = {})
        self.html_title = options
      end
    end

    def html_title(key = action_name)
      proc_object(self.class.html_title[key.to_sym], view_context)
    end
  end
end
