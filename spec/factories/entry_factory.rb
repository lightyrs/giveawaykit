FactoryGirl.define do

  factory :entry do

    name { Faker::Name.name }

    sequence :email do |n|
      "#{n}#{Faker::Internet.email}"
    end

    is_viral { [true, false][rand(2)] }

    wall_post_count { rand(10) }

    request_count { rand(10) }

    entry_count { rand(20) }

    convert_count { rand(3) }
  end
end
