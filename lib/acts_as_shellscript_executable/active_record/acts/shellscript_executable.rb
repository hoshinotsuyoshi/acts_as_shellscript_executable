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
          retval = %x(#{self.send script})
          self.result = retval
          self.save!
        end

        private
        def configuration
          self.class.configuration
        end
      end
    end
  end
end