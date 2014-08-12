require 'stringio'

module Roster
  class Cohort
    @all = {}
    class << self
      def get(name)
        @all.fetch name
      end

      def add(name, &block)
        @all[name] = new(name, &block)
      end
    end

    attr_accessor :name, :projects, :student_names, :stderr
    def initialize(name, options={})
      self.name          = name
      self.student_names = []
      self.projects      = {}
      self.stderr        = options.fetch :stderr, StringIO.new
      yield self if block_given?
    end

    def add_project(name, groups)
      projects[name] = groups.map { |group|
        group.map { |student_name|
          student_name = student_name.intern
          unless student_names.include? student_name
            stderr.puts "Unknown student #{student_name.inspect} for Cohort #{name.inspect}"
          end
          name
        }
        group.map(&:intern)
      }
    end

    def set_students(names)
      @student_names = names.map(&:intern)
    end
  end
end
