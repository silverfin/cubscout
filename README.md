[![Build Status](https://travis-ci.org/GetSilverfin/cubscout.svg?branch=master)](https://travis-ci.org/GetSilverfin/cubscout)

# Cubscout

Unofficial Ruby client for the [Helpscout API V2](https://developer.helpscout.com/mailbox-api/). 

Cubscout is heavily inspired by [girlscout](https://github.com/omise/girlscout), another unofficial Ruby Client for Helpscout API V1.

## Installation

Add `gem 'cubscout'` to your application's Gemfile, and then run `bundle` to install.

Or install it yourself as `gem install cubscout`.

## Configuration

To get started, you need to configure the client with your App ID and App secret. If you are using Rails, you should add the following to a new initializer file in `config/initializers/helpscout.rb`.

```ruby
require 'cubscout'

Cubscout::Config.client_id = 'YOUR_APP_ID'
Cubscout::Config.client_secret = 'YOUR_APP_SECRET'
```

Note: Your App ID and App Secret are secret credentials, and you should treat them like passwords. You can create an App in your Helpscout account, under Your Profile > My Apps.

## Usage

Cubscout mimics Active Record's querying pattern.

### Conversations

List of conversations:

```ruby
# all possible conversations available
# WARNING: this will create a lot of HTTP requests. You probably want some filtering.
conversations = Cubscout::Conversation.all

# conversations with filters
conversations = Cubscout::Conversation.all(tag: 'red,blue', status: 'active')

# Cubscout::Conversation.all returns a Cubscout::List object. You can iterate
# over it's Cubscout::Conversation items like this:
conversations.each { |conversation| puts conversation.mailbox_id }

# or you can also get some metadata information. For example if you only care
# about the number of items, you can query the first page only and find out how
# many elements exist in total:
Cubscout::Conversation.all(page: 1, tag: 'red,blue', status: 'active').total_size
```

Check Helpscout's API documentation for [all supported filters](https://developer.helpscout.com/mailbox-api/endpoints/conversations/list/#url-parameters) and [attributes returned](https://developer.helpscout.com/mailbox-api/endpoints/conversations/list/#response).

All filter keys must be passed in the same format as described in the documentation, and all values must be strings or integers. Attribute keys must be symbols:

```ruby
conversations = Cubscout::Conversation.all(page: 1,
                                           assigned_to: 1234,
                                           sortField: "customerName",
                                           modifiedSince: (DateTime.now - 4).to_time.utc.iso8601,
                                           tag: "red,blue")
```

Get one conversation by id:

```ruby
# find conversation by id:
conversation = Cubscout::Conversation.find(12345)

# Cubscout::Conversation.find returns one Cubscout::Conversation object, from
# which attributes can be read. attributes can be read as snake case or camel case.
puts conversation.mailbox_id
puts conversation.mailboxId
```

Check Helpscout's API documentation for all [attributes returned](https://developer.helpscout.com/mailbox-api/endpoints/conversations/get/#response)

Update a conversation:

```ruby
conversation = Cubscout::Conversation.find(12345)
conversation.update(op: "replace", path: "/subject", value: "New conversation subject")

# or
Cubscout::Conversation.update(12345, op: "replace", path: "/subject", value: "New conversation subject")
```

Multiple combinations of `:op`, `:path` and `:value` are permitted, check Helpscout's API documentation for [all the possibilities](https://developer.helpscout.com/mailbox-api/endpoints/conversations/update/#valid-paths-and-operations).

### Threads

In Helpscout's lingo, threads are all the items following a conversation: notes, replies, assignment to users, etc.

Get the threads for a conversation:

```ruby
# by conversation id:
threads = Cubscout::Conversation.threads(conversation_id)

# from a conversation object:
also_threads = Cubscout::Conversation.find(id).threads
```

Check Helpscout's API documentation for all [attributes returned](https://developer.helpscout.com/mailbox-api/endpoints/conversations/threads/list/#response)

Create a note on a conversation:

```ruby
# by conversation id:
Cubscout::Conversation.create_note(conversation_id, attributes)

# from a conversation object:
Cubscout::Conversation.find(id).create_note(attributes)

# of the attributes hash, :text is the only attribute required
Cubscout::Conversation.create_note(12345, text: "A new note by me")

# this endpoint doesn't return any body
```

Check Helpscout's API documentation for [all supported attributes](https://developer.helpscout.com/mailbox-api/endpoints/conversations/threads/note/#request-fields)

## Users

List of users:

```ruby
# all possible users available
# WARNING: this will create multiple HTTP requests. You may want some filtering.
users = Cubscout::User.all

# users with filters
users = Cubscout::User.all(mailbox: 12345)

# Cubscout::User.all returns a Cubscout::List object. You can iterate over
# it's Cubscout::User items like this:
users.each { |user| puts user.first_name }

# or you can also get some metadata information. For example if you only care
# about the number of items, you can query the first page only and find out how
# many elements exist in total:
Cubscout::User.all(page: 1, mailbox: 12345).total_size
```

Check Helpscout's API documentation for [all supported filters](https://developer.helpscout.com/mailbox-api/endpoints/users/list/#url-parameters) and [attributes returned](https://developer.helpscout.com/mailbox-api/endpoints/users/list/#response).

Get one user by id:

```ruby
# find user by id:
user = Cubscout::User.find(12345)

# Cubscout::User.find returns one Cubscout::User object, from
# which attributes can be read. attributes can be read as snake case or camel case.
puts user.firstName
puts user.first_name
```

Check Helpscout's API documentation for all [attributes returned](https://developer.helpscout.com/mailbox-api/endpoints/users/get/#response)

Get a conversation's assigned user:

```ruby
user = Cubscout::Conversation.find(conversation_id).assignee
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GetSilverfin/cubscout. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cubscout project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/GetSilverfin/cubscout/blob/master/CODE_OF_CONDUCT.md).
