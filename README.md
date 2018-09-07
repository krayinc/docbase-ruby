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

#### Search

```ruby
client.create_posts(q: 'body')
```

#### Show

```ruby
client.post(1)
```

#### Create

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

client.create_post(params)
```

#### Update

```ruby
params = {
  id: 1,
  title: 'memo title',
  body: 'memo body',
  draft: false,
  tags: ['rails', 'ruby'],
  scope: 'group',
  groups: [1],
  notice: true,
}

client.update_post(params)
```

#### Delete

```ruby
client.delete_post(1)
```

### Comment

#### Create

```ruby
params = {
  post_id: 1,
  body: 'GJ!!',
  notice: true,
}

client.create_comment(params)
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
