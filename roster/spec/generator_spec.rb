require 'roster'

module Roster
  describe 'Graph' do
    it 'knows its members' do
      graph = Graph.new %w[a b]
      expect(graph.members).to eq %w[a b]
    end

    describe 'frequency' do
      let(:graph) { Graph.new %w[a b c] }
      before { graph.add_group(%w[a b]).add_group(%w[a c]) }

      it 'increments for each time the two paired together' do
        expect(graph.frequency('a', 'b')).to eq 1
        expect(graph.frequency('a', 'c')).to eq 1
        graph.add_group %w[a b]
        expect(graph.frequency('a', 'b')).to eq 2
        expect(graph.frequency('a', 'c')).to eq 1
      end

      it 'returns the same values regardless of order' do
        expect(graph.frequency('b', 'a')).to eq 1
        expect(graph.frequency('a', 'b')).to eq 1
      end

      it 'raises an error when asking the members frequency with itself' do
        expect { graph.frequency 'a', 'a' }.to raise_error ArgumentError
      end

      it 'raises an error when asking for frequencies of non-members' do
        expect { graph.frequency 'a', 'z' }.to raise_error ArgumentError
        expect { graph.frequency 'z', 'a' }.to raise_error ArgumentError
      end
    end

    describe 'total_weight' do
      let(:graph) { Graph.new %w[a b c] }
      before { graph.add_group(%w[a b]).add_group(%w[a c]) }

      it 'returns the sum of the frequencies' do
        expect(graph.total_weight 'a').to eq 2
        expect(graph.total_weight 'b').to eq 1
        expect(graph.total_weight 'c').to eq 1
      end

      it 'raises an error total_weight for members of a group who are not in the graph\'s members' do
        expect { graph.total_weight 'z' }.to raise_error ArgumentError
      end
    end

    describe 'standard_deviation' do
      it 'returns the standard deviation of the frequencies' do
        graph = Graph.new(%w[a b c d]).add_group(%w[a b]).add_group(%w[a b]).add_group(%w[b c]).add_group(%w[c d])
        expect(graph.standard_deviation 'b').to be_within(0.01).of(0.96) # (2, 1, 0, 0)
        expect(graph.standard_deviation 'c').to be_within(0.01).of(0.57) # (0, 1, 1, 0)
        expect(graph.standard_deviation 'a').to be_within(0.01).of(1.00) # (2, 0, 0, 0)
        expect(graph.standard_deviation 'd').to be_within(0.01).of(0.50) # (1, 0, 0, 0)
      end
    end

    describe 'priority_queue' do
      it 'orders higher weights over lower weights' do
        graph = Graph.new(%w[a b c]).add_group(%w[a b]).add_group(%w[a b]).add_group(%w[b c])
        expect(graph.priority_queue).to eq %w[b a c] # b=(a,a,c)=3, a=(b,b)=2, c=(b)=1
      end

      it 'breaks weight ties with lower standard deviation of frequencies' do
        # b | weight: (a, a,c) = 3
        # c | weight: (b, d  ) = 2, low standard dev
        # a | weight: (b, b  ) = 2, high standard dev
        # d | weight: (c     ) = 1
        graph = Graph.new(%w[a b c d]).add_group(%w[a b]).add_group(%w[a b]).add_group(%w[b c]).add_group(%w[c d])
        expect(graph.priority_queue).to eq %w[b c a d]

        # swap a and c
        graph = Graph.new(%w[a b c d]).add_group(%w[c b]).add_group(%w[c b]).add_group(%w[b a]).add_group(%w[a d])
        expect(graph.priority_queue).to eq %w[b a c d]
      end
    end

    describe 'best_groups_for(group_sizes)' do
      it 'raises an error if the group sizes dont add up to the number of members' do
        graph = Graph.new %w[a b c]
        [ [1], [1, 1], [2, 2], [4], [] ].each do |group_sizes|
          expect { Groups.best_for(group_sizes, graph) }.to raise_error ArgumentError
        end
        [ [1, 1, 1], [2, 1], [1, 2], [3] ].each do |group_sizes|
          Groups.best_for(group_sizes, graph)
        end
      end

      it 'applies members to groups according to the priority queue' do
        graph = Graph.new(%w[a b c d]).add_group(%w[a b]).add_group(%w[b c]).add_group(%w[a d]).add_group(%w[a d])
        expect(Groups.best_for [2, 2], graph).to eq [%w[a c], %w[b d]]

        # same thing but rotate frequencies
        graph = Graph.new(%w[a b c d]).add_group(%w[b c]).add_group(%w[c d]).add_group(%w[b a]).add_group(%w[b a])
        expect(Groups.best_for [2, 2], graph).to eq [%w[b d], %w[c a]]
      end

      it 'does not overfill a group' do
        groups = Groups.best_for [1, 2], Graph.new(%w[a b c])
        expect(groups).to eq [['a'], ['b', 'c']]
      end
    end
  end
end
