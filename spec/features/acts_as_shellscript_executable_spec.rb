require 'spec_helper'
require 'tmpdir'

describe ActiveRecord::Base do
  describe '.acts_as_shellscript_executable' do
    def db_setup!
      # use not-in-memory-sqlite-db. because of fork
      db_dir = Dir.mktmpdir('db')
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "#{db_dir}/db.sqlite3")
      ActiveRecord::Schema.verbose = false
      ActiveRecord::Base.connection.schema_cache.clear!
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
      ENV['test_wait_child'] = 'true'
    end

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

    describe 'given option fork' do
      context 'given option {script: :script, stdout: :result, fork: false}' do
        before do
          class Script < ActiveRecord::Base
            acts_as_shellscript_executable script: :script, stdout: :result, fork: false
          end
        end

        it do
          script = Script.create
          script.script = 'echo $PPID' # this $PPID is equal to $$
          expect(script.execute!).to eq "#{Process.pid}\n"
        end
      end

      context '[forking] given option {script: :script, stdout: :result, fork: true}' do
        before do
          class Script < ActiveRecord::Base
            acts_as_shellscript_executable script: :script, stdout: :result, fork: true
          end
        end

        it do
          script = Script.create
          script.script = "sleep 1\necho $PPID" # when fork, this $PPID is not equal to $$
          result = script.execute!

          expect(result).to eq('')
          sleep 1.5
          expect(result).to eq("#{Process.pid}\n")
        end
      end
    end

    context 'given option {script: :script2, stdout: :result}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: :script2, stdout: :result
        end
      end

      it do
        script = Script.create
        script.script  = 'echo "hehehe"'
        script.script2 = 'echo "lalala"'
        expect(script.execute!).to eq "lalala\n"
      end
    end

    context 'given option {script: "echo 1;", stdout: :result}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: "echo 1;", stdout: :result
        end
      end

      it do
        script = Script.create
        script.script  = 'echo "hehehe"'
        expect(script.execute!).to eq "1\n"
      end
    end

    context 'given option {script: "echo 1\necho 2", stdout: :result}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: "echo 1\necho 2", stdout: :result
        end
      end

      it do
        script = Script.create
        script.script  = 'echo "hehehe"'
        result = script.execute!
        expect(result).to eq "1\n2\n"
      end
    end

    context 'given option {script: "echo 1\nsleep 1\necho 2", stdout: :result, fork: true}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: "echo 1\nsleep 1\necho 2", stdout: :result, fork: true
        end
      end

      describe 'block given' do
        it do
          script = Script.create
          watcher = []

          retval = script.execute! do |each_line_result|
            watcher << each_line_result
          end

          sleep 2

          expect(retval).to be_nil
          expect(watcher).to eq ["1\n", "", "2\n"]
        end
      end
    end

    context 'given option {method: :awesome_execute!, script: "echo 1\nsleep 1\necho 2", stdout: :result, fork: true}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable method: :awesome_execute!, script: "echo 1\nsleep 1\necho 2", stdout: :result, fork: true
        end
      end

      describe 'block given' do
        it do
          script = Script.create
          watcher = []

          retval = script.awesome_execute! do |each_line_result|
            watcher << each_line_result
          end

          sleep 2

          expect(retval).to be_nil
          expect(watcher).to eq ["1\n", "", "2\n"]
        end
      end
    end
  end
end
