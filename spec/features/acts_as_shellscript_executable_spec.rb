require 'spec_helper'

describe ActiveRecord::Base do
  def db_setup!
    ActiveRecord::Base.establish_connection \
      adapter: 'sqlite3', database: ':memory:'
    ActiveRecord::Schema.verbose = false
    ActiveRecord::Base.connection.schema_cache.clear!
    db_schema_define!
  end

  def db_schema_define!
    ActiveRecord::Schema.define(version: 1) do
      create_table :scripts do |t|
        t.column :script,  :string
        t.column :script2, :string
        t.column :result,  :string
      end
    end
  end

  before do
    db_setup!
  end

  describe '.acts_as_shellscript_executable' do
    context 'given option {script: :script}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: :script
        end
      end

      it do
        script = Script.create
        script.script = 'echo "lalala"'
        expect(script.execute!).to eq "lalala\n"
      end
    end

    context 'given option { script: :script2 }' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: :script2
        end
      end

      it do
        script = Script.create
        script.script  = 'echo "hehehe"'
        script.script2 = 'echo "lalala"'
        expect(script.execute!).to eq "lalala\n"
      end
    end

    context 'given option { script: "echo 1;" }' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: 'echo 1;'
        end
      end

      it do
        script = Script.create
        script.script  = 'echo "hehehe"'
        expect(script.execute!).to eq "1\n"
      end
    end

    context 'given option {script: "echo 1\necho 2"}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: "echo 1\necho 2"
        end
      end

      it do
        script = Script.create
        script.script  = 'echo "hehehe"'
        result = script.execute!
        expect(result).to eq "1\n2\n"
      end
    end

    context 'given option {script: "echo 1\necho 2"}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: "echo 1\necho 2"
        end
      end

      describe 'block given' do
        it do
          script = Script.create
          watcher = []

          retval = script.execute! do |each_line_result|
            watcher << each_line_result
          end

          expect(retval).to be_nil
          expect(watcher).to eq ["1\n", "2\n"]
        end
      end
    end

    context 'given 2 options' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable \
            script: "echo 1\necho 2"
          acts_as_shellscript_executable \
            script: "echo 3\necho 4", method: :awesome!
        end
      end

      it do
        script = Script.create
        result = script.execute!
        awesome_result = script.awesome!

        expect(result).to eq "1\n2\n"
        expect(awesome_result).to eq "3\n4\n"
      end
    end
  end

  describe '.acts_as_rubyscript_executable' do
    context 'given option {script: :script}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_rubyscript_executable script: :script
        end
      end

      it do
        script = Script.create
        script.script = 'puts "lalala"'
        expect(script.ruby_execute!).to eq "lalala\n"
      end
    end

    context 'given option {script: "puts 1\nputs 2"}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_rubyscript_executable script: "puts 1\nputs 2"
        end
      end

      describe 'block given' do
        it do
          script = Script.create
          watcher = []

          retval = script.ruby_execute! do |each_line_result|
            watcher << each_line_result
          end

          expect(retval).to be_nil
          expect(watcher).to eq ["1\n", "2\n"]
        end
      end
    end

    context 'given option {ruby: ["ruby", "-c"]}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_rubyscript_executable \
            script: "puts 1\nputs 2", ruby: ['ruby', '-c']
        end
      end

      describe 'block given' do
        it do
          script = Script.create
          watcher = []

          retval = script.ruby_execute! do |each_line_result|
            watcher << each_line_result
          end

          expect(retval).to be_nil
          expect(watcher).to eq ["Syntax OK"]
        end
      end
    end

    context 'given 2 options' do
      before do
        class Script < ActiveRecord::Base
          acts_as_rubyscript_executable \
            script: "puts 1\nputs 2"
          acts_as_rubyscript_executable \
            script: "puts 3\nputs 4", method: :awesome!
        end
      end

      it do
        script = Script.create
        result = script.ruby_execute!
        awesome_result = script.awesome!

        expect(result).to eq "1\n2\n"
        expect(awesome_result).to eq "3\n4\n"
      end
    end
  end
end
