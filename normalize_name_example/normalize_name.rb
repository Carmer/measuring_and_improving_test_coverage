def normalize_name(name, gender)
  if name
    name
  elsif gender == :masculine
    'John Doe'
  elsif gender == :feminine
    'Jane Doe'
  end
end
