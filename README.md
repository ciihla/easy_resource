# EasyResource

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_resource'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_resource

## TODO
  Implement tests!

## Basic Usage

To use EasyResource you just have to include it:

```ruby
class ResourcesController < ApplicationController::Base
  include EasyResource::BaseController
end
```

Then you can inherit from this controller (don't forget to overwrite permitted_params!):
```ruby
class UsersController < ResourcesController
  private

  def permitted_params
    params[:user].permit(:name, :email)
  end
end
```

## RSpec Usage

To use Rspec CRUD macro you just have to include it:

```ruby
require 'easy_resource/spec_crud_macro'

RSpec.configure do |config|
  config.include EasyResource::SpecCrudMacro, type: :controller
end
```

Then you can test your controller:

```ruby
RSpec.describe Admin::UsersController, type: :controller do
  let(:valid_attributes) { FactoryBot.attributes_for(:user) }
  let(:invalid_attributes) { { name: '' } }
  let(:new_attributes) { { name: 'Updated' } }

  context 'signed_in ' do
    let(:admin) { FactoryBot.create(:admin) }
    before(:each) { sign_in(admin) }
    crud_spec(:user)
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ciihla/easy_resource.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

