require 'spec_helper'

describe ActiveRecord::Base do
  describe '.acts_as_shellscript_executable' do
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

    describe 'given option parallel' do
      context 'given option {script: :script, parallel: false}' do
        before do
          class Script < ActiveRecord::Base
            acts_as_shellscript_executable script: :script, parallel: false
          end
        end

        it do
          script = Script.create
          script.script = 'echo $PPID'
          expect(script.execute!).to eq "#{Process.pid}\n"
        end
      end

      context 'given option {script: :script, parallel: true}' do
        before do
          class Script < ActiveRecord::Base
            acts_as_shellscript_executable script: :script, parallel: true
          end
        end

        it do
          script = Script.create
          script.script = "sleep 1\necho $PPID"
          result = script.execute!

          expect(result).to eq('')
          sleep 1.5
          expect(result).to eq("#{Process.pid}\n")
        end
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

    context 'given option {script: "echo 1\nsleep 1\necho 2" parallel: true}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable \
            script: "echo 1\nsleep 1\necho 2", parallel: true
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
          expect(watcher).to eq ["1\n", '', "2\n"]
        end
      end
    end

    context 'given option {method: :awesome!}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable \
            method: :awesome!, script: "echo 1\nsleep 1\necho 2", parallel: true
        end
      end

      describe 'block given' do
        it do
          script = Script.create
          watcher = []

          retval = script.awesome! do |each_line_result|
            watcher << each_line_result
          end

          sleep 2

          expect(retval).to be_nil
          expect(watcher).to eq ["1\n", '', "2\n"]
        end
      end
    end
  end
end
