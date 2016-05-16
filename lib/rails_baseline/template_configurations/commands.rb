def git
  after_everything do
    git :init
    git :add => '.'
    git :commit => '-m "Initial commit"'
  end
end

def bundler
  say_wizard "Running Bundler install. This will take a while."
  run 'bundle install'
  say_wizard "Running after Bundler callbacks."
  @after_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

  @current_recipe = nil
  say_wizard "Running after everything callbacks."
  @after_everything_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

  @current_recipe = nil
  say_wizard "==================================FINISH PROCESS================================="
end