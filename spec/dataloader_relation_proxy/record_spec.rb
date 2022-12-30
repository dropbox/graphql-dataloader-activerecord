# frozen_string_literal: true

RSpec.describe DataloaderRelationProxy::Record do
  let(:alice) { User.find_by_name('alice') }
  let(:bob) { User.find_by_name('bob') }

  describe 'belongs_to' do
    it 'loads multiple relations in one query' do
      story1 = alice.stories.first
      story2 = bob.stories.first

      database_queries = 0
      callback = ->(*) { database_queries += 1 }
      ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
        authors = GraphQL::Dataloader.with_dataloading do |dataloader|
          proxy1 = DataloaderRelationProxy.for(Story).new(story1, dataloader)
          proxy2 = DataloaderRelationProxy.for(Story).new(story2, dataloader)

          dataloader.append_job { proxy1.author }
          dataloader.append_job { proxy2.author }

          [proxy1.author.name, proxy2.author.name]
        end

        expect(authors).to eq(%w[alice bob])
      end

      expect(database_queries).to eq(1)
    end

    it 'supports chaining' do
      story1 = alice.stories.first
      story2 = bob.stories.first

      database_queries = 0
      callback = ->(*) { database_queries += 1 }
      ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
        plans = GraphQL::Dataloader.with_dataloading do |dataloader|
          proxy1 = DataloaderRelationProxy.for(Story).new(story1, dataloader)
          proxy2 = DataloaderRelationProxy.for(Story).new(story2, dataloader)

          dataloader.append_job { proxy1.author.plan }
          dataloader.append_job { proxy2.author.plan }

          [proxy1.author.plan.name, proxy2.author.plan.name]
        end

        expect(plans).to eq(%w[trial personal])
      end

      expect(database_queries).to eq(2)
    end
  end

  describe 'has_many' do
    it 'loads a collection-like proxy object' do
      stories = GraphQL::Dataloader.with_dataloading do |dataloader|
        proxy = DataloaderRelationProxy.for(User).new(alice, dataloader)

        dataloader.append_job { proxy.stories }
        proxy.stories.map(&:text)
      end

      expect(stories).to eq([
        '2022 Year in Review',
        "Alice's Second Story"
      ])
    end

    it 'supports chaining' do
      publications = GraphQL::Dataloader.with_dataloading do |dataloader|
        proxy1 = DataloaderRelationProxy.for(User).new(alice, dataloader)
        proxy2 = DataloaderRelationProxy.for(User).new(bob, dataloader)

        dataloader.append_job { proxy1.stories.first.publication }
        dataloader.append_job { proxy2.stories.first.publication }

        [
          proxy1.stories.first.publication.name,
          proxy2.stories.first.publication.name
        ]
      end

      expect(publications).to eq([
        'Fresno Bee',
        'Miami Herald'
      ])
    end
  end
end
