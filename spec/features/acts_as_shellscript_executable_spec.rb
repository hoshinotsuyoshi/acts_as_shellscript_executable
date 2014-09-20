require 'spec_helper'

describe ActsAsShellscriptExecutable do
  before do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
    ActiveRecord::Schema.verbose = false
    ActiveRecord::Base.connection.schema_cache.clear!
    ActiveRecord::Schema.define(version: 1) do
      create_table :scripts do |t|
        t.column :script, :string
        t.column :result, :string
      end
    end

    class Script < ActiveRecord::Base
      acts_as_shellscript_executable script: :script
    end
  end

  it do
    script = Script.create
    script.script = 'echo "lalala"'
    expect{script.execute!}.to \
      change{script.result}.from(nil).to("lalala\n")
  end
end
