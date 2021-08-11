local function Debounce(instance, event, binding)
	local Running = false
	return instance[event]:Connect(function(...)
		if Running then return end

		Running = true
		binding(...)
		Running = false
	end)
end

return Debounce