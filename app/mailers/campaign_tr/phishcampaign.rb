class CampaignTr::Phishcampaign < ActionMailer::Base


  # MJML experiment
  def mail_campaign_mj(mark)
    @mark = mark

    @greeting = "To: #{@mark.display_name} "
    email_with_name = %("#{@mark.display_name} " <#{@mark.email_addr}>)

    mail ({to: email_with_name,
         from:  configatron.campaigns.trcampaign.email.message.from,
         subject: configatron.campaigns.trcampaign.email.message.subject,
         'Importance' => 'High', 'X-Priority' => '1',
         template_path: configatron.campaigns.trcampaign.email.message.template.path,
         template_name: configatron.campaigns.trcampaign.email.message.template.name}) do |format|
		format.mjml { render [configatron.campaigns.trcampaign.email.message.template.path,
				configatron.campaigns.trcampaign.email.message.template.name].join('/') }
		format.text { render [configatron.campaigns.trcampaign.email.message.template.path,
                                configatron.campaigns.trcampaign.email.message.template.name].join('/') }
	end

    @mark.complete_flag = true
    @mark.save
  end

  def mail_campaign(mark)

    @mark = mark

    @greeting = "To: #{@mark.display_name} "
    email_with_name = %("#{@mark.display_name} " <#{@mark.email_addr}>)
    #attachments.inline[configatron.campaigns.trcampaign.email.images.logo.first.name] =
    #    File.read(configatron.campaigns.trcampaign.email.images.logo.first.location)
    attachments.inline[configatron.campaigns.trcampaign.email.images.logo.second.name] =
        File.read(configatron.campaigns.trcampaign.email.images.logo.second.location)

    mail to: email_with_name,
         from:  configatron.campaigns.trcampaign.email.message.from,
         subject: configatron.campaigns.trcampaign.email.message.subject,
         'Importance' => 'High', 'X-Priority' => '1',
         template_path: configatron.campaigns.trcampaign.email.message.template.path,
         template_name: configatron.campaigns.trcampaign.email.message.template.name

    @mark.complete_flag = true
    @mark.save

  end

  def notify_delayed_visits_stats(mark, visits, submissions, valid_submission, visit_times, submission_times)

    @mark = mark
    @visits=visits
    @visit_times=visit_times
    @submissions=submissions
    @valid_submission=valid_submission
    @submission_times=submission_times
    @submission_hash= Hash.new

    # Do we have visitors with submissions
    submission_data=@mark.visits.where(resource: 'submit').pluck('data').first
    @submission_hash=JSON.parse(submission_data) if submission_data

    mail to: mark.email_addr,
         from:  configatron.campaigns.trcampaign.post.email.message.from,
         subject:  configatron.campaigns.trcampaign.post.email.message.subject,
         'Importance' => 'High', 'X-Priority' => '1',
         template_path: configatron.campaigns.trcampaign.post.email.template.path,
         template_name: configatron.campaigns.trcampaign.post.email.template.name

    @mark.postnotify_flag = true
    @mark.save

  end
  def notify_each_visitation(mark)

    message = %Q/ #{mark.email_addr} has visited phishing site  as part of a phishing campaign /

    mail(to: mark.email_addr,
         from:  configatron.campaigns.trcampaign.email.message.from,
         subject: configatron.campaigns.trcampaign.email.message.subject,
         'Importance' => 'High', 'X-Priority' => '1') do |format|

      format.text { render text: message  }
    end
  end
  def notify_each_submisson(mark)

    message = %Q/ Dear #{mark.email_addr}.
        You have submitted your company credentials on a phishing site.
       /

    mail(to: mark.email_addr,
         from:  configatron.campaigns.trcampaign.email.message.from,
         subject: configatron.campaigns.trcampaign.email.message.subject,
         'Importance' => 'High', 'X-Priority' => '1') do |format|

      format.text { render text: message  }
    end
  end


end
