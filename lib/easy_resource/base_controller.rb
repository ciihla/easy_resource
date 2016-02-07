module EasyResource
  module BaseController
    extend ActiveSupport::Concern

    included do
      include EasyResource::Actions
      self.responder = EasyResource::Responder
      helper_method :resource, :resource_class, :collection, :namespace

      respond_to :html if mimes_for_respond_to.empty?
    end

    def resource_class
      @resource_class ||= begin
        class_name = controller_name.classify
        class_name.constantize
      rescue NameError
        nil
      end
    end

    def permitted_params
      fail 'Implement me!'
    end

    def resource_params
      @resource_params ||= params[resource_request_name].blank? ? {} : permitted_params
    end

    def collection_name
      instance_name.pluralize
    end

    def instance_name
      controller_name.singularize
    end

    def resource_request_name
      resource_class.to_s.underscore
    end

    def resource_collection_name
      collection_name
    end

    def build_resource
      resource_ivar || setup_resource_ivar(end_of_association_chain.send(method_for_build, resource_params))
    end

    def resource
      resource_ivar || setup_resource_ivar(end_of_association_chain.send(method_for_find, params[:id]))
    end

    def collection
      collection_ivar || setup_collection_ivar(end_of_association_chain.all)
    end

    def namespace
      @namespace ||= begin
        path = controller_path.split('/')
        path.second ? path.first : nil
      end
    end

    def resource_ivar
      instance_variable_get("@#{instance_name}")
    end

    def setup_resource_ivar(resource)
      instance_variable_set("@#{instance_name}", resource)
    end

    def collection_ivar
      instance_variable_get("@#{collection_name}")
    end

    def setup_collection_ivar(collection)
      instance_variable_set("@#{collection_name}", collection)
    end

    def method_for_build
      begin_of_association_chain ? :build : :new
    end

    def method_for_find
      :find
    end

    def method_for_association_chain
      resource_collection_name
    end

    def association_chain
      begin_of_association_chain ? begin_of_association_chain.send(method_for_association_chain) : resource_class
    end

    def end_of_association_chain
      association_chain
    end

    def begin_of_association_chain
      nil
    end
  end
end
