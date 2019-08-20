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
      build_resource.save
      respond_with(resource, location: redirect_location)
    end

    # PUT /resources/1
    def update
      resource.update(resource_params)
      respond_with(resource, location: redirect_location)
    end

    # DELETE /resources/1
    def destroy
      resource.destroy
      respond_with(resource, location: redirect_collection)
    end

    private

    def redirect_collection
      polymorphic_path([namespace, resource_class])
    end

    def redirect_location
      polymorphic_path([namespace, resource])
    end
  end
end
