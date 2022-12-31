# frozen_string_literal: true

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# ActiveRecord::Base.logger = Logger.new($stdout)

class User < ActiveRecord::Base
  has_many :teams, through: :memberships
  has_many :stories, foreign_key: :author_id
  belongs_to :plan
end

class Team < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
end

class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :team
end

class Story < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  belongs_to :publication
end

class Plan < ActiveRecord::Base
end

class Publication < ActiveRecord::Base
  has_many :stories
end

ActiveRecord::Schema.define(version: 1) do
  create_table :users do |t|
    t.text :name
    t.integer :plan_id
  end

  create_table :teams do |t|
    t.text :name
  end

  create_table :memberships do |t|
    t.integer :user_id, null: false
    t.integer :team_id, null: false
  end

  create_table :publications do |t|
    t.text :name
  end

  create_table :stories do |t|
    t.integer :author_id, null: false
    t.integer :publication_id, null: false
    t.text :text
  end

  create_table :plans do |t|
    t.text :name
  end
end

trial_plan = Plan.create(name: 'trial')
personal_plan = Plan.create(name: 'personal')
alice = User.create(name: 'alice', plan: trial_plan)
bob = User.create(name: 'bob', plan: personal_plan)
fresno_bee = Publication.create(name: 'Fresno Bee')
miami_herald = Publication.create(name: 'Miami Herald')
Story.create(author: alice, text: '2022 Year in Review', publication: fresno_bee)
Story.create(author: alice, text: "Alice's Second Story", publication: fresno_bee)
Story.create(author: bob, text: 'Spec Author Not Creative', publication: miami_herald)
Story.create(author: bob, text: "Bob's Second Story", publication: miami_herald)
