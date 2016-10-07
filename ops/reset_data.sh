#!/bin/bash

RAILS_ENV=production

rake marks:marks_delete['campaign_tr']
if RAILS_ENV == 'development'
	rake marks:gen_tag['campaign_tr',3]
end
if RAILS_ENV == 'production'
	rake db:active_seed 
end 

rake marks:email_phish['campaign_tr']
