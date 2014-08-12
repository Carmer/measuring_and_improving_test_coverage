module Roster
  class Groups
    def self.best_for(sizes, graph)
      sum_of_sizes = sizes.inject(0, :+)
      members_size = graph.members.size
      if sum_of_sizes != members_size
        raise ArgumentError, "Sizes #{sizes.inspect} sum to #{sum_of_sizes}, but there are #{members_size} members!"
      end

      graph.priority_queue.each_with_object(sizes.map { |size| new(size, graph) }) { |member, groups|
        groups.select(&:space_available?)
              .sort_by { |group| group.weight_with member }
              .first
              .add_member(member)
      }.map(&:to_a)
    end

    def initialize(size, graph)
      @size    = size
      @members = []
      @graph   = graph
    end

    def to_a
      members.dup
    end

    def weight_with(potential_member)
      total_weight + members.map { |member| graph.frequency member, potential_member }.inject(0, :+)
    end

    def space_available?
      members.size < size
    end

    def add_member(member)
      members << member
    end

    private

    attr_reader :size, :members, :graph

    def total_weight
      sum = 0
      members.map.with_index { |member1, index1|
        members.map.with_index { |member2, index2|
          sum += graph.frequency(member1, member2) if index2 < index1
        }
      }
      sum
    end
  end
end
