def speeding_ticket(speed, speed_limit)
	ratio = speed / speed_limit
	if ratio >= 4
		400
	elsif ratio >= 3
		250
	elsif ratio >= 2
		100
	end
end

