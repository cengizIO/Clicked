local AceConsole = LibStub("AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local bindingProcessorFrame

local attributes
local data

local function OpenBindingProcessorFrame()
	if bindingProcessorFrame ~= nil and bindingProcessorFrame:IsVisible() then
		return
	end

	bindingProcessorFrame = AceGUI:Create("Frame")
	bindingProcessorFrame:SetTitle("Clicked Binding Processor Output")
	bindingProcessorFrame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
	end)
	bindingProcessorFrame:SetLayout("Fill")

	local lines = {}
	
	for i, command in ipairs(data) do
		table.insert(lines, "----- " .. i .. " -----")
		table.insert(lines, "keybind: " .. command.keybind)
		table.insert(lines, "hovercast: " .. tostring(command.hovercast))
		table.insert(lines, "action: " .. command.action)

		if command.data ~= nil then
			local split = { strsplit("\n", command.data) }

			for _, line in ipairs(split) do
				table.insert(lines, "data: " .. line)
			end
		end

		if data[command] ~= nil then
			for attribute, value in pairs(data[command]) do
				local split = { strsplit("\n", value) }
				
				for _, line in ipairs(split) do
					table.insert(lines, "attribute-" .. attribute .. ": " .. line)
				end
			end
		end

		table.insert(lines, "")
	end

	if data["hovercast"] ~= nil then
		table.insert(lines, "----- hovercast -----")
		
		for attribute, value in pairs(data["hovercast"].attributes) do
			local split = { strsplit("\n", value) }
			
			for _, line in ipairs(split) do
				table.insert(lines, "attribute-" .. attribute .. ": " .. line)
			end
		end
	end

	local output = AceGUI:Create("MultiLineEditBox")
	output:SetText(table.concat(lines, "\n"))
	bindingProcessorFrame:AddChild(output)
end

local function OnBindingProcessorComplete(event, commands)
	data = {}
	
	for i, command in ipairs(commands) do
		data[i] = command
	end
end

local function OnMacroAttributesCreated(event, command, attributes)
	data[command] = attributes
end

local function OnHovercastAttributesCreated(event, keybindings, attributes)
	data["hovercast"] = {
		keybindings = keybindings,
		attributes = attributes
	}
end

function Clicked:RegisterDebugOptions()
	self:RegisterMessage(self.EVENT_BINDING_PROCESSOR_COMPLETE, OnBindingProcessorComplete)
	self:RegisterMessage(self.EVENT_MACRO_ATTRIBUTES_CREATED, OnMacroAttributesCreated)
	self:RegisterMessage(self.EVENT_HOVERCAST_ATTRIBUTES_CREATED, OnHovercastAttributesCreated)
end

AceConsole:RegisterChatCommand("ccbpo", OpenBindingProcessorFrame)