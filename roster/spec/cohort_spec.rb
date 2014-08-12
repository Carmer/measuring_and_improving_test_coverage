require 'roster'

module Roster
  describe Cohort do
    it 'keeps track of added cohorts' do
      cohort = Cohort.add 'c1'
      expect(Cohort.get 'c1').to equal cohort
    end

    it 'gives the cohort its name and yields it to the block' do
      block_called = false
      Cohort.add 'the name' do |c|
        block_called = true
        expect(c.name).to eq 'the name'
      end
      expect(block_called).to eq true
    end

    it 'tracks student names as symbols' do
      cohort = Cohort.new 'c1' do |c|
        c.set_students %w[a b]
      end
      expect(cohort.student_names).to eq [:a, :b]
    end

    it 'defaults student names to an empty array' do
      expect(Cohort.new('name').student_names).to eq []
    end

    it 'tracks projects' do
      cohort = Cohort.new 'c1' do |c|
        c.set_students %w[a b c d e f]
        c.add_project 'p1', [['a', 'b']]
        c.add_project 'p2', [['c', 'd'], ['e', 'f']]
      end
      expect(cohort.projects['p1']).to eq [[:a, :b]]
      expect(cohort.projects['p2']).to eq [[:c, :d], [:e, :f]]
    end

    it 'warns about students on projects who are not in the cohort (as it might be a misspelling)' do
      stderr = StringIO.new
      cohort = Cohort.new 'c1', stderr: stderr do |c|
        c.set_students ['a']
        c.add_project 'name', [['not-a']]
      end
      expect(stderr.string).to include 'not-a'
    end
  end
end
