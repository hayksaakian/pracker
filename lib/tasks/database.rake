namespace :database do
  desc "Copy production database to local"
  task :sync => :environment do
    system 'mongodump -h ds043987.mongolab.com:43987 -d heroku_app15043681 -u heroku -p osl7i6f8rha2vfr5gcl9d4e2vu -o db/backups/'
    system 'mongorestore -h localhost --drop -d pracker_development db/backups/heroku_app15043681/'
  end
end
