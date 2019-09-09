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

### users

```ruby
client.users(q: 'name')
client.users(q: 'name', page: 2)
client.users(q: 'name', page: 1, per_page: 100)
client.users(q: 'name', page: 1, per_page: 100, include_user_groups: true)
```

### tags

```ruby
client.tags.body
# => [{ name: 'ruby' }, { name: 'rails' }]
```

### groups

#### List

```ruby
client.groups.body
```

#### Show

```ruby
client.group(1).body
```

#### Create

```ruby
params = {
  name: 'group',
  description: 'Important group.',
}

client.create_group(params)
```

#### Add users to group

```ruby
params = {
  group_id: 1,
  user_ids: [10, 11, 12]
}

client.add_users_to_group(params)
```

#### Remove users from group

```ruby
params = {
  group_id: 1,
  user_ids: [10, 11, 12]
}

client.remove_users_from_group(params)
```

### posts

#### Search

```ruby
client.posts(q: 'body')
client.posts(q: 'body', page: 2)
client.posts(q: 'body', page: 1, per_page: 100)
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

#### Archive

```ruby
client.archive_post(1)
```

#### Unarchive

```ruby
client.unarchive_post(1)
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

#### Delete

```ruby
client.delete_comment(1)
```

### attachments

#### Create

```ruby
client.upload('./test.jpg')
client.upload(['./test.jpg', './README.md'])
```

### switch team

```ruby
client = DocBase::Client.new(access_token: 'your_access_token', team: 'kray')
client.tags.body
# => [{ name: 'ruby' }, { name: 'rails' }]

client.team = 'danny'
clinet.access_token = 'danny_team_access_token'
client.tags.body
# => [{ name: 'javascript' }, { name: 'react' }]
```

## API Document

[https://help.docbase.io/posts/45703](https://help.docbase.io/posts/45703)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
