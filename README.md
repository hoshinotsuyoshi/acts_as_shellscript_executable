# ActsAsShellscriptExecutable

[![travis-batch](https://travis-ci.org/hoshinotsuyoshi/acts_as_shellscript_executable.svg?branch=master)](https://travis-ci.org/hoshinotsuyoshi/acts_as_shellscript_executable)
[![Coverage Status](https://coveralls.io/repos/hoshinotsuyoshi/acts_as_shellscript_executable/badge.png)](https://coveralls.io/r/hoshinotsuyoshi/acts_as_shellscript_executable)
[![Code Climate](https://codeclimate.com/github/hoshinotsuyoshi/acts_as_shellscript_executable/badges/gpa.svg)](https://codeclimate.com/github/hoshinotsuyoshi/acts_as_shellscript_executable)


### before:

| id  | name  | script        | result |
| :---|:----- |:--------------|:-------|
| 1   | foo   | echo 'lalala' |        |

### execute:

```ruby
class Script < ActiveRecord::Base
  acts_as_shellscript_executable script: :script
end
```

```ruby
script = Script.find(1)
script.result = script.execute!
script.save!
```

### after:

| id  | name  | script        | result |
| :---|:----- |:--------------|:-------|
| 1   | foo   | echo 'lalala' | lalala |

## #execute!

* `#execute!(no args)`
    * returns scripts stdout of whole of the shellscript

* `#execute!(block)`
    * returns `nil`, yields the shellscript's stdout st each line(splited by `\n`)

## Options of `.acts_as_shellscript_executable`

* `script:` (default: `:script`)
    * if `Symbol`, the same name column's value will be evaluated as shellscript
    * if `String`, the string will be evaluated as shellscript

* `method:` (default: `execute!`)
    * the execute method's name

## Installation

Add this line to your application's Gemfile:

    gem 'acts_as_shellscript_executable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_as_shellscript_executable

## Contributing

1. Fork it ( http://github.com/hoshinotsuyoshi/acts_as_shellscript_executable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
