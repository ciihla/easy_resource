module EasyResource
  module BaseController
    extend ActiveSupport::Concern

    included do
      include EasyResource::Actions
      self.responder = EasyResource::Responder
      helper_method :resource, :resource_class, :collection, :namespace

      respond_to :html if mimes_for_respond_to.empty?
    end

    private

    def resource_class
      @resource_class ||= begin
        controller_name.classify.constantize
      rescue NameError
        nil
      end
    end

    def permitted_params
      raise 'Implement me!'
    end

    def resource_params
      @resource_params ||= params[resource_name].blank? ? {} : permitted_params
    end

    def resource_name
      controller_name.singularize
    end

    def build_resource
      @resource ||= end_of_association_chain.send(method_for_build, resource_params)
    end

    def resource
      @resource ||= end_of_association_chain.find(params[:id])
    end

    def collection
      @collection ||= end_of_association_chain.all
    end

    def namespace
      @namespace ||= begin
        path = controller_path.split('/')
        path.second ? path.first : nil
      end
    end

    def method_for_build
      begin_of_association_chain ? :build : :new
    end

    def method_for_association_chain
      resource_name.pluralize
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
