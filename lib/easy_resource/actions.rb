module EasyResource
  module Actions
    # GET /resources
    def index
      respond_with(collection)
    end

    # GET /resources/1
    def show
      respond_with(resource)
    end

    # GET /resources/new
    def new
      respond_with(build_resource)
    end

    # GET /resources/1/edit
    def edit
      respond_with(resource)
    end

    # POST /resources
    def create
      object = build_resource
      object.save
      respond_with(object, location: redirect_location)
    end

    # PUT /resources/1
    def update
      object = resource
      object.update_attributes(resource_params)
      respond_with(object, location: redirect_location)
    end

    # DELETE /resources/1
    def destroy
      object = resource
      object.destroy
      respond_with(object, location: redirect_location)
    end

    private

    def redirect_location
      polymorphic_path([namespace, resource])
    end
  end
end
