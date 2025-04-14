# Togglefy

![Gem](https://img.shields.io/gem/v/togglefy)
![Downloads](https://img.shields.io/gem/dt/togglefy)

Togglefy is a simple feature management solution to help you control which features an user or a group has access to.

Togglefy is free, open source and you are welcome to help build it.

## Installation

Add the gem manually to your Gemfile:

```gemfile
gem 'togglefy', '~> 1.0', '>= 1.1.0'
```

Or install it and add to the application's Gemfile by executing:

```bash
bundle add togglefy
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install togglefy
```

## Usage

### First steps

#### Installing inside the project
After adding the gem to your project, you need to run the generate command to add the necessary files:
```bash
rails generate togglefy:install
```

This command will create the migrations to create the tables inside your project. Please, don't remove/change anything that's there or Togglefy may not work as expected.

Run the migration to create these in your datase:
```bash
rails db:migrate
```
Or if you're using a legacy codebase:
```bash
rake db:migrate
```

The models are stored inside Togglefy, so you don't need to create them inside your project unless you want to.

If that's something you want, you can check them following this path: `app/models/togglefy/`.

After that, the next steps are also pretty simple.

#### Including inside the Assignable

Add the following to your model that will have a relation with the features. It can be an `User`, `Account` or something you decide:
```ruby
include Togglefy::Assignable
```

This will add the relationship between Togglefy's models and yours. Yours will be referred to as **assignable** throughout this documentation. If you want to check it in the source code, you can find it here: `lib/togglefy/assignable.rb` inside de `included` block.

Old versions (`<= 1.0.2`) had the `Featureable` instead of the `Assignable`. The `Featureable` is now deprecated. You can still use it and it won't impact old users, but we highly recommend you to use the `Assignable` as it is semantically more accurate about what it does.

With that, everything is ready to use **Togglefy**, welcome!

### Managing Features

#### Creating Features
To create features it's as simple as drinking a nice cold beer after a hard day or drinking the entire bottle of coffee in a span of 1 hour:

```ruby
Togglefy::Feature.create(
  name: "Magic",
  description: "You're a Wizard, Harry"
) # To create a simple Feature
```

If you have tenant, groups (or roles), difference between environments, you can do the following:

```ruby
Togglefy::Feature.create(
  name: "Super Powers",
  description: "With great power comes great responsibility", 
  tenant_id: "123abc",
  group: :admin,
  environment: :production
)
```

You can also use:

```ruby
Togglefy.create(
  name: "Teleportation",
  description: "Allows the assignable to teleport to anywhere",
  group: :jumper
)

# Or

Togglefy.create_feature(
  name: "Teleportation",
  description: "Allows the assignable to teleport to anywhere",
  group: :jumper
)
```

You don't have to fill all fields, the only one that is mandatory is the name, because is by using the name that we will create the unique identifier, which is the field we'll use to find, delete and more.

The identifier is the name, downcased and snake_cased 🐍

Whenever you create a `Togglefy::Feature`, you can expect something like this:

```ruby
id: 1,
name: "Super Powers",
identifier: "super_powers",
description: "With great power comes great responsibility",
created_at: "2025-04-12 01:39:10.176561000 +0000",
updated_at: "2025-04-12 01:39:46.818928000 +0000",
tenant_id: "123abc",
group: "admin",
environment: "production",
status: "inactive"
```

#### Updating a Feature

To update a feature is as simple as riding on a monocycle while balancing a cup of water on the top of a really tall person that's on your shoulders.

Here's how you can do it:

```ruby
Togglefy.update(:super_powers, tenant_id: "abc123")
Togglefy.update_feature(:super_powers, tenant_id: "abc123")
```

Or by finding the feature manually and then updating it like you always do with Rails:

```ruby
feature = Togglefy::Feature.find_by(identifier: :super_powers)
# or
feature = Togglefy.feature(:super_powers) # This is explained more in the "Finding a specific feature" section of this README

feature.update(tenant_id: "123abc")
```

#### Destroying Features

It looks like you're mean 😈

So here's how you can destroy a feature:

```ruby
Togglefy.destroy(:super_powers)
Togglefy.destroy_feature(:super_powers)
Togglefy::Feature.identifier(:super_powers).destroy
Togglefy::Feature.find_by(identifier: :super_powers).destroy
```

#### Toggle Features

You can toggle a feature status to active or inactive by doing this:

```ruby
Togglefy.toggle(:super_powers)
Togglefy.toggle_feature(:super_powers)
```

#### About `Togglefy::Feature` status

As you can see, the `Togglefy::Feature` also has a status and it is default to `inactive`. You can change this during creation.

The status holds the `inactive` or `active` values. This status is not to define if a assignable (any model that has the `include Togglefy::Assignable`) either has ou hasn't a feature, but to decide if this feature is available in the entire system.

It's up to you to define how you will implement it.

* Is it disabled? Then this feature is likely unrelease
* Or maybe if it is disabled, you can see the flag to active to an assignable but can't change the values?

Again, it's up to you!

You can change the status by:
* Sending a value during creation
* Updating the column
* Doing a:
  ```ruby
  Togglefy::Feature.find_by(identifier: :super_powers).active!
  Togglefy.feature(:super_powers).active!
  Togglefy.active!(:super_powers)
  Togglefy.activate_feature(:super_powers)

  Togglefy::Feature.find_by(identifier: :super_powers).inactive!
  Togglefy.feature(:super_powers).inactive!
  Togglefy.inactive!(:super_powers)
  Togglefy.inactivate_feature(:super_powers)
  ```

### Managing Assignables <-> Features
Now that we know how to create features, let's check how we can manage them.

An assignable has some direct methods thanks to the `include Togglefy::Assignable`, which are (and let's use an user as an example of an assignable):

```ruby
user.has_feature?(:super_powers) # Checks if user has a single feature
user.add_feature(:super_powers) # Adds a feature to user
user.remove_feature(:super_powers) # Removes a feature from an user
user.clear_features # Clears all features from an user
```

The assignable <-> feature relation is held by the `Togglefy::FeatureAssignment` table/model.

But there's another way to manage assignables <-> features by using the `FeatureAssignableManager`. It's up to you to decide which one.

Here are the examples:

```ruby
Togglefy.for(assignable).has?(:super_powers) # Checks if assignable (user || account || anything) has a single feature
Togglefy.for(assignable).enable(:super_powers) # Enables/adds a feature to an assignable
Togglefy.for(assignable).disable(:super_powers) # Disables/removes a feature from an assignable
Togglefy.for(assignable).clear # Clears all features from an assignable
```

You can also supercharge it by chaining methods, like:

```ruby
# Instead of doing this:
Togglefy.for(assignable).disable(:alpha_access)
Togglefy.for(assignable).enable(:beta_access)

# You can go something like this:
Togglefy.for(assignable).disable(:alpha_access).enable(:beta_access)
```

This second method may look strange, but it's the default used by the gem and you will see that right now!

### Querying Features
Remember when I told you a looooong time ago that the strange way is the default using by the gem? If you don't, no worries. It was a really loooong time ago, like `1.minute.ago`.

It's actually pretty simple. Each line of each code block will show you a way to query to achieve the same result in the context. You **don't** need to use all of options listed in each code block.

#### Querying Features (plural)

To query `Togglefy::Feature` from a specific group (the same applies to environment and tenant), you would do something like this:

```ruby
Togglefy::Feature.where(group: :dev)
Togglefy::Feature.for_group(:dev)
Togglefy.for_group(:dev)
Togglefy.for_role(:dev)
Togglefy.for_filters(filters: {group: :dev})
Togglefy.for_filters(filter: {role: :dev})
```

The `for_filters` is recommended when you want to use more than one filter, like:

```ruby
Togglefy.for_filters(filters: {group: :admin, environment: :production})
```

This will query me all `Togglefy::Feature`s that belongs to group admin and the production environment.

The `Togglefy.for_filters` can have the following filters:

```ruby
filters: {
  group:,
  role:, # Acts as a group, explained in the Aliases section
  environment:,
  env:, # Acts as a group, explained in the Aliases section
  tenant_id:,
  status:,
  identifier:
}
```

The `Togglefy.for_filters` will only apply the filters sent that are `nil` or `!value.blank?`.

You can send `nil` values too, like:

```ruby
Togglefy.for_tenant(nil) # This will query me all Togglefy::Features with tenant_id nil

Togglefy.for_filters(filters: {group: :admin, environment: nil, tenant_id: nil})
```

There's also another way to filter for `nil` values:

```ruby
Togglefy.without_group
Togglefy.without_role

Togglefy.without_environment
Togglefy.without_env

Togglefy.without_tenant
```

#### Querying by Status
To query Togglefy::Features by status (the same applies to inactive).

```ruby
Togglefy::Feature.where(status: :active)
Togglefy::Feature.active
Togglefy.with_status(:active)
```

#### Finding a specific feature
```ruby
Togglefy.feature(:super_powers)
Togglefy::Feature.identifier(:super_powers)
Togglefy::Feature.find_by(identifier: :super_powers)
```

#### Querying all features
```ruby
Togglefy.features(:super_powers)
Togglefy::Feature.all
```

#### Querying all features enabled to a klass
Let's assume that you have two different assignables: User and Account.

You want to list all features being used by assignables of User type:

```ruby
Togglefy.for_type(User) # This is return all current FeatureAssignment with a User assignable
```

#### Aliases

By the way, did you notice that I wrote `group` and `role` to get group?

There are aliases for both group and environment that can be used outside of `Togglefy::Feature`. If you want to query `Togglefy::Feature` directly, use only the default name.
* `group` can be written as `role` outside of `Togglefy::Feature`
* `environment` can be written as `env` out side of `Togglefy::Feature`

```ruby
Togglefy.for_group(:dev)
Togglefy.for_role(:dev)
Togglefy.for_filters(filters: {group: :dev})
Togglefy.for_filters(filter: {role: :dev})

Togglefy.for_environment(:production)
Togglefy.for_env(:production)
Togglefy.for_filters(filters: {environment: :production})
Togglefy.for_filters(filter: {env: :production})
```

## Aliases table

Here's a table of all aliases available on Togglefy.

You can use either, as long as you respect the rules listed.

| Original              | Alias                | Rules                                               |
| --------------------- | -------------------- | --------------------------------------------------- |
| `for_group`           | `for_role`           | Can't be used if doing a direct `Togglefy::Feature` |
| `without_group`       | `without_role`       | Can't be used if doing a direct `Togglefy::Feature` |
| `for_environment`     | `for_env`            | Can't be used if doing a direct `Togglefy::Feature` |
| `without_environment` | `without_env`        | Can't be used if doing a direct `Togglefy::Feature` |
| `create`              | `create_feature`     | None                                                |
| `update`              | `update_feature`     | None                                                |
| `toggle`              | `toggle_feature`     | None                                                |
| `active!`             | `activate_feature`   | None                                                |
| `deactive!`           | `inactivate_feature` | None                                                |
| `destroy`             | `destroy_feature`    | None                                                |


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/azeveco/togglefy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/azeveco/togglefy/blob/master/CODE_OF_CONDUCT.md).

There's a PR Template. Its use is highly encouraged.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the togglefy project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/azeveco/togglefy/blob/master/CODE_OF_CONDUCT.md).
