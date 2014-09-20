require 'spec_helper'

describe ActiveRecord::Base do
  describe '.acts_as_shellscript_executable' do
    before do
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
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
  end
end
