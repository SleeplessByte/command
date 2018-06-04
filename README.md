# Command
[![Build Status: master](https://travis-ci.com/SleeplessByte/command.svg?branch=master)](https://travis-ci.com/SleeplessByte/command)
[![GitHub version](https://badge.fury.io/gh/SleeplessByte%2Fcommand.svg)](https://badge.fury.io/gh/SleeplessByte%2command) 
[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

Command adds the [Command Design Pattern](https://sourcemaking.com/design_patterns/command) to any `Class`. 

This was based on `Hanami::Interactor`, and started off as adding a direct `call` on the singleton class, before that
was added to Hanami's. After working with different interactors and command-style gems, including ways to organize
units for execution and without depending on other utility classes, `command` was born.

**Looking for a good name**: `command` is already taken on rubygems...,  so whatevs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'command', git: 'https://github.com/SleeplessByte/command.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install command, git: 'https://github.com/SleeplessByte/command.git'

## Usage

There are examples in the code and the tests. Here is a crude and basic example:

```Ruby
class FetchSecondInput
  include Command
  
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the 
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [SleeplessByte/commmand](https://github.com/SleeplessByte/command).
