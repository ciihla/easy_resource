module EasyResource
  module SpecCrudMacro
    def self.included(base)
      base.include(Rails.application.routes.url_helpers)
      base.extend(ClassMethods)
    end

    def klass(meth)
      meth.to_s.classify.constantize
    end

    def directory(meth)
      assigns(meth.to_s.pluralize)
    end

    def object_assign(meth)
      assigns(meth)
    end

    module ClassMethods
      def crud_spec(model_name, options = {})
        let(:model) { options[:model] ? send(options[:model]) : FactoryGirl.create(model_name) }
        options.reverse_merge!(exclude_actions: [])

        context 'crud spec' do
          %i(index show new edit create update destroy).each do |action|
            send("#{action}_action", model_name) unless options[:exclude_actions].map(&:to_sym).include?(action)
          end
        end
      end

      def index_action(model_name)
        describe 'GET index' do
          it 'assigns all instances as results' do
            instance = model
            get :index
            expect(response).to be_success
            expect(directory(model_name)).to include(instance)
          end
        end
      end

      def show_action(model_name)
        describe 'GET show' do
          it 'assigns a new model_name as @instance and render show' do
            instance = model
            get :show, id: instance.to_param
            expect(response).to be_success
            expect(assigns(model_name)).to eq(instance)
            expect(response).to render_template('show')
          end
        end
      end

      def new_action(model_name)
        describe 'GET new' do
          it 'assigns a new model_name as @instance' do
            get :new
            expect(response).to be_success
            expect(object_assign(model_name)).to be_a_new(klass(model_name))
          end
        end
      end

      def edit_action(model_name)
        describe 'GET edit' do
          it 'assigns the requested model_name as @instance' do
            instance = model
            get :edit, id: instance.to_param
            expect(response).to be_success
            expect(assigns(model_name)).to eq(instance)
            expect(response).to render_template('edit')
          end
        end
      end

      def create_action(model_name)
        context 'POST create' do
          describe 'with valid params' do
            it "creates a new #{model_name.capitalize}" do
              expect do
                post :create, model_name => valid_attributes
              end.to change(klass(model_name), :count).by(1)
            end

            it 'assigns a newly created model_name as @instance' do
              post :create, model_name => valid_attributes
              expect(object_assign(model_name)).to be_a(klass(model_name))
              expect(object_assign(model_name)).to be_persisted
            end

            it 'redirects to the created instance' do
              post :create, model_name => valid_attributes
              expect(response).to be_redirect
            end
          end

          describe 'with invalid params' do
            it 'assigns a newly created but unsaved model_name as @instance' do
              post :create, model_name => invalid_attributes
              expect(object_assign(model_name)).to be_a_new(klass(model_name))
            end

            it "re-renders the 'new' instance" do
              post :create, model_name => invalid_attributes
              expect(response).to render_template('new')
            end
          end
        end
      end

      def update_action(model_name)
        describe 'PUT update' do
          describe 'with valid params' do
            it 'updates the requested instance' do
              instance = model
              put :update, id: instance.to_param, model_name => new_attributes
              instance.reload
              new_attributes.each do |key, val|
                expect(instance.send(key)).to eq(val)
              end
            end

            it 'assigns the requested model_name as @instance' do
              put :update, id: model.to_param, model_name => valid_attributes
              expect(object_assign(model_name)).to eq(model)
            end

            it 'redirects to the instance' do
              instance = model
              put :update, id: instance.to_param, model_name => valid_attributes
              expect(response).to be_redirect
            end
          end

          describe 'with invalid params' do
            it 'assigns the model_name as @instance' do
              instance = model
              put :update, id: instance.to_param, model_name => invalid_attributes
              expect(object_assign(model_name)).to eq(instance)
            end

            it "re-renders the 'edit' instance" do
              if invalid_attributes.present?
                put :update, id: model.to_param, model_name => invalid_attributes
                expect(response).to render_template('edit')
              end
            end
          end
        end
      end

      def destroy_action(model_name)
        describe 'DELETE destroy' do
          it 'deletes a instance' do
            instance = model
            expect { delete :destroy, id: instance.id }.to change { klass(model_name).count }.by(-1)
          end

          it 'redirects to index' do
            delete :destroy, id: model.id
            expect(response).to be_redirect
          end
        end
      end
    end
  end
end
