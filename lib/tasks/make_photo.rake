namespace :make_photo do
  desc "make image"
  task take: :environment do
    Sky.make_image
  end

end
