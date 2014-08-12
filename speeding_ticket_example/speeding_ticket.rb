def speeding_ticket(speed, speed_limit)
  if speed < speed_limit
    0
  elsif speed_limit*2 < speed
    100
  else
    50
  end
end
