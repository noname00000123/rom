require 'spec_helper'

describe ROM::Processor::Transproc do
  subject(:transproc) { ROM::Processor::Transproc.build(header) }

  let(:header) { ROM::Header.coerce(attributes) }

  context 'no mapping' do
    let(:attributes) { [[:name]] }
    let(:relation) { [ { name: 'Jane' }, { name: 'Joe' } ] }

    it 'returns tuples' do
      expect(transproc[relation]).to eql(relation)
    end
  end

  context 'mapping to object' do
    let(:header) { ROM::Header.coerce(attributes, model) }

    let(:model) do
      Class.new do
        include Virtus.value_object
        values { attribute :name }
      end
    end

    let(:attributes) { [[:name]] }
    let(:relation) { [ { name: 'Jane' }, { name: 'Joe' } ] }

    it 'returns tuples' do
      expect(transproc[relation]).to eql([
        model.new(name: 'Jane'), model.new(name: 'Joe')
      ])
    end
  end

  context 'renaming keys' do
    let(:attributes) { [[:name, from: 'name']] }
    let(:relation) { [ { 'name' => 'Jane' }, { 'name' => 'Joe' } ] }

    it 'returns tuples with renamed keys' do
      expect(transproc[relation]).to eql([{ name: 'Jane' }, { name: 'Joe' }])
    end
  end

  context 'mapping nested hash' do
    let(:relation) do
      [
        { 'name' => 'Jane', 'task' => { 'title' => 'Task One' } },
        { 'name' => 'Joe', 'task' => { 'title' => 'Task Two' } },
      ]
    end

    context 'when no mapping is needed' do
      let(:attributes) { [['name'], ['task', type: Hash, header: [[:title]]]] }

      it 'returns tuples' do
        expect(transproc[relation]).to eql(relation)
      end
    end

    context 'renaming keys' do
      context 'when only hash needs renaming' do
        let(:attributes) do
          [
            ['name'],
            [:task, from: 'task', type: Hash, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns tuples with key renamed in the nested hash' do
          expect(transproc[relation]).to eql([
            { 'name' => 'Jane', :task => { :title => 'Task One' } },
            { 'name' => 'Joe', :task => { :title => 'Task Two' } },
          ])
        end
      end

      context 'when all attributes need renaming' do
        let(:attributes) do
          [
            [:name, from: 'name'],
            [:task, from: 'task', type: Hash, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns tuples with key renamed in the nested hash' do
          expect(transproc[relation]).to eql([
            { :name => 'Jane', :task => { :title => 'Task One' } },
            { :name => 'Joe', :task => { :title => 'Task Two' } },
          ])
        end
      end
    end
  end

  context 'wrapping tuples' do
    let(:relation) do
      [
        { 'name' => 'Jane', 'title' => 'Task One' },
        { 'name' => 'Joe', 'title' => 'Task Two' },
      ]
    end

    context 'when no mapping is needed' do
      let(:attributes) do
          [
            ['name'],
            ['task', type: Hash, wrap: true, header: [['title']]]
          ]
      end

      it 'returns wrapped tuples' do
        expect(transproc[relation]).to eql([
          { 'name' => 'Jane', 'task' => { 'title' => 'Task One' } },
          { 'name' => 'Joe', 'task' => { 'title' => 'Task Two' } }
        ])
      end
    end

    context 'renaming keys' do
      context 'when only wrapped tuple requires renaming' do
        let(:attributes) do
          [
            ['name'],
            ['task', type: Hash, wrap: true, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns wrapped tuples with renamed keys' do
          expect(transproc[relation]).to eql([
            { 'name' => 'Jane', 'task' => { :title => 'Task One' } },
            { 'name' => 'Joe', 'task' => { :title => 'Task Two' } }
          ])
        end
      end

      context 'when all attributes require renaming' do
        let(:attributes) do
          [
            [:name, from: 'name'],
            [:task, type: Hash, wrap: true, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns wrapped tuples with all keys renamed' do
          expect(transproc[relation]).to eql([
            { :name => 'Jane', :task => { :title => 'Task One' } },
            { :name => 'Joe', :task => { :title => 'Task Two' } }
          ])
        end
      end
    end
  end

  context 'grouping tuples' do
    let(:relation) do
      [
        { 'name' => 'Jane', 'title' => 'Task One' },
        { 'name' => 'Jane', 'title' => 'Task Two' },
        { 'name' => 'Joe', 'title' => 'Task One' },
      ]
    end

    context 'when no mapping is needed' do
      let(:attributes) do
        [
          ['name'],
          ['tasks', type: Array, group: true, header: [['title']]]
        ]
      end

      it 'returns wrapped tuples with all keys renamed' do
        expect(transproc[relation]).to eql([
          { 'name' => 'Jane',
            'tasks' => [{ 'title' => 'Task One' }, { 'title' => 'Task Two' }] },
          { 'name' => 'Joe',
            'tasks' => [{ 'title' => 'Task One' }] }
        ])
      end
    end

    context 'renaming keys' do
      context 'when only grouped tuple requires renaming' do
        let(:attributes) do
          [
            ['name'],
            ['tasks', type: Array, group: true, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns grouped tuples with renamed keys' do
          expect(transproc[relation]).to eql([
            { 'name' => 'Jane',
              'tasks' => [{ :title => 'Task One' }, { :title => 'Task Two' }] },
            { 'name' => 'Joe',
              'tasks' => [{ :title => 'Task One' }] }
          ])
        end
      end

      context 'when all attributes require renaming' do
        let(:attributes) do
          [
            [:name, from: 'name'],
            [:tasks, type: Array, group: true, header: [[:title, from: 'title']]]
          ]
        end

        it 'returns grouped tuples with all keys renamed' do
          expect(transproc[relation]).to eql([
            { :name => 'Jane',
              :tasks => [{ :title => 'Task One' }, { :title => 'Task Two' }] },
            { :name => 'Joe',
              :tasks => [{ :title => 'Task One' }] }
          ])
        end
      end
    end
  end
end
