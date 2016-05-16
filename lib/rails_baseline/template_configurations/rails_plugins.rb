def cancancan
  gem 'cancancan'

  after_bundler do
    generate "cancan:ability"
  end
end

def state_machines
  if @configs['database'] == "mongoid"
    gem 'state_machines-mongoid'
  else
    gem 'state_machines-activerecord'
  end
end

def paranoia
  if @configs['database'] != "mongoid"
    gem "paranoia"
  else
    gem 'mongoid_paranoia'
  end  
end

def debugger
  gem_group :development do
    gem "better_errors"
    gem "hirb"
  end
end

def kaminari
  gem 'kaminari'

  after_bundler do
    generate "kaminari:views bootstrap3" if @configs["bootstrap"]
  end
end