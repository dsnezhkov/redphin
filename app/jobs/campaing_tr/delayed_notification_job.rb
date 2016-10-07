module CampaignTr
  class DelayedNotificationJob < ActiveJob::Base
    queue_as :default

    def perform
      Rails.logger.info "#{self.class.name}: Crono job is being performed ... "
      Mark.all.each do |mark|
        if not mark.stat.nil? and mark.stat.visit > 0 and mark.postnotify_flag == false
          shows=0
          submissions=0
          valid_submission=mark.stat.valid_submission
          stimes=[]
          utimes=[]

          mark.visits.where(resource: 'show').each do |v|
            shows = shows + 1
            stimes << v.time.utc.in_time_zone("Central Time (US & Canada)").strftime("%m-%d-%Y %H:%M")
          end
          mark.visits.where(resource: 'authenticate').each do |v|
            submissons = submissions + 1
            utimes << v.time.utc.in_time_zone("Central Time (US & Canada)").strftime("%m-%d-%Y %H:%M")
          end

          Rails.logger.info "#{self.class.name}: Scheduling notification to  #{mark.display_name} at: #{mark.email_addr}"
          CampaignTr::Phishcampaign.notify_delayed_visits_stats(mark, shows, submissions, valid_submission, stimes, utimes ).deliver_now
        end
      end
    end
  end
end