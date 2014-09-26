require 'tempfile'

module ActiveRecord
  module Acts
    module ShellscriptExecutable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def __define_execute_method(method, type, config_var)
          class_eval <<-EOV
            def #{method}(&block)
              script = #{config_var}[:#{method}][:script]
              command  = #{config_var}[:#{method}][:command]
              answer = ''
              __execute__(script, :#{type}, answer, command, block)
              block_given? ? nil : answer
            end
          EOV
        end

        def __configs_set(config_var, configuration, method)
          configurations = begin
                             class_variable_get(config_var)
                           rescue NameError
                             {}
                           end
          configurations[method] = configuration
          class_variable_set(config_var, configurations)
        end

        def acts_as_shellscript_executable(options = {})
          configuration = {
            method: :execute!, script: :script, shell: '/bin/sh'
          }.update(options)
          configuration[:command] = configuration[:shell]
          method = configuration[:method]

          __define_execute_method \
            method, :shell, :@@__shell_configs__
          __configs_set(:@@__shell_configs__, configuration, method)

          include ::ActiveRecord::Acts::ShellscriptExecutable::InstanceMethods
        end

        def acts_as_rubyscript_executable(options = {})
          configuration = {
            method: :ruby_execute!, script: :script, ruby: 'ruby'
          }.update(options)
          configuration[:command] = configuration[:ruby]
          method = configuration[:method]

          __define_execute_method \
            method, :ruby, :@@__ruby_configs__
          __configs_set(:@@__ruby_configs__, configuration, method)

          include ::ActiveRecord::Acts::ShellscriptExecutable::InstanceMethods
        end
      end

      module InstanceMethods
        private

        def __execute__(script, type, answer, command, block = nil)
          script = send script if script.is_a? Symbol

          path = Tempfile.open('') do |temp|
            temp.puts 'STDOUT.sync = true' if type == :ruby
            temp.puts script
            temp.path
          end

          retval = []
          IO.popen([*command, path], err: [:child, :out]).each do |io|
            if block
              block.call io
            else
              retval << io
            end
          end

          answer.replace retval.join
        end
      end
    end
  end
end
