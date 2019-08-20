module EasyResource
  module BaseController
    extend ActiveSupport::Concern

    included do
      include EasyResource::Actions
      include EasyResource::HtmlTitle
      self.responder = EasyResource::Responder
      helper_method :resource, :resource_class, :collection, :namespace, :resource_name

      respond_to :html if mimes_for_respond_to.empty?

      prepare_html_title index: ->(c) { c.resource_class.model_name.human.pluralize },
                         new: ->(c) { "New #{c.resource_class.model_name.human}" },
                         create: ->(c) { "New #{c.resource_class.model_name.human}" },
                         edit: ->(c) { "Editing #{c.resource_class.model_name.human}" },
                         update: ->(c) { "Editing #{c.resource_class.model_name.human}" },
                         show: ->(c) { c.resource_class.model_name.human }

    end

    private

    def resource_class
      @resource_class ||= begin
        controller_name.classify.constantize
      rescue NameError
        raise 'Implement resource_class!'
      end
    end

    def permitted_params
      raise 'Implement me!'
    end

    def resource_params
      @resource_params ||= params[resource_name].blank? ? {} : permitted_params
    end

    def resource_name
      @resource_name ||= controller_name.singularize
    end

    def build_resource
      @resource ||= collection.build(resource_params)
    end

    def resource
      @resource ||= collection.find(params[:id])
    end

    def collection
      @collection ||= resource_class.all
    end

    def namespace
      @namespace ||= begin
        path = controller_path.split('/')
        path.second ? path.first : nil
      end
    end
  end
end
