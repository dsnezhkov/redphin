### Campaigns we will run for the customer,
# You can add more than one campaign
# Setup each config vars in the campaign block

configatron.campaigns.trcampaign do |trcampaign|

  # Name of the campaign, affects how we find templates
  trcampaign.name='campaign_tr'

  #::::  Phishing Email Campaign Delivery
  # Email Message SECTION
  # This section is to configure some of the email massage presentation and construction
  trcampaign.email do |email|

    # First LOGO. Repeat for as many logos you want to place in email message.
    # Be mindful to work with Phish Controller to attach them properly in the email message
    # Logo of the sender company (upper tab)
    email.images.logo.first.name = 'logo1.png'
    # Size of the logo in email
    email.images.logo.first.size = '100x100'
    # logo file on disk
    email.images.logo.first.location =
        Configatron::Delayed.new {
          "#{Rails.root}/app/assets/images/emails/#{trcampaign.name}/#{email.images.logo.first.name}" }

    email.images.logo.second.name = 'logo2.png'
    email.images.logo.second.size = '50x50'
    email.images.logo.second.location =
        Configatron::Delayed.new {
          "#{Rails.root}/app/assets/images/emails/#{trcampaign.name}/#{email.images.logo.first.name}" }


    # How this email message is delivered
    # From:
    email.message.from = 'Some One <information@crainesbusiness.com>'
    # Subject:
    email.message.subject = 'Subject of Interest'
    # Which email template we are using for this campaign, and where to find it
    email.message.template.path = ['phishemail',trcampaign.name].join('/')
    email.message.template.name = 'content'


    # How are we building links to phisher stager web site
    # http://<addr>:<port>/<controller>/..id../<action>
    # Note: 'id' is the notification_tag which wil be filled in by the phishmailer
    # We do not manage SSL on the app server. This is done through nginx
    email.links.hserver.addr = 'crainesbusiness.com'
    email.links.hserver.port  = '80'
    email.links.hserver.controller  = 'trnotifications'
    email.links.hserver.action  = 'show'

  end

  # Web visit SECTION
  # This describes what the mark does on the phishing stager server, and how we respond to mark;s actions
  # This is also per campaign, obviously

  # Website itself
  trcampaign.web do |web|

    # How we find top-level phsihing company image(s). Same logic as 'email': name, location, size to
    # properly format the page. You may also work with semantic layout in the individual views
    web.images.logo.first.name = 'logo1.png'
    web.images.logo.first.location = ['web', trcampaign.name, web.images.logo.first.name].join('/')
    web.images.logo.first.size = '100x100'

    web.layout.window.title = 'Title Of Webpage'
    web.layout.headers.first.content = 'Content Header'
    web.layout.footers.copy.content = 'Copyright'

  end

  # How we respond to mark's visit actions, how and who we notify.
  # Example: Do we continue to accept visits/submission from the same mark or implement threshold logic.
  trcampaign.web.visits  do |visits|
    # Do we implement locks on visits to the submission form?
    visits.lock = false
    # if we do -  what is the number of visits allowed per mark
    visits.lock_threshold  = 9999

    # Do we make realtime awareness of the steps users take?
    # REALTIME:
    # When user visit how many visits does it take to notify the party
    visits.realtime.respond  = false
    visits.realtime.email.threshold  = 1
    # TODO: BATCH check implement
    # Do we make delayed/scheduled awareness of the steps users take?
    # When user visit how many visits does it take to notify the party
    visits.delayed.respond  = false
    visits.delayed.email.threshold  = 1
  end

  # How we respond to mark's submissions, not visits.
  trcampaign.web.submissions  do |submissions|
    # Do we implement locks on submissions?

    submissions.lock = true
    # if we do - what is the number of submissions allowed
    # Example: When user submits data how many submits does it take to notify parties of an attempt
    submissions.lock_threshold  = 1

    # Do we want to affect locks of page visits to prevent showing the submission form after submission is already made?
    submissions.lock_visits_after_submission = false

    # Do we make realtime awareness of the submissions?
    # REALTIME:
    # When user submits, how many submits  does it take to notify the party, correlate with lock_threashold to make sense.
    submissions.realtime.respond  = false
    submissions.realtime.email.threshold  = 1

    # TODO: Add checks for BATCH notification.
    # TODO: Currently we implement batch notification by default at the end of the day.
    # Do we make delayed/schtruled awareness of the submissions users take?
    # When user submits, how many submits does it take to notify the party
    submissions.delayed.respond  = false
    submissions.delayed.email.threshold  = 1
  end


  ## When we send post-phishing notification, how do we do it?
  trcampaign.post.email.delivery.every.day = 1.day
  trcampaign.post.email.delivery.at.time =  '22:30'
  trcampaign.post.email.message.from = 'Security Notification <notification@example.com>'
  trcampaign.post.email.message.subject = 'Social Engineering Test Results'
  # Where we find email template that will be sent?
  trcampaign.post.email.template.path = ['postnotification',trcampaign.name].join('/')
  trcampaign.post.email.template.name = 'content'


end
# redirect for all campaigns for this customer
configatron.web.rdr = 'http://example.com'
