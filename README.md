# ActsAsShellscriptExecutable


    class Script < ActiveRecord::Base
      acts_as_shellscript_executable script: :script, stdout: :result
    end

### before:

| id  | name  | script | result |
| :------|:------ |:---------------|:-----|
| 1  | foo   | echo 'lalala' |  |


### execute:

    script = Script.find(1)
    script.execute!

### after:
    
| id  | name  | script | result |
| :------|:------ |:---------------|:-----|
| 1  | foo   | echo 'lalala' | lalala |

## Installation

Add this line to your application's Gemfile:

    gem 'acts_as_shellscript_executable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_as_shellscript_executable

## Contributing

1. Fork it ( http://github.com/<my-github-username>/acts_as_shellscript_executable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
