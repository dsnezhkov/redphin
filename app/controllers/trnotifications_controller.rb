class TrnotificationsController < ApplicationController

  before_action :set_mark, only: [:show, :submit, :status, :status_locked_submissions, :enotify]


  layout 'campaign_tr'
  helper 'campaign_tr/phishcampaign'

  helper_method :submitted?

  def submitted?
    @submitted
  end


  ### Actions
  def status
    @visits = @mark.visits
    logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|'))  {
      logger.info 'Status Shown' }
    #render :status_fail_logon
    render :status_thank_you
  end


  def status_locked_submissions
    @visits = @mark.visits
    logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|'))  {
      logger.info 'Status Shown' }
    render :status_locked_submissions
  end

  # when visits to /controller/ without the notification code
  def index
    add_visit('Visited index, without proper code')
    logger.tagged('unknown', [controller_name, action_name].join('|')) {
      logger.warn 'Visited without proper notification code' }
    render nothing: true
  end

  # when email message is viewed and the client fetches from the server (via beacon)
  def enotify
    add_visit
    logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
      logger.info 'Email Viewed' }
  end


  # when mark visits his own notification tag. Should be default
  def show

      logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
        logger.info 'Show Page' }

      if not @mark.stat.nil? and  @mark.stat.visit_lock

        logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
          logger.info 'Denied visit: locked threshold breach by visit_lock' }
        render :status_locked_visits
      end

      # when no more visits is desired - do not show content, but record visits
      if configatron.campaigns.trcampaign.web.visits.lock
        logger.info 'visits lock is ON'

        unless @mark.stat.visit < configatron.campaigns.trcampaign.web.visits.lock_threshold

          mark_stat=@mark.stat
          mark_stat.update(visit_lock: true)
          mark_stat.save

          logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
            logger.info 'Denied visit: locked threshold breach by visit threshold' }
            render :status_locked_visits
        end
      end

      add_visit
      notify_visit_realtime?
      #notify_visit_delayed?

  end

  #when mark authenticates to the service
  def submit

    logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
      logger.info 'Data Submission Attempt' }

    respond_to do |format|
      if params[:id]
        if configatron.campaigns.trcampaign.web.submissions.lock
          unless @mark.stat.submission  < configatron.campaigns.trcampaign.web.submissions.lock_threshold
            logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
              logger.info 'Denied submission: locked threshold breach.' }
              format.html { redirect_to controller: controller_name, action: :status_locked_submissions, id: params[:id] }
          end
        end


        # Do not save meta-parameters in visits
        scrub = [ :utf8, :authenticity_token, :controller, :action ]
        params.except!( *scrub )

        add_visit(nil,params)
        mark_stat=@mark.stat
        mark_stat.update(submission: mark_stat.submission + 1)
        mark_stat.save

        logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
          logger.info 'Input Recorded: ' + params.to_a.join('|') }

        if configatron.campaigns.trcampaign.web.submissions.lock_visits_after_submission

          # immediate lock rendering of form
          logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
            logger.info 'Locking visits after submission threshold ' }
            @mark.stat.submission_lock = true
            @mark.stat.visit_lock = true
            @mark.stat.save
        end
        notify_submission_realtime?
        format.html { redirect_to controller: controller_name, action: :status, id:  params[:id] }
      else
        add_visit('Authentication: Proper Id not passed',nil)
        logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
          logger.warn 'No Notification Tag in Submission :' + params.to_s }
        format.html { redirect_to @mark}
      end
    end

  end


  private

  def set_mark
    @mark = Mark.from_param(params[:id])
    if @mark.nil?
      logger.tagged('Unknown Tag', [controller_name, action_name].join('|')) {
        logger.warn 'No Notification Tag in Query :' + params.to_s }
      render nothing: true
    end
  end

  def add_visit(exception=nil, params=nil)
    data = params || Hash.new
    valid_submission = false

    logger.tagged('Params passed', [controller_name, action_name].join('|')) {
      logger.info  data.to_s }

    if @mark.nil?
      logger.tagged('Unknown Mark', [controller_name, action_name].join('|')) {
          logger.warn 'No Notification Tag in Query :' + params.to_s }
      return
    end

    logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
      logger.info 'Processing Visit with params: ' + data.to_s }

    if params
      if params.has_key?(:networkid)
        if params[:networkid].casecmp(@mark.notification_tag) == 0
          valid_submission = true
        end
      end
    end

    Visit.new(
        {
            time: configatron.current.time,
            location:  [request.env['REMOTE_ADDR'], request.env['HTTP_X_FORWARDED_FOR']].join('|'),
            ua:  request.env['HTTP_USER_AGENT'],
            resource: action_name,
            data: data.to_json,
            valid_submission: valid_submission,
            mark_id: @mark.nil? ? 9999 : @mark.id ,
            exception: exception.nil? ? false : true,
            exception_exp: exception.nil? ? nil : exception,
            campaign: configatron.campaigns.trcampaign.name
      }
    ).save

    if @mark.stat
      logger.info 'Mark Stat available'
      mark_stat=@mark.stat
      mark_stat.update(visit: mark_stat.visit + 1)
      if configatron.campaigns.trcampaign.web.submissions.lock
        unless mark_stat.submission < configatron.campaigns.trcampaign.web.submissions.lock_threshold
          logger.info 'Mark Stat Submission needs lock'
          mark_stat.update(submission_lock: true)
        end
      end
      mark_stat.save
      logger.info 'Mark Stat (visits) Saved'

      if valid_submission
        mark_stat.update(valid_submission: valid_submission)
        mark_stat.save
        logger.info 'Mark Stat (valid submission) Saved'
      end

    else
      Stat.new(
          mark_id: @mark.nil? ? 9999 : @mark.id ,
          visit: 1,
          visit_lock: false,
          submission: 0,
          valid_submission: false,
          submission_lock: false
      ).save
    end
  end


  # #Visit to the attacker's setup via predefined link triggers a scheduler for email response to parties
  # def notify_visit_delayed?
  #
  #   if configatron.campaigns.trcampaign.web.visits.delayed.respond
  #     printf 'Delayed: Visits to date from %s : %d', @mark.notification_tag, @mark.visits.count
  #     if @mark.visits.count == configatron.campaigns.trcampaign.web.visits.delayed.email.threshold
  #       logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
  #         logger.warn 'Delayed: Visit Threshold tripped for ' + @mark.notification_tag + '. Delayed email Job will pick it up' }
  #     end
  #   end
  # end

  #Visit to the attacker's setup via predefined link triggers a realtime visitation email response to parties
  #based on threshold of notification
  def notify_visit_realtime?

    if configatron.campaigns.trcampaign.web.visits.realtime.respond
      printf 'Submissions to date from %s : %d', @mark.notification_tag, @mark.visits.count
      if @mark.visits.count == configatron.campaigns.trcampaign.web.visits.realtime.email.threshold
        logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
         logger.warn 'Visit Threshold tripped' + @mark.notification_tag + '. Need to send out visitation email.' }
        #Phishcampaign.hook_campaign_ed_visitation(@mark).deliver
        RealtimeNotificationJob.perform(@mark.id)
      end
    end
  end

  #Submission of a form to the attacker's setup via predefined link triggers a submission
  #email to the party based on threshold of notification
  def notify_submission_realtime?

    if configatron.campaigns.trcampaign.web.submissions.realtime.respond
      submissions=@mark.visits.where(resource: 'authenticate').count
      if submissions == configatron.campaigns.trcampaign.web.submissions.realtime.email.threshold
        logger.tagged(@mark.notification_tag, [controller_name, action_name].join('|')) {
          logger.warn 'Submission Threshold tripped' + @mark.notification_tag + '. Need to send out visitation email.' }
        #Phishcampaign.hook_campaign_ed_submission(@mark).deliver
        RealtimeNotificationJob.perform(@mark.id)
      end
    end
  end


end
