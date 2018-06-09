# Command
[![Build Status: master](https://travis-ci.com/SleeplessByte/command.svg?branch=master)](https://travis-ci.com/SleeplessByte/command)
[![Gem Version](https://badge.fury.io/rb/commande.svg)](https://badge.fury.io/rb/commande)
[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

Command adds the [Command Design Pattern](https://sourcemaking.com/design_patterns/command) to any `Class`. 

This was based on `Hanami::Interactor`, and started off as adding a direct `call` on the singleton class, before that
was added to Hanami's. After working with different interactors and command-style gems, including ways to organize
units for execution and without depending on other utility classes, `command` was born.

Because [`command`](https://rubygems.org/gems/command) has been taken on rubygems (but not updated since 2013), and
[`commando`](https://rubygems.org/gems/commando) has been taken (but not updated since 2009) and the Dutch `opdracht` is
probably not pronounceable by most people using this, I've decided to register this on the French 
[`commande`](https://rubygems.org/gems/commande).

However, if you are using this directly from GitHub, you can continue using it as is, without renaming, as long as you
change the Gemfile line to `require: 'command'`.

```Ruby
# Gemfile
gem 'commande', require: 'command'
```

## Installation

Add this line to your application's Gemfile:

```Ruby
gem 'commande'
```

or alternatively if you would like to refer to commande as `Command`:

```Ruby
gem 'commande', require: 'command'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install commande

## Usage

There are examples in the code and the tests. Here is a crude and basic example:

```Ruby
class FetchSecondInput
  include Commande
  
  output :fetched
  
  def call(*args)
    # always define call
    self.fetched = args.second 
  end
  
  def valid?(*args)
    args.length == 2
  end
  
  private
  
  attr_accessor :fetched
end

result = FetchSecondInput.call(42, 'gem')
result.successful? # => true
result.fetched # => 'gem'

result = FetchSecondInput.call(42, 'gem', 'three is a crowd')
result.successful? # => false
result.fetched # => nil
```

## Testing

There are some `Minitest` assertions included in this library.

```Ruby
require 'commande/minitest'
```
| Assert | Refute | |
|:---:|:---:|:---:|
| `assert_successful(command_result)` | `refute_successful` | passes if the command is successful?
| `assert_valid(command, *args_for_valid)` | `refute_valid` | passes if the command is valid
| `assert_with_error(expected, actual)` | `refute_with_error` | passes if the command has a certain error message

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the 
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [SleeplessByte/commmand](https://github.com/SleeplessByte/command).
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Shrine::ConfigurableStorage project’s codebases, issue trackers, chat rooms and mailing
lists is expected to follow the [code of conduct](https://github.com/SleeplessByte/command/blob/master/CODE_OF_CONDUCT.md).
