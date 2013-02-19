#!/usr/bin/env ruby

require 'rubygems'
require 'RMagick'
require 'aws/s3'
require 'digest/md5'
require 'kooaba'

# ------------- CONFIGURATION ------------------------------ #

# Set the kooaba API data key. You can find it at
# https://platform.kooaba.com/datakeys
Kooaba.data_key = 'KOOABA_DATA_KEY'

# Set the bucket you want to put the item into
kooaba_bucket_id = 'KOOABA_BUCKET_ID'

aws_access_key = 'AWS_ACCESS_KEY'
aws_secret_key = 'AWS_SECRET_KEY'
aws_bucket = 'AWS_S3_BUCKET_NAME'

# Intitalize S3 (for storing some thumbnails and PDF pages)
AWS::S3::Base.establish_connection!(
   :access_key_id     => aws_access_key,
   :secret_access_key => aws_secret_key
 )

# ------------- CONFIGURATION END --------------------------- #


pdf = Magick::ImageList.new("1.pdf")

pdf.each_with_index do |page,i|

  puts "Preparing Page #{i} ..."

  page.write("tmp.pdf") #write local PDF copy of just that page

  # write a jpg file which will be uploaded to kooaba as reference image
  page.change_geometry!('640x480>'){ |cols, rows, img|
    img.resize!(cols, rows)
    img.colorspace = Magick::RGBColorspace
    img.write("tmp.jpg")
  }

  # write a jpg file which serves as thumbnail
  page.change_geometry!('160x120>'){ |cols, rows, img|
    img.resize!(cols, rows)
    img.colorspace = Magick::RGBColorspace
    img.write("thumb.jpg")
  }

  # 1. calculate md5 digest for filename
  digest = Digest::MD5.hexdigest(File.read('tmp.jpg'))

  # 2. Upload to s3 (files are publicly accessible)
  AWS::S3::S3Object.store("#{digest}.jpg", open('thumb.jpg'), aws_bucket, :access => :public_read )
  AWS::S3::S3Object.store("#{digest}.pdf", open('tmp.pdf'), aws_bucket, :access => :public_read)

  # 3. create the metadata object, which will be uploaded as json to kooaba
  metadata = { :pdf_url => "https://s3.amazonaws.com/#{aws_bucket}/#{digest}.pdf",
                :thumb_url => "https://s3.amazonaws.com/#{aws_bucket}/#{digest}.jpg" }


  # 4. Upload to kooaba

  item = Kooaba::Item.new(   #initialize the item
    :title => "Page #{i}",
    :metadata => metadata.to_json,
    :image_files => ["tmp.jpg"],
    :reference_id => "page-#{i}"
    )

  # upload the item
  puts "Uploading Page #{i} ..."
  response = Kooaba.upload(item, kooaba_bucket_id)

  puts "Response code: #{response.code}"
  puts "Response body: #{response.body}"

end
