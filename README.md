# docbase-ruby

[![Build Status](https://travis-ci.org/krayinc/docbase-ruby.svg?branch=master)](https://travis-ci.org/krayinc/docbase-ruby)

DocBase API Client, written in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'docbase'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install docbase

## Usage

```ruby
client = DocBase::Client.new(access_token: 'your_access_token', team: 'your_team')
```

or

```ruby
ENV['DOCBASE_ACCESS_TOKEN'] = 'your_access_token'

client = DocBase::Client.new(team: 'your_team')
```

### teams

```ruby
client.teams.body
# => [{ domain: 'kray', name: 'kray' }, { domain: 'danny', name: 'danny' }]
```
### tags

```ruby
client.tags.body
# => [{ name: 'ruby' }, { name: 'rails' }]
```

### groups

```ruby
client.groups.body
# => [{ id: 1, name: 'DocBase' }, { id: 2, name: 'kray' }]
```

### posts

#### create

```ruby
params = {
  title: 'memo title',
  body: 'memo body',
  draft: false,
  tags: ['rails', 'ruby'],
  scope: 'group',
  groups: [1],
  notice: true,
}

client.create_posts(params).body
# => {
#   id: 1,
#   title: 'memo title',
#   body: 'memo body',
#   draft: false,
#   url: 'https://kray.docbase.io/posts/1',
#   created_at: '2015-03-10T12:01:54+09:00',
#   tags: [
#     { name: 'rails' },
#     { name: 'ruby' },
#   ],
#   scope: 'group',
#   groups: [
#     { name: 'DocBase' }
#   ],
#   user: {
#     id: 1,
#     name: 'danny'
#   },
# }
```

### switch team

```ruby
client = DocBase::Client.new(access_token: 'your_access_token', team: 'kray')
client.tags.body
# => [{ name: 'ruby' }, { name: 'rails' }]

client.team = 'danny'
client.tags.body
# => [{ name: 'javascript' }, { name: 'react' }]
```

## API Document

[https://help.docbase.io/posts/45703](https://help.docbase.io/posts/45703)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
