require 'spec_helper'
require 'support/active_record'

class User < ActiveRecord::Base
  include ActsAs
end

class RebelProfile < ActiveRecord::Base
  has_one :rebel
end

class ImperialProfile < ActiveRecord::Base
  has_one :imperial
end

class Clan < ActiveRecord::Base
  has_many :rebels

  def delegate_at_will
    '10'
  end
end

class XWing < ActiveRecord::Base
  belongs_to :rebel
end

class Rebel < User
  acts_as :profile, class_name: 'RebelProfile'
  acts_as :clan, prefix: %w( name ), with: %w( delegate_at_will )
end

class Imperial < User
  acts_as :profile, class_name: 'ImperialProfile'
end

describe ActsAs do

  let(:rebel) { Rebel.create(name: "Leia", clan_name: "Organa") }
  subject { rebel }

  it 'raises exception for non-ActiveRecord::Base extensions' do
    expect {
      class MyObject; include ActsAs; end
    }.to raise_error(ActsAs::ActiveRecordOnly)
  end

  describe 'automatic association building' do
    describe 'when acted model has already been created' do
      it 'retrieves it from the database' do
        rebel.profile.serial_data = '123'
        rebel.save
        rebel.reload.profile.serial_data.should == '123'
      end
    end

    describe 'when acted model has not been created' do
      it 'creates it empty automatically' do
        expect {
          rebel.profile.should be_persisted
        }.to change(RebelProfile, :count).by(1)
      end
    end

    describe 'when host model is not persisted' do
      let(:rebel) { Rebel.new(name: "Bail", clan_name: "Oranga") }

      it 'does not persist the acted model' do
        expect {
          rebel.profile.should_not be_persisted
        }.to_not change(RebelProfile, :count)
      end
    end
  end

  describe 'with' do
    it { should respond_to(:delegate_at_will) }
    its(:delegate_at_will) { should == rebel.clan.delegate_at_will  }
    it 'actually calls the method on the associated object' do
      rebel.clan.should_receive(:delegate_at_will).once
      rebel.delegate_at_will
    end
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

  describe '#previous_changes' do
    it 'should account for acted models' do
      rebel.strength = 12
      rebel.name = 'bob'
      rebel.save
      rebel.previous_changes.should include('strength')
    end
  end

  describe '#update_column' do
    it 'should pass through to acted models' do
      rebel.update_column :strength, 23
      rebel.strength.should == 23
    end
  end

  describe 'automagic .where hash syntax helpers' do
    it 'should auto-expand acted hash attributes' do
      Rebel.where(strength: rebel.strength).should include(rebel)
      Rebel.where(strength: rebel.strength, name: 'Jimbo').should_not include(rebel)
      expect {
        Rebel.where('strength = ?', 12).any?
      }.to raise_error(ActiveRecord::StatementInvalid)

      Rebel.where(name: rebel.name).should include(rebel)
    end

    it 'should auto-expand acted attributes that are nested as well' do
      pending 'support nested attributes'
      xwing = XWing.create!(rebel: rebel)
      XWing.joins(rebel: :clan).where(rebel: {strength: rebel.strength}).should include(xwing)
    end
  end
end