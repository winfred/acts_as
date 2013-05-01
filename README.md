# ActsAs

ActiveRecord extension for easy belongs_to composition delegation

## Installation

Add this line to your application's Gemfile:

    gem 'acts_as'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_as

## Usage

```ruby

# This pattern encourages foreign keys to be stored on the STI's root table for easy reads.
#
# table :users
#   name :string
#   clan_id :integer
#   profile_id :integer
#
class User
  include ActsAs
end

class Rebel < User
  acts_as :profile, class_name: 'RebelProfile', autosave: true
  acts_as :clan, prefix: %w( name ), with: %w( delegate_at_will ), autosave: true
end

# table :clans
#   name :string
#   strength :integer
#   cool :boolean
#
class Clan < ActiveRecord::Base
  has_many :rebels

  def delegate_at_will
    '10'
  end
end

# table :rebel_profiles
#   serial_data :string
#
class RebelProfile < ActiveRecord::Base
  has_one :rebel
end

```

Now a whole slew of methods related to ActiveRecord attributes are available for the fields being delegated to another table

    # Fully Proxied Setters/Getters
    rebel.strength = 10
    rebel.clan.strength = 20
    rebel.strength #=> 20

    # ActiveModel::Dirty helpers
    rebel.strength_was #=> 10

    # Shorthand for prefix-delegating specific fields
    rebel.clan_name #=> rebel.clan.name

    # Automagic boolean helpers
    rebel.cool? #=> rebel.clan.cool?

    # Any method you want
    rebel.delegate_at_will #=> '10'


## To be considered

How does the active record join hash-parsing stuff work? EX-

    Rebel.joins(:clan).where(clan: {cool: true)

Can we make this work for ruby-sql autojoins? Is that even a good idea?
    Rebel.where(cool: true) #auto-joins :clan

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
