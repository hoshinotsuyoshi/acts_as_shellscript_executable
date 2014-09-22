require 'acts_as_shellscript_executable/version'
require 'acts_as_shellscript_executable/active_record/' \
          'acts/shellscript_executable'

module ActsAsShellscriptExecutable
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'acts_as_shellscript_executable.insert_into_active_record' do
        ActiveSupport.on_load :active_record do
          ActsAsShellscriptExecutable::Railtie.insert
        end
      end
    end
  end

  class Railtie
    def self.insert
      if defined?(ActiveRecord)
        require 'active_record'
        ActiveRecord::Base.include ActiveRecord::Acts::ShellscriptExecutable
      end
    end
  end
end

ActsAsShellscriptExecutable::Railtie.insert
