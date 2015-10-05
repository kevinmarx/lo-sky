require 'RMagick'

class Sky < ActiveRecord::Base
  has_attached_file :image,
                    storage: :s3,
                    s3_credentials: { bucket: ENV["S3_BUCKET"], access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"] }


  validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  TOP_COLORS = 4

  def self.make_image
    original = Magick::Image.read("http://webpages.charter.net/dohara12/cameras/lsmmacam/lsmvc800.jpg").first
    # Crop image to the sky, increase saturation, and reduce number of colors
    modulated = original.crop(Magick::NorthGravity, 640, 180).modulate(1.1, 2, 1).quantize(TOP_COLORS, Magick::RGBColorspace)
    file = Tempfile.new(['out','.png'])
    modulated.write(file.path)

    new_sky = self.new
    new_sky.image = file
    new_sky.colors = self.get_pix(self.sort_by_decreasing_frequency(modulated))
    new_sky.save
  end

  # Create a 1-row image that has a column for every color in the quantized
  # image. The columns are sorted decreasing frequency of appearance in the
  # quantized image.
  def self.sort_by_decreasing_frequency(img)
    hist = img.color_histogram
    # sort by decreasing frequency
    sorted = hist.keys.sort_by {|p| -hist[p]}
    new_img = Magick::Image.new(hist.size, 1)
    new_img.store_pixels(0, 0, hist.size, 1, sorted)
  end

  def self.get_pix(img)
    #palette = Magick::ImageList.new
    pixels = img.get_pixels(0, 0, img.columns, 1)
    pixels.map do |p|
      p.to_color(Magick::AllCompliance, false, 8, true)
    end
  end

end
