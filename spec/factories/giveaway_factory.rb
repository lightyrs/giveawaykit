include ActionDispatch::TestProcess

FactoryGirl.define do

  factory :giveaway do

    facebook_page_id { FacebookPage.all.sample.id }

    title { Faker::Movie.title }

    description { Faker::HTMLIpsum.p(12) }

    prize { Faker::Product.product_name }

    custom_fb_tab_name { Faker::Name.name }

    image { fixture_file_upload "#{Rails.root}/spec/support/obama-dog.jpg", 'image/jpeg' }

    feed_image { fixture_file_upload "#{Rails.root}/spec/support/obama-dog.jpg", 'image/jpeg' }

    terms_url { Faker::Internet.http_url }

    terms_text { Faker::HipsterIpsum.paragraphs }

    autoshow_share_dialog { [1, 0][rand(2)] }

    allow_multi_entries { [1, 0][rand(2)] }

    email_required { [1, 0][rand(2)] }

    bonus_value { generate(:integer) }

    active { false }

    trait :scheduled do

      start_date { generate(:datetime) }

      end_date { generate(:datetime) }
    end

    trait :active do

      active { true }

      start_date { [1.year.ago, 1.month.ago, 2.weeks.ago, 1.week.ago, 6.days.ago, 4.days.ago, 1.day.ago][rand(7)] }

      end_date { [(Time.now + 1.week), (Time.now + 1.month), (Time.now + 6.months), (Time.now + 1.year), nil][rand(5)] }
    end

    trait :completed do

      active { false }

      start_date { [1.year.ago, 1.month.ago, 2.weeks.ago, 1.week.ago, 6.days.ago, 4.days.ago, 1.day.ago][rand(7)] }

      end_date { start_date + 18.hours }
    end
  end
end
