module EasyResource
  module SpecCrudMacro
    def self.included(base)
      base.include(Rails.application.routes.url_helpers)
      base.extend(ClassMethods)
    end

    def klass(meth)
      meth.to_s.classify.constantize
    end

    module ClassMethods
      def crud_spec(model_name, options = {})
        let(:model) { options[:model] ? send(options[:model]) : FactoryGirl.create(model_name) }
        options.reverse_merge!(exclude_actions: [], xhr_actions: false)

        context 'crud spec' do
          %i(index show new edit create update destroy).each do |action|
            xhr = options[:xhr_actions].is_a?(Array) ? options[:xhr_actions].map(&:to_sym).include?(action) : options[:xhr_actions]
            send("#{action}_action", model_name, xhr) unless options[:exclude_actions].map(&:to_sym).include?(action)
          end
        end
      end

      def index_action(model_name, xhr)
        describe 'GET index' do
          it 'assigns all instances as results' do
            instance = model
            get :index, xhr: xhr
            expect(response).to be_success
            expect(assigns(:collection)).to include(instance)
          end
        end
      end

      def show_action(_model_name, xhr)
        describe 'GET show' do
          it 'assigns a new model_name as @instance and render show' do
            instance = model
            get :show, xhr: xhr, params: { id: instance.to_param }
            expect(response).to be_success
            expect(assigns(:resource)).to eq(instance)
            expect(response).to render_template('show')
          end
        end
      end

      def new_action(model_name, xhr)
        describe 'GET new' do
          it 'assigns a new model_name as @instance' do
            get :new, xhr: xhr
            expect(response).to be_success
            expect(assigns(:resource)).to be_a_new(klass(model_name))
          end
        end
      end

      def edit_action(model_name, xhr)
        describe 'GET edit' do
          it 'assigns the requested model_name as @instance' do
            instance = model
            get :edit, xhr: xhr, params: { id: instance.to_param }
            expect(response).to be_success
            expect(assigns(:resource)).to eq(instance)
            expect(response).to render_template('edit')
          end
        end
      end

      def create_action(model_name, xhr)
        context 'POST create' do
          describe 'with valid params' do
            it "creates a new #{model_name.capitalize}" do
              expect do
                post :create, xhr: xhr, params: { model_name => valid_attributes }
              end.to change(klass(model_name), :count).by(1)
            end

            it 'assigns a newly created model_name as @instance' do
              post :create, xhr: xhr, params: { model_name => valid_attributes }
              expect(assigns(:resource)).to be_a(klass(model_name))
              expect(assigns(:resource)).to be_persisted
            end

            if xhr
              it "renders the 'create' template" do
                post :create, xhr: true, params: { model_name => invalid_attributes }
                expect(response).to render_template('create')
              end
            else
              it 'redirects to the created instance' do
                post :create, params: { model_name => valid_attributes }
                expect(response).to be_redirect
              end
            end
          end

          describe 'with invalid params' do
            it 'assigns a newly created but unsaved model_name as @instance' do
              post :create, xhr: xhr, params: { model_name => invalid_attributes }
              expect(assigns(:resource)).to be_a_new(klass(model_name))
            end

            if xhr
              it "renders the 'create' template" do
                post :create, xhr: true, params: { model_name => invalid_attributes }
                expect(response).to render_template('create')
              end
            else
              it "re-renders the 'new' instance" do
                post :create, params: { model_name => invalid_attributes }
                expect(response).to render_template('new')
              end
            end
          end
        end
      end

      def update_action(model_name, xhr)
        describe 'PUT update' do
          describe 'with valid params' do
            it 'updates the requested instance' do
              instance = model
              put :update, xhr: xhr, params: { id: instance.to_param, model_name => new_attributes }
              instance.reload
              new_attributes.each do |key, val|
                expect(instance.send(key)).to eq(val)
              end
            end

            it 'assigns the requested model_name as @instance' do
              put :update, xhr: xhr, params: { id: model.to_param, model_name => valid_attributes }
              expect(assigns(:resource)).to eq(model)
            end

            if xhr
              it "renders 'update' template" do
                instance = model
                put :update, xhr: true, params: { id: instance.to_param, model_name => valid_attributes }
                expect(response).to render_template('update')
              end
            else
              it 'redirects to the instance' do
                instance = model
                put :update, params: { id: instance.to_param, model_name => valid_attributes }
                expect(response).to be_redirect
              end
            end
          end

          describe 'with invalid params' do
            it 'assigns the model_name as @instance' do
              instance = model
              put :update, params: { id: instance.to_param, model_name => invalid_attributes }
              expect(assigns(:resource)).to eq(instance)
            end

            if xhr
              it "renders 'update' template" do
                if invalid_attributes.present?
                  put :update, xhr: true, params: { id: model.to_param, model_name => invalid_attributes }
                  expect(response).to render_template('update')
                end
              end
            else
              it "re-renders the 'edit' instance" do
                if invalid_attributes.present?
                  put :update, params: { id: model.to_param, model_name => invalid_attributes }
                  expect(response).to render_template('edit')
                end
              end
            end
          end
        end
      end

      def destroy_action(model_name, xhr)
        describe 'DELETE destroy' do
          it 'deletes a instance' do
            instance = model
            expect { delete :destroy, xhr: xhr, params: { id: instance.id } }.to change { klass(model_name).count }.by(-1)
          end

          if xhr
            it "renders 'destroy' template" do
              delete :destroy, xhr: true, params: { id: model.id }
              expect(response).to render_template('destroy')
            end
          else
            it 'redirects to index' do
              delete :destroy, params: { id: model.id }
              expect(response).to be_redirect
            end
          end
        end
      end
    end
  end
end
