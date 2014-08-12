module Roster
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
