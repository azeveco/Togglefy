# Togglefy

![Gem](https://img.shields.io/gem/v/togglefy)
![Downloads](https://img.shields.io/gem/dt/togglefy)

Togglefy is a simple feature management solution to help you control which features an user or a group has access to.

Togglefy is free, open source and you are welcome to help build it.

## Installation

Add the gem manually to your Gemfile:

```gemfile
gem 'togglefy', '~> 1.0', '>= 1.1.1'
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

This command will create the migrations to create the tables inside your project.

If you use an older version of Rails (< 5), then the migration files don't need you to specify the version.

To fix this, you will have to manually go to the two migration files of Togglefy: `create_feature` and `create_feature_assignments` and do the following:

Change these lines from this:

```ruby
rails_version = "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"

class CreateTogglefyFeatures < ActiveRecord::Migration[rails_version]
```

```ruby
rails_version = "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"

class CreateTogglefyFeatureAssignments < ActiveRecord::Migration[rails_version]
```

To this:

```ruby
class CreateTogglefyFeatures < ActiveRecord::Migration
```

```ruby
class CreateTogglefyFeatureAssignments < ActiveRecord::Migration
```

Please, don't remove/change anything else that's there or Togglefy may not work as expected.

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

Older versions (`<= 1.0.2`) had the `Featureable` instead of the `Assignable`. The `Featureable` is now deprecated. You can still use it and it won't impact old users, but we highly recommend you to use the `Assignable` as it is semantically more accurate about what it does.

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

#### Mass Enable/Disable of Features to/from Assignables
You can mass enable/disable features to/from Assignables.

Doing that is simple! Let's assume that your assignable is an User model.

```ruby
Togglefy.mass_for(User).bulk.enable(:super_powers) # To enable a specific feature to all users
Togglefy.mass_for(User).bulk.enable([:super_powers, :magic, ...]) # To enable two or more features to all users
Togglefy.mass_for(User).bulk.enable(:super_powers, percentage: 20) # To enable a feature to 20% of all users
Togglefy.mass_for(User).bulk.enable([:super_powers, :magic, ...], percentage: 50) # To enable two or more features to 50% of all users
```

The same applies to the disable:

```ruby
Togglefy.mass_for(User).bulk.disable(:super_powers) # To disable a specific feature to all users
Togglefy.mass_for(User).bulk.disable([:super_powers, :magic, ...]) # To disable two or more features to all users
Togglefy.mass_for(User).bulk.disable(:super_powers, percentage: 5) # To disable a feature to 5% of all users
Togglefy.mass_for(User).bulk.disable([:super_powers, :magic, ...], percentage: 75) # To disable two or more features to 75% of all users
```

There are a few things to pay attention:
* Whenever you do a enable/disable, it will only query for valid assignables, so:
  * If you do a enable, it will query all assignables that don't have the feature(s) enabled
  * If you do a disable, it will query all assignables that do already have the feature(s) enabled
* You can also use filters for:
  * `group || role`
  * `environment || env`
  * `tenant_id`
  * You can check about filters aliases at [Aliases table](#aliases-table)

These will be applied to query features that match the identifiers + the filters sent.

So it would be something like:

```ruby
Togglefy.mass_for(User).bulk.enable(:super_powers, group: :admin, percentage: 20)
Togglefy.mass_for(User).bulk.disable(:magic, group: :dev, env: :production, percentage: 75)
```

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

#### Finding multiple features
```ruby
Togglefy.feature([:super_powers, :magic])
Togglefy::Feature.identifier([:super_powers, :magic])
Togglefy::Feature.where(identifier: [:super_powers, :magic])
```

#### List all features of an Assignable
Let's pretend that your assignable is an User.

```ruby
user = User.find(1)
user.features
```

#### Check all features an Assignable have/doesn't have
Again, let's pretend that your assignable is an User. This is the only case you need to send the feature id and not the identifier.

```ruby
User.with_features(1)
User.with_features([2, 3])
User.without_features(1)
User.without_features([2, 3])
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
Togglefy.for_type(User) # This returns all current FeatureAssignment with a User assignable
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
| `group`               | `role`               | Used inside methods that receives filters           |
| `environment`         | `env`                | Used inside methods that receives filters           |
| `create`              | `create_feature`     | None                                                |
| `update`              | `update_feature`     | None                                                |
| `toggle`              | `toggle_feature`     | None                                                |
| `active!`             | `activate_feature`   | None                                                |
| `deactive!`           | `inactivate_feature` | None                                                |
| `destroy`             | `destroy_feature`    | None                                                |


## Development
### Setup the environment
1. Clone the repository
2. Run `bin/setup` on the Gem's root directory to install dependencies and run the dummy Rails app migrations used for tests
3. Create your branch and checkout to it

### Running the tests
1. Make sure that the dummy Rails app db and migrations were ran
2. Run `bundle exec rspec` on the Gem's root directory to run all the tests
3. If you want to specify a single file to run the tests: `bundle exec rspec path/to/spec/file.rb`
4. If you want to specify a single test of a single file to run: `bundle exec spec path/to/spec/file.rb:42` where 42 represents the number of the line

### Running RuboCop
1. Make sure you're at the Gem's root directory
2. Run `bundle exec rubocop` to run RuboCop on all files not ignored by the `.rubocop.yml` file
3. Run `bundle exec rubocop app spec lib/something.rb` to run RuboCop on specific directories/files
4. Run `bundle exec rubocop -a` to fix all the auto-correctable offenses listed by RuboCop

### Other
1. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Use local Togglefy Gem with a Rails application
1. Open the Gemfile of your Rails application
2. Add the following: `gem "togglefy", path: "path/to/togglefy/directory"`
3. Now you can test everything inside of your Rails application

#### If you make a change to the Togglefy's code and want to test it, make sure to:
1. If you're running a Rails server: restart
2. If you're running a Rails console: `reload!` or restart

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/azeveco/togglefy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/azeveco/togglefy/blob/master/CODE_OF_CONDUCT.md).

* Where can I check for planned features but not started?
  * You can check Togglefy's project here: https://github.com/users/azeveco/projects/2 to see the priorities, status and more
  * Or you can check the issues: https://github.com/azeveco/Togglefy/issues
* I have an idea of a feature! What do I do?
  * First things first, check if there's an issue about it first. If it does, put your comments there. If it doesn't, do the following:
    * Are you a developer that wants to develop it? Create a new issue, select the New Feature 🚀 template and fill out everything
    * Are you a developer or just an user that would like to request a new feature? Create a new issue, select the Feature Request 💡 template and fill out everything
* I have a bug report. Where can I... report it?
  * Create an issue, select the Bug Report 🪲 template and fill out everything

There's a PR and Issues Templates. We recommend you to follow these strictly to help everyone.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the togglefy project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/azeveco/togglefy/blob/master/CODE_OF_CONDUCT.md).
