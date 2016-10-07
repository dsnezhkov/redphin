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


################# Seed


# clean
Mark.delete_all


# populate
10.times do
  seed_number=Random.rand(1000000...9999999)
  notification_tag=gen_notification_id(seed_number)
  m=Mark.create(
      id: seed_number,
      display_name: gen_user_name(seed_number),
      email_addr: gen_email(seed_number) ,
      notification_tag: notification_tag,
      complete_flag: false,
      campaign: 'tr_campaign',
      hashid: Mark.gen_hashid(seed_number)
  )
  p  m
end
