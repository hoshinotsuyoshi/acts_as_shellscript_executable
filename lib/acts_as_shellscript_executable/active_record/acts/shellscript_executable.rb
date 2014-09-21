module ActiveRecord
  module Acts
    module ShellscriptExecutable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_shellscript_executable(options = {})
          @@configuration = { script: :script, stdout: nil }
          @@configuration.update(options) if options.is_a?(Hash)

          class_eval <<-EOV
            include ::ActiveRecord::Acts::ShellscriptExecutable::InstanceMethods

          EOV
        end

        def configuration
          @@configuration
        end
      end

      module InstanceMethods
        def execute!
          script = configuration[:script]
          stdout = configuration[:stdout]
          if configuration[:fork]
            fork { execute(script, stdout) }
            # for test
            Process.wait if ENV['test']
          else
            execute(script, stdout)
          end
        end

        private
        def configuration
          self.class.configuration
        end

        def execute(script, stdout)
          case script
          when Symbol
            retval = %x(#{send script})
          when String
            retval = %x(#{script})
          end
          if stdout && respond_to?("#{stdout}=".to_sym)
            send("#{stdout}=".to_sym, retval)
          end
          save!
        end
      end
    end
  end
end
