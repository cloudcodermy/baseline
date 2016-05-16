def file_upload
  if @configs['database'] == "mongoid"
    gem "mongoid-paperclip", :require => "mongoid_paperclip"
    gem 'aws-sdk', '~> 1.3.4'
  else
    gem "paperclip", "~> 4.2"
  end
end