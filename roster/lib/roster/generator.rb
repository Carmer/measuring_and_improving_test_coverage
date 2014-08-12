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


  class Graph
    attr_reader :members

    def initialize(members)
      @members = members
      @frequencies = Hash.new { |h, k| raise "No member #{k} in #{members.inspect}" }
      members.each { |member| @frequencies[member] = members.each_with_object(Hash.new) { |m, h| h[m] = 0 } }
      @total_weights = members.each_with_object(Hash.new) { |member, weights| weights[member] = 0 }
    end

    def add_group(group)
      group = group.select { |member| member? member }
      group.each do |member1|
        group.each do |member2|
          next if member1 == member2
          frequencies[member1][member2] += 1
          total_weights[member1] += 1
        end
      end
      self
    end

    def frequency(member1, member2)
      raise ArgumentError, "Not valid to ask the frequency of #{member1.inspect} with itself" if member1 == member2
      raise ArgumentError, "#{member1.inspect} is not a member" unless member? member1
      raise ArgumentError, "#{member2.inspect} is not a member" unless member? member2
      frequencies[member1][member2]
    end

    def total_weight(member)
      raise ArgumentError, "#{member.inspect} is not a member" unless member? member
      total_weights[member]
    end

    def standard_deviation(member)
      numbers = frequencies[member].values
      length  = numbers.length.to_f
      mean    = numbers.inject(0, :+) / length
      sum     = numbers.inject(0) { |sum, num| sum + (num - mean)**2 }
      Math.sqrt(sum / (length - 1))
    end

    def priority_queue
      members.sort_by { |member| [-total_weight(member), standard_deviation(member)] }
    end

    def member?(member)
      members.include? member
    end

    private
    attr_accessor :frequencies, :total_weights
  end
end
