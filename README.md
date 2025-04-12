# Jane

Jane is a simple feature management solution to help you control which features an user or a group has access to.

Jane is free, open source and you are welcome to help build it.

## Installation

### UNDER CONSTRUCTION BECAUSE GEM STILL NEEDS TO BE UPLOADED TO RUBYGEMS

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Add the gem manually to your Gemfile:

```gemfile
gem "jane"
```

Or install it and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

### First steps

#### Installing inside the project
After adding the gem to your project, you need to run the generate command to add the necessary files:
```bash
rails generate jane:install
```

This command will create the migrations to create the tables inside your project. Please, don't remove/change anything that's there or Jane may not work as expected.

Run the migration to create these in your datase:
```bash
rails db:migrate
```
Or if you're using a legacy codebase:
```bash
rake db:migrate
```

The models are stored inside Jane, so you don't need to create them inside your project unless you want to.

If that's something you want, you can check them following this path: `app/models/jane/`.

After that, the next steps are also pretty simple.

#### Including inside the Assignable

Add the following to your model that will have a relation with the features. It can be an `User`, `Account` or something you decide:
```ruby
include Jane::Featureable
```

This will add the relationship between Jane's models and yours. Yours will be referred to as **assignable** throughout this documentation. If you want to check it in the source code, you can find it here: `lib/jane/featureable.rb` inside de `included` block.

With that, everything is ready to use **Jane**, welcome!

### Creating Features
To create features it's as simple as drinking a nice cold beer after a hard day or drinking the entire bottle of coffee in a span of 1 hour:

```ruby
Jane::Feature.create(
  name: "Magic",
  description: "You're a Wizard, Harry"
) # To create a simple Feature
```

If you have tenant, groups (or roles), difference between environments, you can do the following:

```ruby
Jane::Feature.create(
  name: "Super Powers",
  description: "With great power comes great responsibility", 
  tenant_id: "123abc",
  group: :admin,
  environment: :production
)
```

You don't have to fill all fields, the only one that is mandatory is the name, because is by using the name that we will create the unique identifier, which is the field we'll use to find, delete and more.

The identifier is the name, downcased and snake_cased 🐍

Whenever you create a `Jane::Feature`, you can expect something like this:

```ruby
id: 1,
name: "Super Powers",
identifier: "super_powers",
description: "With great power comes great responsibility",
created_at: "2025-04-12 01:39:10.176561000 +0000",
updated_at: "2025-04-12 01:39:46.818928000 +0000",
tenant: "123abc",
group: "admin",
environment: "production",
status: "inactive"
```

#### About `Jane::Feature` status

As you can see, the `Jane::Feature` also has a status and it is default to `inactive`. You can change this during creation.

The status holds the `inactive` or `active` values. This status is not to define if a assignable (any model that has the `include Jane::Featureable`) either has ou hasn't a feature, but to decide if this feature is available in the entire system.

It's up to you to define how you will implement it.

* Is it disabled? Then this feature is likely unrelease
* Or maybe if it is disabled, you can see the flag to active to an assignable but can't change the values?

Again, it's up to you!

You can change the status by:
* Sending a value during creation
* Updating the column
* Doing a:
  ```ruby
  feature.active! # To activate
  feature.inactive! # To inactivate
  ```

### Managing Assignables <-> Features
Now that we know how to create features, let's check how we can manage them.

An assignable has some direct methods thanks to the `include Jane::Featureable`, which are (and let's use an user as an example of an assignable):

```ruby
user.has_feature?(:super_powers) # Checks if user has a single feature
user.add_feature(:super_powers) # Adds a feature to user
user.remove_feature(:super_powers) # Removes a feature from an user
user.clear_features # Clears all features from an user
```

The assignable <-> feature relation is held by the `Jane::FeatureAssignment` table/model.

But there's another way to manage assignables <-> features by using the `FeatureManager`. It's up to you to decide which one.

Here are the examples:

```ruby
Jane.for(assignable).has?(:super_powers) # Checks if assignable (user || account || anything) has a single feature
Jane.for(assignable).enable(:super_powers) # Enables/adds a feature to an assignable
Jane.for(assignable).disable(:super_powers) # Disables/removes a feature from an assignable
Jane.for(assignable).clear # Clears all features from an assignable
```

This second method may look strange, but it's the default used by the gem and you will see that right now!

### Querying Features
Remember when I told you a looooong time ago that the strange way is the default using by the gem? If you don't, no worries. It was a really loooong time ago, like `1.minute.ago`.

It's actually pretty simple. Each line of each code block will show you a way to query to achieve the same result in the context. You **don't** need to use all of options listed in each code block.

#### Querying Features (plural)

To query `Jane::Feature` from a specific group (the same applies to environment and tenant), you would do something like this:

```ruby
Jane::Feature.where(group: :dev)
Jane::Feature.for_group(:dev)
Jane.for_group(:dev)
Jane.for_role(:dev)
Jane.for_filters(filters: {group: :dev})
Jane.for_filters(filter: {role: :dev})
```

The `for_filters` is recommended when you want to use more than one filter, like:

```ruby
Jane.for_filters(filters: {group: :admin, environment: :production})
```

This will query me all `Jane::Feature`s that belongs to group admin and the production environment.

You can send `nil` values too, like:

```ruby
Jane.for_tenant(nil) # This will query me all Jane::Features with tenant_id nil

Jane.for_filters(filters: {group: :admin, environment: :nil, tenant_id: nil})
```

There's also another way to filter for `nil` values:

```ruby
Jane.without_group
Jane.without_role

Jane.without_environment
Jane.without_env

Jane.without_tenant
```

#### Querying by Status
To query Jane::Features by status (the same applies to inactive).

```ruby
Jane::Feature.where(status: :active)
Jane::Feature.active
Jane.with_status(:active)
```

#### Finding a specific feature
```ruby
Jane.feature(:super_powers)
Jane::Feature.find_by(identifier: :super_powers)
```

#### Finding a specific feature just to destroy it because you're mean 😈
```ruby
Jane.destroy_feature(:super_powers)
Jane::Feature.find_by(identifier: :super_powers).destroy
```

#### Querying all features enabled to a klass
Let's assume that you have two different assignables: User and Account.

You want to list all features being used by assignables of User type:

```ruby
Jane.for_type(User) # This is return all current FeatureAssignment with a User assignable
```

#### Aliases

By the way, did you notice that I wrote `group` and `role` to get group?

There are aliases for both group and environment that can be used outside of `Jane::Feature`. If you want to query `Jane::Feature` directly, use only the default name.
* `group` can be written as `role` outside of `Jane::Feature`
* `environment` can be written as `env` out side of `Jane::Feature`

```ruby
Jane.for_group(:dev)
Jane.for_role(:dev)
Jane.for_filters(filters: {group: :dev})
Jane.for_filters(filter: {role: :dev})

Jane.for_environment(:production)
Jane.for_env(:production)
Jane.for_filters(filters: {environment: :production})
Jane.for_filters(filter: {env: :production})
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/azeveco/jane. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/azeveco/jane/blob/master/CODE_OF_CONDUCT.md).

There's a PR Template. Its usa is highly encouraged.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the jane project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/azeveco/jane/blob/master/CODE_OF_CONDUCT.md).
