Rails.application.config.assets.enabled = true
Rails.application.config.assets.paths << "#{Rails.root}/vendor/assets/fonts"
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/fonts"
Rails.application.config.assets.precompile += %w(application.js sg.js jquery.js welcome.js tab.js application.css welcome.css tab.css widgets.css *.svg *.eot *.woff *.ttf)