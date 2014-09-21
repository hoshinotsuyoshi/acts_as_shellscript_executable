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
        expect{script.execute!}.to_not \
          change{script.result}
      end
    end

    context 'given option {script: :script, stdout: :result}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: :script, stdout: :result
        end
      end

      it do
        script = Script.create
        script.script = 'echo "lalala"'
        expect{script.execute!}.to \
          change{script.result}.from(nil).to("lalala\n")
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
          pid = Process.pid
          script.script = 'echo $PPID' # this $PPID is equal to $$
          expect{script.execute!}.to \
            change{script.result}.from(nil).to("#{Process.pid}\n")
        end
      end

      context '[forking] given option {script: :script, stdout: :result, fork: true}' do
        before do
          class Script < ActiveRecord::Base
            acts_as_shellscript_executable script: :script, stdout: :result, fork: true
          end

          @script = Script.create
          @script.script = 'echo $PPID' # when fork, this $PPID is not equal to $$
          @script.execute!
        end

        it do
          # reset object because of fork
          sleep 1
          @script = Script.find @script.id
          expect(@script.result).not_to equal nil
          expect(@script.result).not_to eq("#{Process.pid}\n")
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
        expect{script.execute!}.to \
          change{script.result}.from(nil).to("lalala\n")
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
        expect{script.execute!}.to \
          change{script.result}.from(nil).to("1\n")
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
        expect{script.execute!}.to \
          change{script.result}.from(nil).to("1\n2\n")
      end
    end

    context 'given option {script: "echo 1\nsleep 1\necho 2", stdout: :result, fork: true}' do
      before do
        ENV['test_wait_child'] = 'false'
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable script: "echo 1\nsleep 1\necho 2", stdout: :result, fork: true
        end
      end

      it do
        script = Script.create
        script.script  = 'echo "hehehe"'
        script.execute!
        watcher = []
        @time = Time.now
        while Time.now - @time < 2
          watcher << Script.find(1).result.to_s
          sleep 0.2
        end
        expect(watcher.uniq).to be_include "1\n"
        expect(watcher.uniq).to be_include "1\n2\n"
      end
    end

    context 'given option {method: :awesome_execute!, script: :script, stdout: :result}' do
      before do
        class Script < ActiveRecord::Base
          acts_as_shellscript_executable method: :awesome_execute!, script: :script, stdout: :result
        end
      end

      it do
        script = Script.create
        script.script = 'echo "lalala"'
        expect{script.awesome_execute!}.to \
          change{script.result}.from(nil).to("lalala\n")
      end
    end
  end
end
