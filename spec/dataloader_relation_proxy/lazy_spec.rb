# frozen_string_literal: true

RSpec.describe DataloaderRelationProxy::Lazy do
  describe '#object' do
    it 'loads multiple relations in one query' do
      query_string = <<-GRAPHQL
        query {
          stories {
            author {
              name
            }
          }
        }
      GRAPHQL
      database_queries = 0
      callback = ->(*) { database_queries += 1 }
      ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
        TestImplementationSchema.execute(query_string)
      end

      # + 1 query for the stories
      # + 1 query for the authors (needed for authors hop and authorization)
      # + 1 query for publications (arbitrarily loaded by the authorization)
      # ---
      # = 3
      expect(database_queries).to eq(3)
    end
  end
end
