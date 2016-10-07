Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files  = false
  config.assets.js_compressor = :uglifier
  config.assets.compile = true
  #config.assets.compile = false #DXS
  config.assets.digest = true
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false

  # Production
  config.action_mailer.delivery_method = :sendmail
  
  #config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true

  #config.action_mailer.smtp_settings = {
  #    :address              => "smtp.gmail.com",
  #    :port                 => 587,
  #    :user_name            => "someone",
  #    :domain               => "example.com",
  #    :password             => "*****",
  #    :authentication       => "plain",
  #    :enable_starttls_auto => true
  #}

end
