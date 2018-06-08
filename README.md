# Unixium

The Unixium library provides the following useful functions for Unix systems:

* Access to a Unix-based system's user, shadow and group databases
* Obtain the Terminal size in rows and columns
* Lots more to come!

**Note**: This library is still being developed and will likely undergo various major changes over the coming months until we reach a stable release.  Please use as a reference only at this point.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  unixium:
    github: fgimian/unixium.cr
```

## Usage

```crystal
require "unixium"

# Obtain all users on the system
Unixium::Users.all.each do |user|
  puts "Username: #{user.name}"
  puts "Password: #{user.passwd}"
  puts "UID: #{user.uid}"
  puts "GID: #{user.gid}"
  puts "GECOS: #{user.gecos}"
  puts "Home Directory: #{user.dir}"
  puts "Shell: #{user.shell}"
end

# Obtain an individual user by their username or uid
fots = Unixium::Users.get("fots")
fots = Unixium::Users.get(501)

# Obtain all groups on the system
Unixium::Groups.all.each do |group|
  puts "Name: #{group.name}"
  puts "Password: #{group.passwd}"
  puts "GID: #{group.gid}"
  puts "Members: #{group.members}"
end

# Obtain an group user by their name or gid
staff = Unixium::Groups.get("staff")
staff = Unixium::Groups.get(20)

# TODO: Add instructions on shadow usage when it's implemented

# Obtain the Terminal size
termsize = Unixium::Terminal.size
puts "Your terminal has #{termsize.rows} rows and #{termsize.columns} columns"
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/fgimian/unixium.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [fgimian](https://github.com/fgimian) Fotis Gimian - creator, maintainer
