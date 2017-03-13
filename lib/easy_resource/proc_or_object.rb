# frozen_string_literal: true
module EasyResource
  module ProcOrObject
    extend ActiveSupport::Concern

    def proc_object(obj, values)
      obj.is_a?(Proc) ? obj.call(*values) : obj
    end
  end
end
