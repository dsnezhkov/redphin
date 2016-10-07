Rails.application.config.logger = ActiveSupport::TaggedLogging.new(Logger.new('customlog.log'))
Rails.application.config.log_tags = [Proc.new {Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')}]