class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process resize_to_fit: [32, 32]
  end
  version :preview do
    process resize_to_fit: [256, 256]
  end
  version :medium do
    process resize_to_fit: [512, 512]
  end
end
