require 'rake'
require 'csv'

namespace :marks do

  desc 'Generate Mock-up marks <campaign, number_of_marks>'
  task :generate_marks, [:campaign,:number_users] => :environment do |t,args|

    args.with_defaults(:campaign => nil, :number_users => 10)
    if args.campaign.nil?
      abort('You need to specify which campaign you need to seed marks for')
    end

    args.number_users.to_i.times do
      seed_number=Random.rand(10000...99999)
      notification_tag=gen_notification_id(seed_number)
      m=Mark.create(
          id: seed_number,
          display_name: gen_user_name(seed_number),
          email_addr: gen_email(seed_number) ,
          notification_tag: notification_tag,
          complete_flag: false,
          campaign: args.campaign,
          hashid: Mark.gen_hashid(seed_number)
      )
      m.save!
      p  m

    end
  end


  desc 'Load Marks from CSV'
  task :load_marks, [:csv_file] => :environment do |t,args|

    args.with_defaults(:campaign => nil, :csv_file => nil)
    if args.csv_file.nil?
      abort('You need to specify csv file with mark seeds')
    end

    if File.exists?(args.csv_file)
      csv_records = CSV.read(args.csv_file, headers: true, col_sep: ',')

      csv_records.each do |record|

        #puts 'Processing : ' + record.inspect
        seed_number=Random.rand(1000000...9999999)
        hashid=Mark.gen_hashid(seed_number)

        m=Mark.create(
            id: seed_number,
            display_name: record['Display Name'],
            email_addr: record['Email Address'],
            notification_tag: record['User ID'],
            complete_flag: record['Complete?'],
            campaign: record['Campaign Name'],
            hashid: hashid
        )
        m.save!
        p  m

      end
    else
      abort(args.csv_file + ': Not accessible')
    end

  end
end



def gen_notification_id(seed_number)
  #NNNNNNNN -> [a-z1-9](5,6) Example: g1zp6
  (seed_number.to_s + (1+rand(8)).to_s).reverse.to_i.to_s(36)
end
def gen_user_name(seed_number)
  user_name='User ' + seed_number.to_s
end
def gen_email(seed_number)
  base_user='user'
  smtp_domain='@example.com'
  email = base_user + seed_number.to_s + smtp_domain
end
