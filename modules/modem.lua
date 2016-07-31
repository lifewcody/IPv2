function openModems()

	for a=1, #rs.getSides() do
	
		if peripheral.getType(rs.getSides()[a]) == "modem" then
		
			if peripheral.call(rs.getSides()[a], "isWireless") then
				print("Wireless modem on " .. rs.getSides()[a])
			else
				print("Wired modem on " .. rs.getSides()[a])
			end
		end
	
	end
	
end