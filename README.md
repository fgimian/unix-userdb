# unix_userdb

The unix_userdb library provides access to a Unix-based system's user, shadow and group databases for Crystal.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  unix_userdb:
    github: fgimian/unix_userdb.cr
```

## Usage

```crystal
require "unix_userdb"

# Obtain all users on the system
Users.all.each do |user|
  puts "Username: #{user[:name]}"
  puts "Password: #{user[:passwd]}"
  puts "UID: #{user[:uid]}"
  puts "GID: #{user[:gid]}"
  puts "GECOS: #{user[:gecos]}"
  puts "Home Directory: #{user[:dir]}"
  puts "Shell: #{user[:shell]}"
end

# Obtain an individual user by their username or uid
fots = Users.get("fots")
fots = Users.get(501)

# Obtain all groups on the system
Groups.all.each do |group|
  puts "Name: #{group[:name]}"
  puts "Password: #{group[:passwd]}"
  puts "GID: #{group[:gid]}"
  puts "Members: #{group[:members]}"
end

# Obtain an group user by their name or gid
staff = Groups.get("staff")
staff = Groups.get(20)

# TODO: Add instructions on shadow usage when it's implemented
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/fgimian/unix_userdb.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [fgimian](https://github.com/fgimian) Fotis Gimian - creator, maintainer
