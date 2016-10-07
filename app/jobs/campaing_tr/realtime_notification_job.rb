class RealtimeNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(mark_id)
    Rails.logger.info "#{self.class.name}: I'm performing job for mark: #{mark_id}"
    return unless Mark.exists?(mark_id)

    mark = Mark.find(mark_id)
    Rails.logger.info "#{self.class.name}: Scheduling notification to  #{mark.display_name} at: #{mark.email_addr}"

    # deliver later
    #Phishcampaign.hook_campaign_tr_post_note(mark).deliver_later!(delay_until: 1.minute.from_now)

    # deliver now
    #Phishcampaign.hook_campaign_tr_post_note(mark).deliver_now

  end
end
