def recipes
 @recipes 
end

def recipe?(name)
  @recipes.include?(name) 
end

def say_custom(tag, text)
  say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}"
end

def say_recipe(name)
  say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..."
end

def say_wizard(text)
  say_custom(@current_recipe || 'wizard', text) 
end

def ask_wizard(question)
  ask "\033[1m\033[30m\033[46m" + (@current_recipe || "prompt").rjust(10) + "\033[0m\033[36m" + "  #{question}\033[0m"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question)
  !yes_wizard?(question) 
end

def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice,i| 
    values[(i + 1).to_s] = choice[1]
    say_custom (i + 1).to_s + ')', choice[0]
  end
  answer = ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

def after_bundler(&block)
  @after_blocks << [@current_recipe, block]
end

def after_everything(&block)
  @after_everything_blocks << [@current_recipe, block]
end

def before_config(&block)
  @before_configs[@current_recipe] = block
end