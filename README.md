# Tox

Tox is a high performance XML parser and renderer for Ruby based on [Ox](https://github.com/ohler55/ox). It's best explained using an example:

```ruby
require 'tox'

xml = %{
  <profile id="20">
    <name>Mike Ross</name>

    <friend title="Name Partner">
      <name>Harvey Specter</name>
      <tags>
        <tag>The Best</tag>
        <tag>Closer</tag>
      </tags>
    </friend>

    <friend title="Paralegal">
      <name>Rachel Zane</name>
      <age>30</age>
    </friend>
  </profile>
}

template = Tox.dsl do
  el(:profile, {
    id: at(:id),
    name: el(:name, text),
    friends: mel(:friend, {
      name: el(:name, text),
      age: el(:age, text),
      title: at(:title),
      tags: el(:tags, mel(:tag, text))
    })
  })
end

v = template.parse(xml)
# {
#   id: "20",
#   name: "Mike Ross",
#   friends: [
#     {
#       title: "Name Partner",
#       name: "Harvey Specter",
#       tags: ["The Best", "Closer"]
#     },
#     {
#       title: "Paralegal",
#       name: "Rachel Zane",
#       age: "30"
#     }
#   ]
# }

template.render(v)
# Outputs input xml
```

Read [Tox Tests](https://github.com/piesync/tox/tree/master/test/tox_test.rb) for more examples.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tox'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tox

## Development

Run tests using rake:

```
rake
```

Performance tests can be enabled using:

```
PERFORMANCE=true rake
```

## License

MIT
