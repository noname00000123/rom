require 'spec_helper'

describe Relation::Graph::Edge, '#target_aliases' do
  subject { object.target_aliases }

  let(:object) { described_class.new(name, left, right) }

  let(:name)            { mock('orders', :relationship => relationship, :to_sym => :orders) }
  let(:relationship)    { mock('relationship', :join_definition => join_definition) }
  let(:join_definition) { mock('join_definition') }

  let(:left)            { mock('users', :name => source_name, :aliases => source_aliases) }
  let(:source_name)     { mock('source_name') }
  let(:source_aliases)  { mock('source_aliases', :join => mock) }
  let(:right)           { mock('orders', :aliases => target_aliases) }
  let(:target_aliases)  { mock('target_aliases') }

  it { should be(target_aliases) }
end
