require 'rake'
namespace :marks do

  desc "List Campaigns"
  task :list_campaigns => :environment do |t, args|
    Mark.uniq.pluck(:campaign).each { |c| puts c }
  end

  desc "Show Marks"
  task :show_marks, [:campaign] => :environment do |t, args|

    if args.campaign.nil?
      abort('You need to specify which campaign you need to query marks for')
    end
    puts "Showing marks for campaign : #{args.campaign}"

    flag=nil
    Mark.where(campaign: args.campaign).each do |m|
      if m.complete_flag.eql?(false)
        flag ='Pending'
      else
        flag ='Delivered'
      end
      puts "[#{flag}] #{m.display_name} #{m.email_addr}"
    end
  end

  desc "Email Marks"
  task :email_phish, [:campaign, :force] => :environment do |t, args|

    if args.campaign.nil?
      abort('You need to specify which campaign you need to email marks to')
    end

    Mark.where(campaign: args.campaign).each do |m|
      if m.email_addr.nil?
        puts "Skipping Mark because (no email_addr): #{m.display_name}"
      else
        # Not yet delivered. Toggle to 'false' if need to resend, or pass 'true' to force
        if (not m.complete_flag == true) or args.force
          puts "Delivering (#{args.campaign}) phish to : #{m.display_name} - #{m.email_addr}"

          # Some mail servers throttle email acceptance. Try to accompdate
	  # TODO: Configuration
          sleep 5
	  # Deliver MJML or HTML	
          CampaignTr::Phishcampaign.mail_campaign(m).deliver_now
          #CampaignTr::Phishcampaign.mail_campaign_mj(m).deliver_now

          # set mark 'mailed'
          m.complete_flag=true
          m.save!
        else
          puts "Already delivered to : #{m.display_name}, #{m.email_addr} (pass ['campaign,>true<]' to force if you must rerun delivery)"
        end
      end
    end
  end

  desc "Clean Marks table"
  task :marks_delete, [:campaign] => :environment do |t, args|

    if args.campaign.nil?
      abort('You need to specify which campaign you need to remove marks from')
    end
    puts "Deleting data from Mark model"
    marks_to_delete=Mark.where(campaign: args.campaign)
    marks_to_delete.each do |m|
      m.destroy
    end
    # Visit and Stat should be reaped alongside with the mark
  end

  desc "Show Visits and Submissions - alphabetical"
  task :visits_show_alpha => :environment do |t, args|
    require 'csv'
    CSV.open('report.csv', 'w',
             :write_headers => true,
             :headers => ['Fusion ID', 'First Name', 'Last Name', 'Email', 'Visited Site (Y/N)'] #< column header
    ) do |hdr|
      Mark.all.order(:display_name).each do |m|
          names=m.display_name.split(' ');
          data_out = [m.notification_tag, names[0], names[1], m.email_addr]

        if m.visits.count == 0
          data_out << 'N'
          #puts "#{m.notification_tag},#{m.display_name},#{m.email_addr},N"
        else
          data_out << 'Y'
          #puts "#{m.notification_tag},#{m.display_name},#{m.email_addr},Y"
        end
        puts data_out
        hdr << data_out
      end
    end
   end

  desc "Show Visits and Submissions"
  require 'csv'
  task :visits_show => :environment do |t, args|

    CSV.open('test.csv', 'w',
             :write_headers => true,
             :headers => ['Name', 'Visit Date.Time', 'IP Visited From',
                          'Show Page or Submit Form?', 'Submission Network ID', 'Valid Network ID?',
                          'Submission Email Address', 'Tracking ID'] #< column header
    ) do |hdr|

      Mark.all.each do |m|
        #v=m.visits.where(resource: 'authenticate')
        m.visits.each do |v|

          networkid='-'
          networkid_valid='-'
          emailaddress='-'

          r=JSON.parse(v.data, symbolize_names: true)
          unless r.empty?
            if r[:networkid]
              if r[:networkid].empty?
                networkid='Empty'
              else
                networkid=r[:networkid]
                networkid_valid = 'No'
                networkid_valid = 'Yes' if v.valid_submission
              end

            end
            if r[:emailaddress]
              if r[:emailaddress].empty?
                emailaddress='Empty'
              else
                emailaddress=r[:emailaddress]
              end
            end
          end


          data_out = [m.display_name,
                      v.time.strftime("%Y-%m-%d %H:%M:%S"),
                      v.location.split('|')[1],
                      v.resource,
                      networkid,
                      networkid_valid,
                      emailaddress,
                      m.hashid
          ]

          hdr << data_out

          puts [m.display_name.to_s,
                v.time.strftime("%Y-%m-%d %H:%M:%S"),
                v.location.split('|')[1],
                v.resource,
                networkid,
                networkid_valid,
                emailaddress,
                m.hashid
               ].join(',')
        end
      end
    end

  end

end
