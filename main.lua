local AddonName, Addon = ...
Addon.Name = AddonName

--[[ globals ]]--

local _G = _G
local format = string.format
local print = print

do
	local events = CreateFrame('Frame')
	
	events:SetScript('OnEvent', function(self, event, ...)
		local func = self[event]
		if func then
			func(self, event, ...)
		end
	end)
	
	events.PLAYER_LOGIN = function(self, event)
		Addon:OnEnable()
		self:UnregisterEvent(event)
	end
	
	events:RegisterEvent('PLAYER_LOGIN')
end

function Addon:OnEnable()
	self:Print('OnEnable')
	
	for i = 1, 12 do
		self:CreateVirtualButton(_G['ActionButton' .. i])
	end
	
	self:LoadBindings()
end

function Addon:Print(...)
	return print(format('|cff9F8170%s|r:', self.Name), ...)
end

function Addon:GetFrameController()
	local frameController = self.frameController
	
	if not self.frameController then
		frameController = CreateFrame("Frame", 'KeyMachineController', _G['UIParent'], 'SecureHandlerBaseTemplate, SecureHandlerStateTemplate')
		
		frameController:Execute([[ 
			Frames = table.new() 
			Targets = table.new()
		]])
		
		frameController:SetAttribute('AddFrame', [[
			table.insert(Frames, self:GetFrameRef('frameToAdd'))
			table.insert(Targets, self:GetFrameRef('targetToAdd'))
			
			print('AddFrame', #Frames, #Targets)
		]])
		
		frameController:SetAttribute('LoadBindings', [[
			print('LoadBindings', ...)
					
			self:ClearBindings() 
					
			for frameID in ipairs(Frames) do
				self:RunAttribute('SetFrameBindings', frameID, self:RunAttribute('GetFrameBindings', frameID))
			end	
		]])
		
		frameController:SetAttribute('SetFrameBindings', [[
			print('SetFrameBindings', ...)	
			
			local frameID = (...)			
			for i = 2, select('#', ...) do
				self:RunAttribute('SetFrameBinding', frameID, (select(i, ...)))
			end
		]])
		
		frameController:SetAttribute('SetFrameBinding', [[
			local frameID, key = ...
			local frame = Frames[frameID]				
				
			-- print('SetFrameBinding', true, key, frame:GetName())
			self:SetBindingClick(true, key, frame:GetName())
		]])
		
		frameController:SetAttribute('GetFrameBindings', [[
			local frameID = ...
			
			return GetBindingKey(Targets[frameID]:GetName())
		]])
		
		self.frameController = frameController
	end
	
	return self.frameController
end

function Addon:CreateVirtualButton(target)
	local button = CreateFrame('Button', 'KeyMachine_' .. target:GetName(), self:GetFrameController(), 'SecureHandlerBaseTemplate, SecureActionButtonTemplate')
	
	button:RegisterForClicks('anyDown')
	
	button:SetAttribute('type', 'click')
	button:SetAttribute('clickbutton', target)
	
	self:RegisterVirtualButton(button, target)
	
	return button
end

function Addon:RegisterVirtualButton(vButton, target)
	local controller = self:GetFrameController()
	
	controller:SetFrameRef('frameToAdd', vButton)
	controller:SetFrameRef('targetToAdd', target)
	controller:Execute([[ self:RunAttribute('AddFrame') ]])
	
	return self
end

function Addon:LoadBindings()
	self:GetFrameController():Execute([[ self:RunAttribute('LoadBindings') ]])
	
	return self
end