[![Version     ](https://img.shields.io/gem/v/mosca.svg)](https://rubygems.org/gems/mosca)
[![Dependency Status](https://gemnasium.com/ionia-corporation/mosca.svg)](https://gemnasium.com/ionia-corporation/mosca)
[![Code Climate](https://codeclimate.com/github/ionia-corporation/mosca.png)](https://codeclimate.com/github/ionia-corporation/mosca)
[![Build Status](https://img.shields.io/travis/ionia-corporation/mosca/master.svg)](https://travis-ci.org/ionia-corporation/mosca)
[![Coverage    ](https://img.shields.io/codeclimate/coverage/github/ionia-corporation/mosca.svg)](https://codeclimate.com/github/ionia-corporation/mosca)


# Mosca

A simple client for mqtt communication

## Installation

Add this line to your application's Gemfile:

    gem 'mosca'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mosca
    
## Usage

### Configure

You can configure the default timeout for response, and default mqtt broker.

```ruby
  Mosca::Client.default_timeout = 10 # 10 seconds
  Mosca::Client.default_broker = "test.mosquitto.org"
```

### New instance

```ruby
  client = Mosca::Client.new user: "username", pass: "password", topic_in: "readings", topic_out: "commands", topic_base: "/device/"
```

### Publishing

#### Single message

```ruby
  client.publish "restart" # will be sent to topic /device/commands
```

#### Message with response

```ruby
  response = client.publish "some_command", response: true, topic_in: "responses" # will publish and wait for a response on the /device/responses topic
  
```

### Getting messages

```ruby
  puts client.get # will wait up to Mosca.default_timeout (default 5) seconds. will return if no response comes.
  
  puts client.get timeout: 2, topic_in: "another_topic" # will wait up to 2 seconds for a response on the another_topic topic.
```

###TO DO

Readme not complete yet

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
