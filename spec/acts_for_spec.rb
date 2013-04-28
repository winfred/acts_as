require 'spec_helper'
require 'support/active_record'

class User < ActiveRecord::Base
  include ActsAs
end

class RebelProfile < ActiveRecord::Base
  belongs_to :rebel
end

class ImperialProfile < ActiveRecord::Base
  belongs_to :imperial
end

class Clan < ActiveRecord::Base
  has_many :rebels

  def delegate_at_will
    '10'
  end
end

class Rebel < User
  has_one :profile, class_name: 'RebelProfile', autosave: true
  belongs_to :clan, autosave: true
  acts_as :profile
  acts_as :clan, prefix: %w( name ), whitelist: %w( delegate_at_will )
end

class Imperial < User
  has_one :profile, class_name: 'ImperialProfile'
  acts_as :profile
end



describe ActsAs do

  let(:rebel) { Rebel.create(name: "Leia", clan_name: "Organa") }
  subject { rebel }

  describe 'whitelist' do
    it { should respond_to(:delegate_at_will) }
    its(:delegate_at_will) { should == rebel.clan.delegate_at_will  }
  end

  describe 'proxied getters and setters' do
    it { should respond_to(:strength) }
    its(:strength) { should == rebel.clan.strength }
    it { should respond_to(:strength=) }
    it 'defines setters as well' do
      expect { rebel.strength += 50 }.to change{ rebel.clan.strength }.by(50)
    end

    context 'for imperial class' do
      subject { Imperial.create(name: "Darth Vader", analog_data: "CHhhawww phheerrrrr") }
      it { should respond_to(:analog_data) }
    end
  end

  describe 'prefix fields' do
    it { should respond_to(:clan_name) }
    its(:clan_name) { should == rebel.clan.name }
  end

  describe 'dirty helpers' do
    before { rebel.strength = 10 }
    it { should respond_to(:strength_was) }
    its(:strength_was) { should equal(rebel.clan.strength_was) }
    its(:strength_was) { should equal(50) }
    its(:strength) { should equal(rebel.clan.strength) }
    its(:strength) { should equal(10) }
  end

  describe 'boolean helpers' do
    it { should respond_to(:cool?)}
    specify { rebel.should_not be_cool }
  end
end