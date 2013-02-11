require 'faker'

FactoryGirl.define do
  factory :bookmark do
    sequence(:name) {|n|
      Faker::Lorem.words(2).join(' ') + "_#{n}"
    }

    offset_seconds {Random.rand(360.0)}
    notes { { 'my favourite' => Faker::Lorem.paragraph} }

    association :creator, factory: :user

    association :audio_recording
  end
end