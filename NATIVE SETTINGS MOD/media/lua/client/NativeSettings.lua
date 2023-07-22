--***************************NATIVE SETTINGS MODS (v0.9)**********************
--*                             GroovY / U_0047                              *
--* mod resource allowing addition of custom settings to main options screen *
--*              https://github.com/U0047/NativeSettingsMod/                 *
--*                                                                          *
--****************************************************************************


local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

-- -- -- -- --

local GameOption = ISBaseObject:derive("GameOption")
local GameOptions = ISBaseObject:derive("GameOptions")
local HorizontalLine = ISPanel:derive("HorizontalLine")


--***************************************************************************************
NativeSettings = {mods={}}
ModSettings = {}
NativeSetting = {}
ColorBox = {}
Slider = {}
ComboBox = {}
YesNoBox = {}
YesNoMultiBox = {}


function NativeSettings.addModSettings(Settings)
    table.insert(NativeSettings.mods, Settings)
end

function ModSettings:new(modName)
    local o = {}
	setmetatable(o, self)
	self.__index = self
    o.modName = modName
    o.settings = {}
    o.isHidden = function() return false end
    return o
end

function ModSettings:addSetting(NativeSetting)
    table.insert(self.settings, NativeSetting)
end

--wrapper allowing users to define their own GameOption and child functions
function NativeSettings.createGameOption(VanillaOption, NativeSetting)
    gameOption = GameOption:new(NativeSetting.name, VanillaOption)
    function gameOption.toUI(self)
        local box = self.control
        NativeSetting.toUI(box)
    end

    function gameOption.apply(self)
        local box = self.control
        NativeSetting.apply(box)
    end

    return gameOption

end

function NativeSetting:new(name, tooltip)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.name = name
    o.tooltip = tooltip
    o.isHidden = function() return false end
    return o
end

function ColorBox:new(name, rgba, tooltip)
    local o = NativeSetting:new(name, tooltip)
    setmetatable(o, self)
    self.__index = self
    o.name = name
    o.rgba = rgba
    o.isColorBox = true
    o.tooltip = tooltip
    return o
end

function ColorBox:addToOptionsPage(MainOptionsPage)
    local splitpoint = MainOptionsPage:getWidth() / 3
    VanillaOption = MainOptionsPage:addColorButton(splitpoint, 0, self.name, self.rgba, nil)
    colorPicker = ISColorPicker:new(0, 0)
    colorPicker:initialise()
    colorPicker.pickedTarget = MainOptionsPage
    colorPicker.resetFocusTo = MainOptionsPage
    VanillaOption:setOnClick(MainOptions.displayColorPicker, VanillaOption, self.rgba, colorPicker)

    VanillaOption.tooltip = self.tooltip

    gameOption = NativeSettings.createGameOption(VanillaOption, self)
    return gameOption
end

function Slider:new(name, tooltip)
    local o = NativeSetting:new(name, tooltip)
    setmetatable(o, self)
    self.__index = self
    o.name = name
    o.isSlider = true
    o.tooltip = tooltip
    return o
end

function Slider:addToOptionsPage(MainOptionsPage)
    local splitpoint = MainOptionsPage:getWidth() / 3
    VanillaOption = MainOptionsPage:addVolumeControl(splitpoint, 0, 300, 20, self.name, 0)
    gameOption = NativeSettings.createGameOption(VanillaOption, self)
    return gameOption
end

function ComboBox:new(name, options, tooltip)
    local o = NativeSetting:new(name, tooltip)
    setmetatable(o, self)
    self.__index = self
    o.name = name
    o.options = options
    o.isComboBox = true
    o.tooltip = tooltip
    return o
end

function ComboBox:addToOptionsPage(MainOptionsPage)
    local splitpoint = MainOptionsPage:getWidth() / 3
    VanillaOption = MainOptionsPage:addCombo(splitpoint, 0, 300, 20, self.name, self.options)
    gameOption = NativeSettings.createGameOption(VanillaOption, self)
    return gameOption
end

function YesNoMultiBox:new(name, YesNoBoxes, tooltip)
    local o = NativeSetting:new(name, tooltip)
    setmetatable(o, self)
    self.__index = self
    o.name = name
    o.YesNoBoxes = YesNoBoxes
    o.isYesNoMultiBox = true
    o.tooltip = tooltip
    return o
end

function YesNoMultiBox:addToOptionsPage(MainOptionsPage)
	local fontHgtSmall = FONT_HGT_SMALL
    local splitpoint = MainOptionsPage:getWidth() / 3
    label = ISLabel:new(splitpoint, MainOptionsPage.addY, fontHgtSmall, self.name, 1, 1, 1, 1, UIFont.Small, false)
    label:initialise()
    MainOptionsPage.mainPanel:addChild(label)
    VanillaOption = ISTickBox:new(splitpoint + 20, MainOptionsPage.addY, 200, 20, "HELLO?")
    VanillaOption.autoWidth = true
    VanillaOption.choicesColor = {r=1, g=1, b=1, a=1}
    VanillaOption:initialise()
    MainOptionsPage.mainPanel:addChild(VanillaOption)
    MainOptionsPage.mainPanel:insertNewLineOfButtons(VanillaOption)
    for _, YesNoBox in ipairs(self.YesNoBoxes) do
        VanillaOption:addOption(YesNoBox.name, nil)
    end
    MainOptionsPage.addY = MainOptionsPage.addY + VanillaOption:getHeight() + 4
    gameOption = NativeSettings.createGameOption(VanillaOption, self)
    return gameOption
end

function YesNoBox:new(name, tooltip)
    local o = NativeSetting:new(name, tooltip)
    setmetatable(o, self)
    self.__index = self
    o.name = name
    o.isYesNoBox = true
    o.tooltip = tooltip 
    return o
end

function YesNoBox:addToOptionsPage(MainOptionsPage)
    local splitpoint = MainOptionsPage:getWidth() / 3
    VanillaOption = MainOptionsPage:addYesNo(splitpoint, 0, 300, 20, self.name)
    gameOption = NativeSettings.createGameOption(VanillaOption, self)
    return gameOption
end


--**************************************************************************************
function MainOptions:displayColorPicker(target, button, color, colorPicker)
    --I took psychic damage making this
    local x = button.parent.parent.x + button.parent.x + button.parent:getXScroll() + button.x
    local y = button.parent.parent.y + button.parent.y + button.parent:getYScroll() + button.y + button.height + 1
    if y + colorPicker.height > self.height then
        y = y - button.height - colorPicker.height - 1
    end
    colorPicker:setX(x)
    colorPicker:setY(y)
    colorPicker:setPickedFunc(MainOptions.ColorPickerPickedColor, button)
    local color = button.backgroundColor
    local colorInfo = ColorInfo.new(color.r, color.g, color.b, 1)
    colorPicker:setInitialColor(colorInfo);
    self:addChild(colorPicker)
    colorPicker:bringToTop();
    local joypadData = JoypadState.getMainMenuJoypad()
    if joypadData then
        joypadData.focus = colorPicker
    end
end

function MainOptions:ColorPickerPickedColor(color, mouseUp, button) --lmao
    button.backgroundColor = {r=color.r, g=color.g, b=color.b, a=1}
    local gameOptions = MainOptions.instance.gameOptions
    gameOptions:onChange(gameOptions:get(button.name))
end

--***************************************************************************************
--most of this is just vanilla function
--that had to be put here because of lexical scoping (I think)

function GameOption:new(name, control, arg1, arg2)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.name = name
	o.control = control
	o.arg1 = arg1
	o.arg2 = arg2
	if control.isCombobox then
		control.onChange = self.onChangeComboBox
		control.target = o
	end
	if control.isTickBox then
		control.changeOptionMethod = self.onChangeTickBox
		control.changeOptionTarget = o
	end
	if control.isSlider then
		control.targetFunc = self.onChangeVolumeControl
		control.target = o
	end
	return o
end

function GameOption:toUI()
	print('ERROR: option "'..self.name..'" missing toUI()')
end

function GameOption:apply()
	print('ERROR: option "'..self.name..'" missing apply()')
end

function GameOption:resetLua()
	MainOptions.instance.resetLua = true
end

function GameOption:restartRequired(oldValue, newValue)
	if getCore():getOptionOnStartup(self.name) == nil then
		getCore():setOptionOnStartup(self.name, oldValue)
	end
	if getCore():getOptionOnStartup(self.name) == newValue then
		return
	end
	MainOptions.instance.restartRequired = true
end

function GameOption:onChangeComboBox(box)
	self.gameOptions:onChange(self)
	if self.onChange then
		self:onChange(box)
	end
end

function GameOption:onChangeTickBox(index, selected)
	self.gameOptions:onChange(self)
	if self.onChange then
		self:onChange(index, selected)
	end
end

function GameOption:onChangeVolumeControl(control, volume)
	self.gameOptions:onChange(self)
	if self.onChange then
		self:onChange(control, volume)
	end
end

--this is a fix from the original function
--which does ISPanel.new(self, ...),
--but we need to do ISPanel:new(...)
function HorizontalLine:new(x, y, width)
	local o = ISPanel:new(x, y, width, 2)
	return o
end

--***************************************************************************************

function MainOptions:create()

	local y = 20;
    -- stay away from statics :)
    MainOptions.keyText = {}
    MainOptions.keyBindingLength = 0;

	local fontHgtSmall = FONT_HGT_SMALL
	local fontHgtMedium = FONT_HGT_MEDIUM

	local buttonHgt = math.max(25, fontHgtSmall + 4 * 2)
	local topHgt = math.max(48, 10 + FONT_HGT_MEDIUM + 10)
	local bottomHgt = math.max(48, 5 + buttonHgt + 5)

	self.tabs = ISTabPanel:new(0, topHgt, self.width, self.height - topHgt - bottomHgt);
	self.tabs:initialise();
	self.tabs:setAnchorBottom(true);
	self.tabs:setAnchorRight(true);
--	self.tabs.borderColor = { r = 0, g = 0, b = 0, a = 0};
	self.tabs.onActivateView = MainOptions.onTabsActivateView;
	self.tabs.target = self;
	self.tabs:setEqualTabWidth(false)
	self.tabs.tabPadX = 40
	self.tabs:setCenterTabs(true)
--	self.tabs.tabHeight = self.tabs.tabHeight + 12
	self:addChild(self.tabs);

	self.backButton = ISButton:new(self.width / 2 - 100 / 2 - 10 - 100, self.height - buttonHgt - 5, 100, buttonHgt, getText("UI_btn_back"), self, MainOptions.onOptionMouseDown);
	self.backButton.internal = "BACK";
	self.backButton:initialise();
	self.backButton:instantiate();
	self.backButton:setAnchorLeft(true);
	self.backButton:setAnchorTop(false);
	self.backButton:setAnchorBottom(true);
	self.backButton.borderColor = {r=1, g=1, b=1, a=0.1};
	self.backButton:setFont(UIFont.Small);
	self.backButton:ignoreWidthChange();
	self.backButton:ignoreHeightChange();
	self:addChild(self.backButton);

	self.acceptButton = ISButton:new(self.width / 2 - 100 / 2, self.height - buttonHgt - 5, 100, buttonHgt, getText("UI_btn_accept"), self, MainOptions.onOptionMouseDown);
	self.acceptButton.internal = "ACCEPT";
	self.acceptButton:initialise();
	self.acceptButton:instantiate();
	self.acceptButton:setAnchorRight(false);
	self.acceptButton:setAnchorLeft(false);
	self.acceptButton:setAnchorTop(false);
	self.acceptButton:setAnchorBottom(true);
	self.acceptButton.borderColor = {r=1, g=1, b=1, a=0.1};
	self.acceptButton:setFont(UIFont.Small);
	self.acceptButton:ignoreWidthChange();
	self.acceptButton:ignoreHeightChange();
	self:addChild(self.acceptButton);

	self.saveButton = ISButton:new(self.width / 2 + 100 / 2 + 10, self.height - buttonHgt - 5, 100, buttonHgt, getText("UI_btn_apply"), self, MainOptions.onOptionMouseDown);
	self.saveButton.internal = "SAVE";
	self.saveButton:initialise();
	self.saveButton:instantiate();
	self.saveButton:setAnchorRight(false);
	self.saveButton:setAnchorLeft(false);
	self.saveButton:setAnchorTop(false);
	self.saveButton:setAnchorBottom(true);
	self.saveButton.borderColor = {r=1, g=1, b=1, a=0.1};
	self.saveButton:setFont(UIFont.Small);
	self.saveButton:ignoreWidthChange();
	self.saveButton:ignoreHeightChange();
	self:addChild(self.saveButton);

	local lbl = ISLabel:new((self.width / 2) - (getTextManager():MeasureStringX(UIFont.Medium, getText("UI_optionscreen_gameoption")) / 2), 10, fontHgtMedium, getText("UI_optionscreen_gameoption"), 1, 1, 1, 1, UIFont.Medium, true);
	lbl:initialise();
	self:addChild(lbl);

	self:addPage(getText("UI_optionscreen_display"))

	local splitpoint = self:getWidth() / 3;
	local comboWidth = self:getWidth()-splitpoint - 100
	local comboWidth = 300

	self:addHorizontalLine(y, getText("UI_DisplayOptions_Window"))

if true then
	----- DISPLAY MODE -----
	local displayMode = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_DisplayMode"),
		{ getText("UI_optionscreen_DisplayMode1"), getText("UI_optionscreen_DisplayMode2"), getText("UI_optionscreen_DisplayMode3") })
--[[
	local map = {}
	map["defaultTooltip"] = getText("UI_optionscreen_DisplayMode_tt")
	displayMode:setToolTipMap(map)
--]]
	gameOption = GameOption:new('displayMode', displayMode)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():isFullScreen() then
			box.selected = 1
		elseif getCore():getOptionBorderlessWindow() then
			box.selected = 2
		else
			box.selected = 3
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if not box.options[box.selected] then return end
		if box.selected == 1 then
			if not getCore():isFullScreen() then
				MainOptions.instance.monitorSettings.changed = true
			end
		elseif box.selected == 2 then
			if not getCore():getOptionBorderlessWindow() then
				MainOptions.instance.monitorSettings.changed = true
			end
		elseif box.selected == 3 then
			if getCore():getOptionBorderlessWindow() or getCore():isFullScreen() then
				MainOptions.instance.monitorSettings.changed = true
			end
		end
		local resolution = self.gameOptions:get('resolution') 
		local s = resolution.control.options[resolution.control.selected]
		local w,h = string.match(s, '(%d+) x (%d+)')
		if tonumber(w) ~= getCore():getScreenWidth() or tonumber(h) ~= getCore():getScreenHeight() then
			MainOptions.instance.monitorSettings.changed = true
		end
		MainOptions.instance:setResolutionAndFullScreen()
	end
	self.gameOptions:add(gameOption)

else
	----- FULLSCREEN -----
	local full = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_fullscreen"));

	local gameOption = GameOption:new('fullscreen', full)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():isFullScreen())
	end
	function gameOption.apply(self)
		if self.control:isSelected(1) ~= getCore():isFullScreen() then
			MainOptions.instance.monitorSettings.changed = true
		end
		local resolution = self.gameOptions:get('resolution') 
		local s = resolution.control.options[resolution.control.selected]
		local w,h = string.match(s, '(%d+) x (%d+)')
		if tonumber(w) ~= getCore():getScreenWidth() or tonumber(h) ~= getCore():getScreenHeight() then
			MainOptions.instance.monitorSettings.changed = true
		end
		MainOptions.instance:setResolutionAndFullScreen()
	end
	self.gameOptions:add(gameOption)

	----- BORDERLESS -----
	local combo = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_borderless"));
	combo.tooltip = getText("UI_optionscreen_borderless_tt");

	gameOption = GameOption:new('borderless', combo)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionBorderlessWindow())
	end
	function gameOption.apply(self)
		local box = self.control
		self:restartRequired(getCore():getOptionBorderlessWindow(), box:isSelected(1))
		getCore():setOptionBorderlessWindow(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)
end
	----- RESOLUTION -----
	local modes = getCore():getScreenModes();
	table.sort(modes, MainOptions.sortModes);
	table.insert(modes, 1, "CURRENT")
    local res = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_resolution"), modes, 1);

	gameOption = GameOption:new('resolution', res)
	function gameOption.toUI(self)
		local box = self.control
		local w = getCore():getScreenWidth()
		local h = getCore():getScreenHeight()
		box.options[1] = getText("UI_optionscreen_CurrentResolution", w .. " x " .. h)
		box.selected = 1
--		if w == 1280 and h == 720 then
--			box:select(w.." x "..h.. " (" .. getText("UI_optionscreen_recommended") .. ")")
--		else
			box:select(w.." x "..h)
--		end
	end
	function gameOption.apply(self)
		-- 'fullscreen' option sets both resolution and fullscreen
	end
	self.gameOptions:add(gameOption)

	----- FRAMERATE -----
	local framerate = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_framerate"), {getText("UI_optionscreen_Uncapped"), "244", "240", "165", "120", "95", "90", "75", "60", "55", "45", "30", "24"}, 2);

	gameOption = GameOption:new('framerate', framerate)
	function gameOption.toUI(self)
		local box = self.control
		local fps = getPerformance():getFramerate()
		local isFpsUncapped = getPerformance():isFramerateUncapped()
		if isFpsUncapped then box.selected = 1
		elseif fps == 244 then box.selected = 2
		elseif fps == 240 then box.selected = 3
		elseif fps == 165 then box.selected = 4
		elseif fps == 120 then box.selected = 5
		elseif fps == 95 then box.selected = 6
		elseif fps == 90 then box.selected = 7
		elseif fps == 75 then box.selected = 8
		elseif fps == 60 then box.selected = 9
		elseif fps == 55 then box.selected = 10
		elseif fps == 45 then box.selected = 11
		elseif fps == 30 then box.selected = 12
		elseif fps == 24 then box.selected = 13
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setFramerate(box.selected)
		end
	end
	self.gameOptions:add(gameOption)

	----- VSYNC -----
	local vsync = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_vsync"))

	gameOption = GameOption:new('vsync', vsync)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionVSync())
	end
	function gameOption.apply(self)
		local box = self.control
		if box:isSelected(1) ~= getCore():getOptionVSync() then
			MainOptions.instance.monitorSettings.changed = true
		end
		getCore():setOptionVSync(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

--[[
	----- MULTICORE -----
	local map = {};

    local multithread;
    multithread = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_multicore"));
    multithread.tooltip = getText("UI_optionscreen_needreboot");

	gameOption = GameOption:new('multicore', multithread)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():isMultiThread())
	end
	function gameOption.apply(self)
		local box = self.control
		self:restartRequired(getCore():isMultiThread(), box:isSelected(1))
		getCore():setMultiThread(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- SHADERS -----
    --shaders now forced on.
    local shader;
	shader = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_shaders2"), {getText("UI_Yes"), getText("UI_No")}, 1);

	gameOption = GameOption:new('shaders', shader)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getUseShaders() then
			box.selected = 1;
		else
			box.selected = 2;
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setUseShaders(box.selected == 1)
			if MainScreen.instance.inGame then
				getCore():shadersOptionChanged()
			end
		end
	end
	self.gameOptions:add(gameOption)
--]]

	self:addHorizontalLine(y, getText("UI_DisplayOptions_Cursor"))

	----- ISO CURSOR -----
	options = {}
	table.insert(options, getText("UI_Off"))
	table.insert(options, "5%")
	table.insert(options, "10%")
	table.insert(options, "15%")
	table.insert(options, "30%")
	table.insert(options, "50%")
	table.insert(options, "75%")

	local combo = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_iso_cursor"), options, 3)

	gameOption = GameOption:new('iso_cursor', combo)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getIsoCursorVisibility()+1;
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setIsoCursorVisibility(box.selected-1)
		end
	end
	self.gameOptions:add(gameOption)

	----- SHOW CURSOR WHILE AIMING -----
	local showCursorWhileAiming = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_ShowCursorWhileAiming"));
	showCursorWhileAiming.tooltip = getText("UI_optionscreen_ShowCursorWhileAiming_tt");

	gameOption = GameOption:new('showCursorWhileAiming', showCursorWhileAiming)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionShowCursorWhileAiming())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionShowCursorWhileAiming(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- AIM OUTLINE -----
	local aimOutline = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_aim_outline"),
		{ getText("UI_optionscreen_aim_outline1"), getText("UI_optionscreen_aim_outline2"), getText("UI_optionscreen_aim_outline3") })

	local map = {}
	map["defaultTooltip"] = getText("UI_optionscreen_aim_outline_tt")
	aimOutline:setToolTipMap(map)

	gameOption = GameOption:new('aimOutline', aimOutline)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionAimOutline()
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionAimOutline(box.selected)
		end
	end
	self.gameOptions:add(gameOption)
	
	----- LOCK CURSOR TO WINDOW -----
	local combo = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_LockCursorToWindow"));
	combo.tooltip = getText("UI_optionscreen_LockCursorToWindow_tt");

	gameOption = GameOption:new('lockCursorToWindow', combo)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionLockCursorToWindow())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionLockCursorToWindow(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	self:addHorizontalLine(y, getText("UI_DisplayOptions_UI"))

	----- UI FBO -----
	local UIFBO = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_UIFBO"))
	UIFBO.tooltip = getText("UI_optionscreen_UIFBO_tt")

	gameOption = GameOption:new('UIFBO', UIFBO)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionUIFBO())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionUIFBO(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- UI RENDER FPS -----
	local UIRenderFPS = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_UIRenderFPS"), {"30", "25", "20", "15", "10"}, 2)
	local map = {}
	map["defaultTooltip"] = getText("UI_optionscreen_UIRenderFPS_tt")
	UIRenderFPS:setToolTipMap(map)

	gameOption = GameOption:new("UIRenderFPS", UIRenderFPS)
	function gameOption.toUI(self)
		local box = self.control
		local fps = getCore():getOptionUIRenderFPS()
		if fps == 30 then box.selected = 1
		elseif fps == 25 then box.selected = 2
		elseif fps == 20 then box.selected = 3
		elseif fps == 15 then box.selected = 4
		elseif fps == 10 then box.selected = 5
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			local fpsTable = {30, 25, 20, 15, 10}
			getCore():setOptionUIRenderFPS(fpsTable[box.selected])
		end
	end
	self.gameOptions:add(gameOption)

	----- INVENTORY CONTAINER SIZE -----
	local containerSize = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_InventoryContainerSize"), { getText("UI_optionscreen_Small"), getText("UI_optionscreen_Medium"), getText("UI_optionscreen_Large") }, 1)

	gameOption = GameOption:new('inventoryContainerSize', containerSize)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionInventoryContainerSize()
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionInventoryContainerSize(box.selected)
			if MainScreen.instance.inGame then
				ISInventoryPage.ContainerSizeChanged()
			end
		end
	end
	self.gameOptions:add(gameOption)

	----- Show Item Mod Info -----
	local clock24 = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_Show_Item_Mod_Info"))

	gameOption = GameOption:new('showItemModInfo', clock24)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionShowItemModInfo())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionShowItemModInfo(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- Show Survival Guide -----
	local survivalGuide = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_ShowSurvivalGuide"))

	gameOption = GameOption:new('showSurvivalGuide', survivalGuide)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionShowSurvivalGuide())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionShowSurvivalGuide(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	self:addHorizontalLine(y, getText("UI_DisplayOptions_Textures"))

	----- TEXTURE COMPRESSION -----
    local texcompress = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_texture_compress"));
    texcompress.tooltip = getText("UI_optionscreen_texture_compress_tt");

	gameOption = GameOption:new('texcompress', texcompress)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionTextureCompression())
	end
	function gameOption.apply(self)
		local box = self.control
		self:restartRequired(getCore():getOptionTextureCompression(), box:isSelected(1))
		getCore():setOptionTextureCompression(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- DOUBLE SIZED -----
    local doubleSize = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_texture2x"));
    doubleSize.tooltip = getText("UI_optionscreen_texture2x_tt");

	gameOption = GameOption:new('doubleSize', doubleSize)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionTexture2x())
	end
	function gameOption.apply(self)
		local box = self.control
		self:restartRequired(getCore():getOptionTexture2x(), box:isSelected(1))
		getCore():setOptionTexture2x(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- MAX TEXTURE SIZE -----
	local maxTextureSize = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_MaxTextureSize"),
		{ getText("UI_optionscreen_MaxTextureSize1"), getText("UI_optionscreen_MaxTextureSize2"), getText("UI_optionscreen_MaxTextureSize3"), getText("UI_optionscreen_MaxTextureSize4") });
	local map = {}
	map["defaultTooltip"] = getText("UI_optionscreen_MaxTextureSize_tt"):gsub('\\n', '\n')
	maxTextureSize:setToolTipMap(map)

	gameOption = GameOption:new('maxTextureSize', maxTextureSize)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionMaxTextureSize()
	end
	function gameOption.apply(self)
		local box = self.control
		self:restartRequired(getCore():getOptionMaxTextureSize(), box.selected)
		getCore():setOptionMaxTextureSize(box.selected)
	end
	self.gameOptions:add(gameOption)

	----- MAX VEHICLE TEXTURE SIZE -----
	local maxVehicleTextureSize = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_MaxVehicleTextureSize"),
		{ getText("UI_optionscreen_MaxTextureSize1"), getText("UI_optionscreen_MaxTextureSize2"), getText("UI_optionscreen_MaxTextureSize3"), getText("UI_optionscreen_MaxTextureSize4") });
	local map = {}
	map["defaultTooltip"] = getText("UI_optionscreen_MaxVehicleTextureSize_tt"):gsub('\\n', '\n')
	maxVehicleTextureSize:setToolTipMap(map)

	gameOption = GameOption:new('maxVehicleTextureSize', maxVehicleTextureSize)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionMaxVehicleTextureSize()
	end
	function gameOption.apply(self)
		local box = self.control
		self:restartRequired(getCore():getOptionMaxVehicleTextureSize(), box.selected)
		getCore():setOptionMaxVehicleTextureSize(box.selected)
	end
	self.gameOptions:add(gameOption)

	----- SIMPLE CLOTHING TEXTURES -----
	local simpleClothingTex = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_SimpleClothingTextures"),
		{ getText("UI_optionscreen_SimpleClothingTextures1"), getText("UI_optionscreen_SimpleClothingTextures2"), getText("UI_optionscreen_SimpleClothingTextures3") },
		1);

	local map = {}
	map["defaultTooltip"] = getText("UI_optionscreen_SimpleClothingTextures_tt")
	simpleClothingTex:setToolTipMap(map)

	gameOption = GameOption:new('simpleClothingTex', simpleClothingTex)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionSimpleClothingTextures()
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionSimpleClothingTextures(box.selected)
	end
	self.gameOptions:add(gameOption)
    
	----- SIMPLE WEAPON TEXTURES -----
	local simpleWeaponTex = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_SimpleWeaponTextures"));
	simpleWeaponTex.tooltip = getText("UI_optionscreen_SimpleWeaponTextures_tt");

	gameOption = GameOption:new('simpleWeaponTex', simpleWeaponTex)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionSimpleWeaponTextures())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionSimpleWeaponTextures(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

--[[
	-- Disabled because it's too slow to create the mipmaps.
	----- MODEL TEXTURE MIPMAPS -----
    local modelTextureMipmaps = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_ModelTextureMipmaps"));
    modelTextureMipmaps.tooltip = getText("UI_optionscreen_ModelTextureMipmaps_tt");

	gameOption = GameOption:new('modelTextureMipmaps', modelTextureMipmaps)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionModelTextureMipmaps())
	end
	function gameOption.apply(self)
		local box = self.control
		self:restartRequired(getCore():getOptionModelTextureMipmaps(), box:isSelected(1))
		getCore():setOptionModelTextureMipmaps(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)
]]--

--[[
	----- NEW ROOF-HIDING -----
	local roofHiding = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_NewRoofHiding"), {getText("UI_Yes"), getText("UI_No")}, 1);
	roofHiding:setToolTipMap({ defaultTooltip = getText("UI_optionscreen_NewRoofHiding_tt") })
	gameOption = GameOption:new('newRoofHiding', roofHiding)
	function gameOption.toUI(self)
		local box = self.control
		if getPerformance():getNewRoofHiding() then
			box.selected = 1
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getPerformance():setNewRoofHiding(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)
--]]

	self:addHorizontalLine(y, getText("UI_DisplayOptions_Camera"))

	----- ZOOM ON/OFF -----
    local zoom = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_zoom"))

	gameOption = GameOption:new('zoom', zoom)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionZoom())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionZoom(box:isSelected(1))
		getCore():zoomOptionChanged(MainScreen.instance.inGame)
	end
	self.gameOptions:add(gameOption)

	----- ZOOM LEVELS -----
	label = ISLabel:new(splitpoint, y + self.addY, fontHgtSmall, getText("UI_optionscreen_zoomlevels"), 1, 1, 1, 1, UIFont.Small, false)
	label:initialise()
	self.mainPanel:addChild(label)
	local zoomLevelsTickBox = ISTickBox:new(splitpoint + 20, y + self.addY, 200, 20, "HELLO?")
	zoomLevelsTickBox.choicesColor = {r=1, g=1, b=1, a=1}
	zoomLevelsTickBox:initialise()
	self.mainPanel:addChild(zoomLevelsTickBox)
	self.mainPanel:insertNewLineOfButtons(zoomLevelsTickBox)
	-- Must addChild *before* addOption() or ISUIElement:getKeepOnScreen() will restrict y-position to screen height
	local zoomLevels = getCore():getDefaultZoomLevels()
	for i = 1,zoomLevels:size() do
		local percent = zoomLevels:get(i-1)
		if percent ~= 100 then
			zoomLevelsTickBox:addOption(getText("IGUI_BackButton_Zoom", percent), tostring(percent))
		end
	end
	self.addY = self.addY + zoomLevelsTickBox:getHeight() + 4

	gameOption = GameOption:new('zoomLevels', zoomLevelsTickBox)
	function gameOption.toUI(self)
		local box = self.control
		local percentsStr = (Core.getTileScale() == 2) and
			getCore():getOptionZoomLevels2x() or
			getCore():getOptionZoomLevels1x()
		local percents = luautils.split(percentsStr, ";")
		for i = 1,#box.options do
			box:setSelected(i, (#percents == 0) or self:tableContains(percents, box.optionData[i]))
		end
	end
	function gameOption.apply(self)
		local box = self.control
		local s = ""
		for i = 1,#box.options do
			if box:isSelected(i) then
				if s ~= "" then s = s .. ";" end
				s = s .. box.optionData[i]
			end
		end
		if Core.getTileScale() == 2 and s ~= getCore():getOptionZoomLevels2x() then
			getCore():setOptionZoomLevels2x(s)
			getCore():zoomLevelsChanged()
		elseif Core.getTileScale() == 1 and s ~= getCore():getOptionZoomLevels1x() then
			getCore():setOptionZoomLevels1x(s)
			getCore():zoomLevelsChanged()
		end
	end
	function gameOption.tableContains(self, table, item)
		for _,v in pairs(table) do
			if v == item then return true end
		end
		return false
	end
	self.gameOptions:add(gameOption)

	----- AUTO-ZOOM -----
	label = ISLabel:new(splitpoint, y + self.addY, fontHgtSmall, getText("UI_optionscreen_autozoom"), 1, 1, 1, 1, UIFont.Small, false)
	label:initialise()
	self.mainPanel:addChild(label)
	local autozoomTickBox = ISTickBox:new(splitpoint + 20, y + self.addY, 200, 20, "HELLO?")
	autozoomTickBox.choicesColor = {r=1, g=1, b=1, a=1}
	autozoomTickBox:initialise();
	self.mainPanel:addChild(autozoomTickBox)
	self.mainPanel:insertNewLineOfButtons(autozoomTickBox)
	-- Must addChild *before* addOption() or ISUIElement:getKeepOnScreen() will restrict y-position to screen height
	for i = 1,4 do
		autozoomTickBox:addOption(getText("UI_optionscreen_player"..i), nil)
	end
	self.addY = self.addY + autozoomTickBox:getHeight() + 4

	gameOption = GameOption:new('autoZoom', autozoomTickBox)
	function gameOption.toUI(self)
		local box = self.control
		for i = 1,4 do
			box:setSelected(i, getCore():getAutoZoom(i-1))
		end
	end
	function gameOption.apply(self)
		local box = self.control
		for i = 1,4 do
			getCore():setAutoZoom(i-1, box:isSelected(i))
		end
	end
	self.gameOptions:add(gameOption)

	----- PAN CAMERA WHILE AIMING -----
    local panCameraWhileAiming = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_panCameraWhileAiming"))

	gameOption = GameOption:new('panCameraWhileAiming', panCameraWhileAiming)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionPanCameraWhileAiming())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionPanCameraWhileAiming(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- PAN CAMERA WHILE DRIVING -----
    local panCameraWhileDriving = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_panCameraWhileDriving"))

	gameOption = GameOption:new('panCameraWhileDriving', panCameraWhileDriving)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionPanCameraWhileDriving())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionPanCameraWhileDriving(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	self:addHorizontalLine(y, getText("UI_DisplayOptions_Fonts"))

	----- FONT SIZE -----
	local fontSize = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_FontSize"), { getText("UI_optionscreen_FontSize0"), getText("UI_optionscreen_FontSize1"), getText("UI_optionscreen_FontSize2"), getText("UI_optionscreen_FontSize3"), getText("UI_optionscreen_FontSize4") }, 1)

	if MainScreen.instance.inGame then
		local tooltipMap = {}
		tooltipMap["defaultTooltip"] = getText("UI_optionscreen_needreboot")
		fontSize:setToolTipMap(tooltipMap)
	end

	gameOption = GameOption:new('fontSize', fontSize)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionFontSize()
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			if getCore():getOptionFontSize() ~= box.selected then
				getCore():setOptionFontSize(box.selected)
				self:resetLua()
			end
		end
	end
	self.gameOptions:add(gameOption)

	----- CONTEXT-MENU FONT -----
	local menuFont = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_context_menu_font"), { getText("UI_optionscreen_Small"), getText("UI_optionscreen_Medium"), getText("UI_optionscreen_Large") }, 2)

	gameOption = GameOption:new('contextMenuFont', menuFont)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getOptionContextMenuFont() == "Small" then
			box.selected = 1
		elseif getCore():getOptionContextMenuFont() == "Large" then
			box.selected = 3
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			local choices = { "Small", "Medium", "Large" }
			getCore():setOptionContextMenuFont(choices[box.selected])
		end
	end
	self.gameOptions:add(gameOption)

	----- INVENTORY FONT -----
	local invFont = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_inventory_font"), { getText("UI_optionscreen_Small"), getText("UI_optionscreen_Medium"), getText("UI_optionscreen_Large") }, 2)

	gameOption = GameOption:new('inventoryFont', invFont)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getOptionInventoryFont() == "Small" then
			box.selected = 1
		elseif getCore():getOptionInventoryFont() == "Large" then
			box.selected = 3
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			local choices = { "Small", "Medium", "Large" }
			getCore():setOptionInventoryFont(choices[box.selected])
			if MainScreen.instance.inGame then
				ISInventoryPage.onInventoryFontChanged()
			end
		end
	end
	self.gameOptions:add(gameOption)

	----- TOOLTIP FONT -----
	local ttFont = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_tooltip_font"), { getText("UI_optionscreen_Small"), getText("UI_optionscreen_Medium"), getText("UI_optionscreen_Large") }, 2)

	gameOption = GameOption:new('tooltipFont', ttFont)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getOptionTooltipFont() == "Small" then
			box.selected = 1
		elseif getCore():getOptionTooltipFont() == "Large" then
			box.selected = 3
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			local choices = { "Small", "Medium", "Large" }
			getCore():setOptionTooltipFont(choices[box.selected])
		end
	end
	self.gameOptions:add(gameOption)

	self:addHorizontalLine(y, getText("UI_DisplayOptions_Clock"))

	----- CLOCK FORMAT -----
	local clockFmt = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_clock_format"), { getText("UI_optionscreen_clock_month_day"), getText("UI_optionscreen_clock_day_month") }, 1)

	gameOption = GameOption:new('clockFormat', clockFmt)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionClockFormat()
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionClockFormat(box.selected)
		end
	end
	self.gameOptions:add(gameOption)

	----- CLOCK SIZE -----
	local clockSize = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_clock_Size"), { getText("UI_optionscreen_clock_small"), getText("UI_optionscreen_clock_large") }, 1)

	if MainScreen.instance.inGame then
		local tooltipMap = {}
		tooltipMap["defaultTooltip"] = getText("UI_optionscreen_needreboot")
		clockSize:setToolTipMap(tooltipMap)
	end
	gameOption = GameOption:new('clockSize', clockSize)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionClockSize()
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionClockSize(box.selected)
		end
	end
	self.gameOptions:add(gameOption)

	----- CLOCK 24-HOUR -----
	local clock24 = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_clock_24_or_12"), { getText("UI_optionscreen_clock_24_hour"), getText("UI_optionscreen_clock_12_hour") }, 1)

	gameOption = GameOption:new('clock24hour', clock24)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionClock24Hour() and 1 or 2
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionClock24Hour(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)

    ----- Temperature display -----
    local clock24 = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_temperature_display"), { getText("UI_optionscreen_temperature_fahrenheit"), getText("UI_optionscreen_temperature_celsius") }, 1)

    gameOption = GameOption:new('temperatureDisplay', clock24)
    function gameOption.toUI(self)
        local box = self.control
        box.selected = getCore():getOptionDisplayAsCelsius() and 2 or 1
    end
    function gameOption.apply(self)
        local box = self.control
        if box.options[box.selected] then
            getCore():setOptionDisplayAsCelsius(box.selected == 2)
        end
    end
    self.gameOptions:add(gameOption)

	self:addHorizontalLine(y, getText("UI_DisplayOptions_RenderingAndPerformance"))

    ----- Do Wind sprite effects -----
    local clock24 = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_do_wind_sprite_effects"))

    gameOption = GameOption:new('doWindSpriteEffects', clock24)
    function gameOption.toUI(self)
        local box = self.control
        box:setSelected(1, getCore():getOptionDoWindSpriteEffects())
    end
    function gameOption.apply(self)
        local box = self.control
        getCore():setOptionDoWindSpriteEffects(box:isSelected(1))
    end
    self.gameOptions:add(gameOption)

    ----- Do Door sprite effects -----
    local clock24 = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_do_door_sprite_effects"))

    gameOption = GameOption:new('doDoorSpriteEffects', clock24)
    function gameOption.toUI(self)
        local box = self.control
        box:setSelected(1, getCore():getOptionDoDoorSpriteEffects())
    end
    function gameOption.apply(self)
        local box = self.control
        getCore():setOptionDoDoorSpriteEffects(box:isSelected(1))
    end
    self.gameOptions:add(gameOption)

    ----- Do Container Outline effects -----
    local clock24 = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_do_container_outline"))

    gameOption = GameOption:new('doContainerOutline', clock24)
    function gameOption.toUI(self)
        local box = self.control
        box:setSelected(1, getCore():getOptionDoContainerOutline())
    end
    function gameOption.apply(self)
        local box = self.control
        getCore():setOptionDoContainerOutline(box:isSelected(1))
    end
    self.gameOptions:add(gameOption)

	----- Render rain when indoors -----
    --[[
    local doRainIndoors = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_render_rain_indoors"))

    gameOption = GameOption:new('renderRainIndoors', doRainIndoors)
    function gameOption.toUI(self)
        local box = self.control
        box:setSelected(1, getCore():isRenderPrecipIndoors())
    end
    function gameOption.apply(self)
        local box = self.control
        getCore():setRenderPrecipIndoors(box:isSelected(1))
    end
    self.gameOptions:add(gameOption)
	--]]

	----- OBJECT HIGHLIGHT COLOR -----
	local ohc = getCore():getObjectHighlitedColor()
	local rgba = {r = ohc:getR(), g = ohc:getG(), b = ohc:getB(), a = 1}
	self.objHighColor = self:addColorButton(splitpoint, y, getText("UI_optionscreen_objHighlightColor"), rgba, MainOptions.onObjHighlightColor)

    self.colorPicker2 = ISColorPicker:new(0, 0)
    self.colorPicker2:initialise()
    self.colorPicker2.pickedTarget = self
    self.colorPicker2.resetFocusTo = self
    self.colorPicker2:setInitialColor(getCore():getObjectHighlitedColor());

    gameOption = GameOption:new('objHighColor', self.objHighColor)
    function gameOption.toUI(self)
        local color = getCore():getObjectHighlitedColor()
        self.control.backgroundColor = {r = color:getR(), g = color:getG(), b = color:getB(), a = 1}
    end
    function gameOption.apply(self)
        local color = self.control.backgroundColor
        local current = getCore():getObjectHighlitedColor()
        if current:getR() == color.r and current:getG() == color.g and current:getB() == color.b then
            return
        end
        getCore():setObjectHighlitedColor(ColorInfo.new(color.r, color.g, color.b, 1))
    end
    self.gameOptions:add(gameOption)

	----- Zombie update optimization -----
	local zombieUpdateOpt = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_zombie_update_optimization"))
	zombieUpdateOpt.tooltip = getText("UI_optionscreen_zombie_update_optimization_tt")
	gameOption = GameOption:new('zombieUpdateOpt', zombieUpdateOpt)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionTieredZombieUpdates())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionTieredZombieUpdates(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

    ----- BLOOD DECALS -----
	local options = {}
	for i=0,10 do
		table.insert(options, getText("UI_BloodDecals"..i))
	end
	local combo = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_blood_decals"), options, 1)

	gameOption = GameOption:new('bloodDecals', combo)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionBloodDecals() + 1
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionBloodDecals(box.selected-1)
		end
	end
	self.gameOptions:add(gameOption)

	----- CORPSE SHADOWS -----
    local corpseShadows = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_CorpseShadows"));

	gameOption = GameOption:new('corpseShadows', corpseShadows)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionCorpseShadows())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionCorpseShadows(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- LIGHTING QUALITY -----
    local lighting = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_lighting"), {getText("UI_High"), getText("UI_Medium"), getText("UI_Low"), getText("UI_Lowest")}, 1);

	gameOption = GameOption:new('lightingQuality', lighting)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getPerformance():getLightingQuality() + 1
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getPerformance():setLightingQuality(box.selected-1)
		end
	end
	self.gameOptions:add(gameOption)

	----- LIGHTING FPS -----
    local combo = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_lighting_fps"), {'5', '10', '15 (' .. getText("UI_optionscreen_recommended") .. ')', '20', '25', '30', '45', '60'}, 1)
    map = {}
	map["defaultTooltip"] = getText("UI_optionscreen_lighting_fps_tt")
	combo:setToolTipMap(map)

	gameOption = GameOption:new('lightingFPS', combo)
	function gameOption.toUI(self)
		local box = self.control
		local fps = getPerformance():getLightingFPS()
		local selected = 3
		if fps == 5 then selected = 1 end
		if fps == 10 then selected = 2 end
		if fps == 15 then selected = 3 end
		if fps == 20 then selected = 4 end
		if fps == 25 then selected = 5 end
		if fps == 30 then selected = 6 end
		if fps == 45 then selected = 7 end
		if fps == 60 then selected = 8 end
		box.selected = selected
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			-- handle (RECOMMENDED)
			local s = box.options[box.selected]
			local v = s:split(' ')
			getPerformance():setLightingFPS(tonumber(v[1]))
		end
	end
	self.gameOptions:add(gameOption)

    ----- Performance skybox -----
    local perf_skybox;
	perf_skybox = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_perf_skybox"), {getText("UI_High"), getText("UI_Medium"), getText("UI_No")}, 1);

	gameOption = GameOption:new('perf_skybox', perf_skybox)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getPerfSkybox() + 1
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
            getCore():setPerfSkybox(box.selected-1)
            if getCore():getPerfSkyboxOnLoad() ~= getCore():getPerfSkybox() then
                self:restartRequired(getCore():getPerfSkyboxOnLoad(), getCore():getPerfSkybox())
            end
		end
	end
	self.gameOptions:add(gameOption)
    
    ----- Water QUALITY -----
    local water = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_water"), {getText("UI_High"), getText("UI_Medium"), getText("UI_Low")}, 1);

	gameOption = GameOption:new('waterQuality', water)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getPerformance():getWaterQuality() + 1
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getPerformance():setWaterQuality(box.selected-1)
		end
	end
	self.gameOptions:add(gameOption)
    
    ----- Performance Puddles -----
    local perf_puddles;
	perf_puddles = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_perf_puddles"), {getText("UI_All"), getText("UI_GroundWithRuts"), getText("UI_GroundOnly"), getText("UI_None")}, 1);

	gameOption = GameOption:new('perf_puddles', perf_puddles)
	function gameOption.toUI(self)
		local box = self.control
        box.selected = getCore():getPerfPuddles() + 1
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
            getCore():setPerfPuddles(box.selected-1)
            if (getCore():getPerfPuddlesOnLoad() ~= getCore():getPerfPuddles()) and (getCore():getPerfPuddlesOnLoad() == 3) then
                self:restartRequired(getCore():getPerfPuddlesOnLoad(), getCore():getPerfPuddles())
            end
		end
	end
	self.gameOptions:add(gameOption)
    
    ----- Puddles QUALITY -----
    local puddles = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_puddles"), {getText("UI_High"), getText("UI_Medium"), getText("UI_Low")}, 1);

	gameOption = GameOption:new('puddlesQuality', puddles)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getPerformance():getPuddlesQuality() + 1
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getPerformance():setPuddlesQuality(box.selected-1)
		end
	end
	self.gameOptions:add(gameOption)
    
    ----- Performance reflections -----
    local perf_reflections;
	perf_reflections = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_perf_reflections"));

	gameOption = GameOption:new('perf_reflections', perf_reflections)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getPerfReflections())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setPerfReflections(box:isSelected(1))
		if getCore():getPerfReflectionsOnLoad() ~= getCore():getPerfReflections() then
			self:restartRequired(getCore():getPerfReflectionsOnLoad(), getCore():getPerfReflections())
		end
	end
	self.gameOptions:add(gameOption)

	----- Display 3D Items -----
	local v3Ditem;
	v3Ditem = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_perf_3Ditems"));

	gameOption = GameOption:new('perf_3Ditems', v3Ditem)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():isOption3DGroundItem())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOption3DGroundItem(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- Precipitation -----
	local precipOption = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_render_precipitation"), { getText("UI_optionscreen_render_precipAlways"), getText("UI_optionscreen_render_precipOutdoors"), getText("UI_optionscreen_render_precipNever") }, 1)

	gameOption = GameOption:new('precipOption', precipOption)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionRenderPrecipitation()
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionRenderPrecipitation(box.selected)
		end
	end
	self.gameOptions:add(gameOption)

	----- Fog QUALITY -----
	local newfog = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_fog_quality"), {getText("UI_High"), getText("UI_Medium"), getText("UI_optionscreen_legacy")}, 1);

	gameOption = GameOption:new('fogQuality', newfog)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getPerformance():getFogQuality() + 1
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getPerformance():setFogQuality(box.selected-1)
		end
	end
	self.gameOptions:add(gameOption)

	-- SEARCH MODE OVERLAY EFFECT
	local overlayEffect = self:addCombo(splitpoint, y, 300, 20, getText("UI_optionscreen_Search_Mode_Overlay_Effect_Label"),
			{
				getText("UI_optionscreen_Search_Mode_Overlay_Effect_Both"),
				getText("UI_optionscreen_Search_Mode_Overlay_Effect_Blur"),
				getText("UI_optionscreen_Search_Mode_Overlay_Effect_Desaturate"),
				getText("UI_optionscreen_Search_Mode_Overlay_Effect_None"),
			},
			1)

	gameOption = GameOption:new('searchModeOverlayEffect', overlayEffect);
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionSearchModeOverlayEffect();
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionSearchModeOverlayEffect(box.selected);
		end
	end
	self.gameOptions:add(gameOption);

	self:addHorizontalLine(y, getText("UI_DisplayOptions_Language"))

	----- LANGUAGE -----
    local availableLanguage,currentIndex = MainOptions.getAvailableLanguage();
    local language = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_language"), availableLanguage, currentIndex);
	if MainScreen.instance.inGame == true then
		language:setToolTipMap(MainOptions.doLanguageToolTip(availableLanguage));
	end

	gameOption = GameOption:new('language', language)
	function gameOption.toUI(self)
		local box = self.control
		box:select(Translator.getLanguage():name())
        self:onChange(box);
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			local languages = Translator.getAvailableLanguage()
			for i=1,languages:size() do
				local language = languages:get(i-1)
				if language:text() == box.options[box.selected] then
					if Translator.getLanguage():index() ~= language:index() then
						getCore():setOptionLanguageName(language:name())
						Translator.setLanguage(language)
						self:resetLua()
					end
					break
				end
			end
		end
    end
    function gameOption:onChange(box)
        local panel = MainOptions.instance.tabs:getActiveView();
        local oldH = panel:getScrollHeight()-MainOptions.instance.translatorPane:getHeight();

        local languages = Translator.getAvailableLanguage()
        local curLang = nil;
        for i=1,languages:size() do
            if languages:get(i-1):text() == box.options[box.selected] then
                curLang = languages:get(i-1);
                break;
            end
        end

        local text = getText("UI_optionscreen_general_content").." "..getText("UI_optionscreen_translatedBy"):lower()..": \n";
        for k,v in ipairs(MainOptions.getGeneralTranslators(curLang)) do
            text = text .. " - " .. v .. "\n";
        end
        local names = curLang and getRadioTranslators(curLang) or nil;
        if names ~= nil and names:size() == 1 and names:get(0) == "unknown" then
            -- "unknown" is the default WordZed name. Nasko asked to display nothing instead of "unknown".
        else
            text = text .. "\n" .. getText("UI_optionscreen_radio_content").." "..getText("UI_optionscreen_translatedBy"):lower()..": \n";
            if names and names:size()>0 then
                for i=1,names:size() do
                    if names:get(i-1) ~= "unknown" then
                        text = text .." - ".. names:get(i-1).."\n";
                    end
                end
            else
                text = text .. " - "..getText("UI_optionscreen_no_translators").." -\n";
            end
        end
        if box.options[box.selected]=="English" then
            text = getText("UI_optionscreen_default_lang");
        end
        MainOptions.instance.translatorPane.text = text;
        MainOptions.instance.translatorPane:paginate();
        panel:setScrollHeight(oldH+MainOptions.instance.translatorPane:getHeight())
    end
	self.gameOptions:add(gameOption)

    local communityContentTickBox = ISTickBox:new(splitpoint + 20, y + self.addY, 200, 20, "HELLO?")
    communityContentTickBox.choicesColor = {r=1, g=1, b=1, a=1}
    communityContentTickBox:initialise();
    -- Must addChild *before* addOption() or ISUIElement:getKeepOnScreen() will restrict y-position to screen height
    self.mainPanel:addChild(communityContentTickBox)
    communityContentTickBox:addOption(getText("UI_optionscreen_tickbox_comlang"), nil)
    self.mainPanel:insertNewLineOfButtons(communityContentTickBox)
    self.addY = self.addY + communityContentTickBox:getHeight()

    gameOption = GameOption:new('comlang', communityContentTickBox)
    function gameOption.toUI(self)
        local box = self.control
        box:setSelected(1, getCore():getContentTranslationsEnabled()); -- getCore():getAutoZoom(i-1))
    end
    function gameOption.apply(self)
        local box = self.control
        getCore():setContentTranslationsEnabled(box:isSelected(1))
    end
    self.gameOptions:add(gameOption)

    MainOptions.translatorPane = ISRichTextPanel:new (splitpoint+20, self.addY+22, comboWidth, 0);
    MainOptions.translatorPane:initialise();
    self.mainPanel:addChild(MainOptions.translatorPane);
    MainOptions.translatorPane:paginate();

    self.addY = self.addY+MainOptions.translatorPane:getHeight()+22;

	self.mainPanel:setScrollHeight(y + self.addY + 20)
    
	-----------------
	----- SOUND -----
	-----------------
	self:addPage(getText("UI_optionscreen_audio"))
	y = 20;
	self.addY = 0

	----- Sound VOLUME -----
	local control = self:addVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_sound_volume"), 0)
	gameOption = GameOption:new('soundVolume', control)
	function gameOption.toUI(self)
		local volume = getCore():getOptionSoundVolume()
		volume = math.min(10, math.max(0, volume))
		self.control:setVolume(volume)
	end
	function gameOption.apply(self)
		getCore():setOptionSoundVolume(self.control:getVolume())
	end
	self.gameOptions:add(gameOption)

	----- MUSIC VOLUME -----
	local control = self:addVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_music_volume"), 0)
	gameOption = GameOption:new('musicVolume', control)
	function gameOption.toUI(self)
		local volume = getCore():getOptionMusicVolume()
		volume = math.min(10, math.max(0, volume))
		self.control:setVolume(volume)
	end
	function gameOption.apply(self)
		getCore():setOptionMusicVolume(self.control:getVolume())
	end
	self.gameOptions:add(gameOption)

    ----- AMBIENT VOLUME -----
    local control = self:addVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_ambient_volume"), 0)
    gameOption = GameOption:new('ambientVolume', control)
    function gameOption.toUI(self)
        local volume = getCore():getOptionAmbientVolume()
        volume = math.min(10, math.max(0, volume))
        self.control:setVolume(volume)
    end
    function gameOption.apply(self)
        getCore():setOptionAmbientVolume(self.control:getVolume())
    end
    self.gameOptions:add(gameOption)

    ----- JUMP-SCARE VOLUME -----
    local control = self:addVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_jumpscare_volume"), 0)
    gameOption = GameOption:new('jumpscareVolume', control)
    function gameOption.toUI(self)
        local volume = getCore():getOptionJumpScareVolume()
        volume = math.min(10, math.max(0, volume))
        self.control:setVolume(volume)
    end
    function gameOption.apply(self)
        getCore():setOptionJumpScareVolume(self.control:getVolume())
    end
    self.gameOptions:add(gameOption)

	----- VEHICLE ENGINE VOLUME -----
	local control = self:addVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_vehicle_engine_volume"), 0)
	control.tooltip = getText("UI_optionscreen_vehicle_engine_volume_tt");
	gameOption = GameOption:new('vehicleEngineVolume', control)
	function gameOption.toUI(self)
		local volume = getCore():getOptionVehicleEngineVolume()
		volume = math.min(10, math.max(0, volume))
		self.control:setVolume(volume)
	end
	function gameOption.apply(self)
		getCore():setOptionVehicleEngineVolume(self.control:getVolume())
	end
	self.gameOptions:add(gameOption)

	----- MUSIC LIBRARY -----
	local combo = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_music_library"), { getText("UI_optionscreen_music_library_1"), getText("UI_optionscreen_music_library_2"), getText("UI_optionscreen_music_library_3")}, 1)
	gameOption = GameOption:new('musicLibrary', combo)
	function gameOption.toUI(self)
		local box = self.control
		local library = getCore():getOptionMusicLibrary()
		box.selected = math.min(3, math.max(1, library))
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionMusicLibrary(box.selected)
		end
	end
	self.gameOptions:add(gameOption)

	----- MUSIC ACTION STYLE -----
	local combo = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_MusicActionStyle"), { getText("UI_optionscreen_MusicActionStyle_1"), getText("UI_optionscreen_MusicActionStyle_2")}, 1)
	gameOption = GameOption:new('musicActionStyle', combo)
	function gameOption.toUI(self)
		local box = self.control
		local library = getCore():getOptionMusicActionStyle()
		box.selected = math.min(2, math.max(1, library))
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionMusicActionStyle(box.selected)
		end
	end
	self.gameOptions:add(gameOption)

--[[
	----- CURRENT MUSIC -----
	local musicLbl = ISLabel:new(splitpoint, y + self.addY, fontHgtSmall, getText("UI_optionscreen_music_track1"), 1, 1, 1, 1, UIFont.Small, false);
--	musicLbl:setAnchorRight(true)
	musicLbl:initialise();
	self.mainPanel:addChild(musicLbl);
	
	self.currentMusicLabel = ISLabel:new(splitpoint + 20, y + self.addY, fontHgtSmall, "", 1, 1, 1, 1, UIFont.Small, true);
	self.currentMusicLabel:initialise();
	self.mainPanel:addChild(self.currentMusicLabel);
	self.addY = self.addY + fontHgtSmall + 6
--]]

	----- RakVoice -----
	local voiceEnable = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceEnable"), {getText("UI_Yes"), getText("UI_No")}, 1)
	gameOption = GameOption:new('voiceEnable', voiceEnable)
	function gameOption.toUI(self)
		local box = self.control
		if getCore():getOptionVoiceEnable() then
			box.selected = 1
		else
			box.selected = 2
		end
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionVoiceEnable(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)

	local listrecorddevices = VoiceManager:RecordDevices();
	local voiceRecordDevice = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceRecordDevice"), listrecorddevices, 0)
	gameOption = GameOption:new('voiceRecordDevice', voiceRecordDevice)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionVoiceRecordDevice()
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionVoiceRecordDevice(box.selected)
	end
	self.gameOptions:add(gameOption)
	
	local voiceMode = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceMode"), {getText("UI_PPT"), getText("UI_VAD"), getText("UI_Mute")}, 1)
	gameOption = GameOption:new('voiceMode', voiceMode)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionVoiceMode()
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionVoiceMode(box.selected)
	end
	self.gameOptions:add(gameOption)

--    self.voipKey = ISLabel:new(splitpoint + 20, y + self.addY, 20, getText("UI_PPT_Key", getCore():getKey("Enable voice transmit")), 1, 1, 1, 1, UIFont.Small, true);
--    self.voipKey:initialise();
--    self.mainPanel:addChild(self.voipKey);
--    self.addY = self.addY + 26;

	local voiceVADMode = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceVADMode"), {getText("UI_VADMode1_Quality"), getText("UI_VADMode2_LowBitrate"), getText("UI_VADMode3_Aggressive"), getText("UI_VADMode4_VeryAggressive")}, 1)
	gameOption = GameOption:new('voiceVADMode', voiceVADMode)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionVoiceVADMode()
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionVoiceVADMode(box.selected)
	end
	self.gameOptions:add(gameOption)

	local voiceAGCMode = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceAGCMode"), {getText("UI_AGCMode1_AdaptiveAnalog"), getText("UI_AGCMode2_AdaptiveDigital"), getText("UI_AGCMode3_FixedDigital")}, 1)
	gameOption = GameOption:new('voiceAGCMode', voiceAGCMode)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionVoiceAGCMode()
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionVoiceAGCMode(box.selected)
	end
	self.gameOptions:add(gameOption)

	local voiceVolumeMic = self:addMegaVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceVolumeMic"), 0)
	voiceVolumeMic.tooltip = getText("UI_optionscreen_voiceVolumeMic_tt");
	gameOption = GameOption:new('voiceVolumeMic', voiceVolumeMic)
	function gameOption.toUI(self)
		local volume = getCore():getOptionVoiceVolumeMic()
		volume = math.min(11, math.max(0, volume))
		self.control:setVolume(volume)
	end
	function gameOption.apply(self)
		getCore():setOptionVoiceVolumeMic(self.control:getVolume())
	end
	self.gameOptions:add(gameOption)
	

	local voiceVolumeMicIndicator = self:addVolumeIndicator(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceVolumeMicIndicator"), 0)
	voiceVolumeMicIndicator.tooltip = getText("UI_optionscreen_voiceVolumeMicIndicator_tt");
	
	local voiceVolumePlayers = self:addMegaVolumeControl(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_voiceVolumePlayers"), 0)
	voiceVolumePlayers.tooltip = getText("UI_optionscreen_voiceVolumePlayers_tt");
	gameOption = GameOption:new('voiceVolumePlayers', voiceVolumePlayers)
	function gameOption.toUI(self)
		local volume = getCore():getOptionVoiceVolumePlayers()
		volume = math.min(11, math.max(0, volume))
		self.control:setVolume(volume)
	end
	function gameOption.apply(self)
		getCore():setOptionVoiceVolumePlayers(self.control:getVolume())
	end
	self.gameOptions:add(gameOption)

	if SystemDisabler.getEnableAdvancedSoundOptions() then
		local button = ISButton:new(splitpoint + 20, y + self.addY, 100, 25, getText("GameSound_ButtonAdvanced"), self, self.onGameSounds)
		button:initialise()
		button:instantiate()
		self.mainPanel:addChild(button)
		self.mainPanel:insertNewLineOfButtons(button)
	elseif getDebug() then
		local button = ISButton:new(splitpoint + 20, y + self.addY, 100, 25, getText("GameSound_ButtonReload"), self, self.onReloadGameSounds)
		button:initialise()
		button:instantiate()
		button.tooltip = getText("GameSound_ButtonReload_tt")
		self.mainPanel:addChild(button)
		self.mainPanel:insertNewLineOfButtons(button)
	end

	self.mainPanel:setScrollHeight(y + self.addY + 20)

    y = y + self.addY;

--    local label = ISLabel:new(splitpoint - 1, y, 20, "Mods folder", 1, 1, 1, 1, UIFont.Small, false);
--    label:initialise();
--    self.mainPanel:addChild(label);
--
--    self.modSaveTxt = ISTextEntryBox:new(getCore():getSaveFolder(), splitpoint + 20, y, self:getWidth()-splitpoint - 240, 20);
--    self.modSaveTxt:initialise();
--    self.modSaveTxt:instantiate();
--    self.modSaveTxt:setAnchorLeft(true);
--    self.modSaveTxt:setAnchorRight(true);
--    self.modSaveTxt:setAnchorTop(true);
--    self.modSaveTxt:setAnchorBottom(false);
--    self.mainPanel:addChild(self.modSaveTxt);

	----- KEY BINDING -----
	local reload = MainOptions.loadKeys();
	SurvivalGuideEntries.addEntry11();
	--
	self:addPage(getText("UI_optionscreen_keybinding"))

	y = 5;

	local keyTextElement = nil;
	local x = MainOptions.keyBindingLength + 30;
	self.keyButtonWidth = 120
	self.keyTickBoxes = {}
	local left = true;
	for i,v in ipairs(MainOptions.keys) do
		keyTextElement = {};

		if luautils.stringStarts(v.value, "[") then
			y = y + 15;
			if not left then
				y = y + 20;
				left = true
			end

			local sbarWidth = 13
			local hLine = HorizontalLine:new(50, y - 8, self.width - 50 * 2 - sbarWidth)
			hLine.anchorRight = true
			self.mainPanel:addChild(hLine)

			local label = ISLabel:new(100, y, fontHgtMedium, getText("UI_optionscreen_binding_" .. v.value:gsub("%[", ""):gsub("%]", "")), 1, 1, 1, 1, UIFont.Medium);
			label:setX(50);
			label:initialise();
			label:setAnchorRight(true);
			self.mainPanel:addChild(label);

			keyTextElement.value = v.value;
			table.insert(MainOptions.keyText, keyTextElement);

			x = MainOptions.keyBindingLength + 30;
			y = y + fontHgtMedium + 10;
		else

--            print("UI_optionscreen_binding_" .. v.value .. " = \" " .. v.value .. "\",");
			local splitpoint = self:getWidth() / 2 ;
			local label = ISLabel:new(x, y, fontHgtSmall + 2, v.value, 1, 1, 1, 1, UIFont.Small);
			label:initialise();
			label:setAnchorLeft(false)
			label:setAnchorRight(true);
            label:setTranslation(getText("UI_optionscreen_binding_" .. v.value));
			self.mainPanel:addChild(label);

			local btn = ISButton:new(x + 10, y, self.keyButtonWidth, fontHgtSmall + 2, getKeyName(tonumber(v.key)), self, MainOptions.onKeyBindingBtnPress);
			btn.internal = v.value;
			btn:initialise();
			btn:instantiate();
--~ 			btn:setAnchorRight(true);
			self.mainPanel:addChild(btn);

			keyTextElement.txt = label;
			keyTextElement.keyCode = tonumber(v.key) or 0
			keyTextElement.btn = btn;
			keyTextElement.left = left
			table.insert(MainOptions.keyText, keyTextElement);
		
			if v.value == "ManualFloorAtk" then
				-- MANUAL FLOOR ATK TOGGLE
				y = y + fontHgtSmall + 2 + 2;
				local toggleAutoProneAtk = ISTickBox:new(x + 10, y, 300, 20, "HELLO?")
				toggleAutoProneAtk.choicesColor = {r=1, g=1, b=1, a=1}
				toggleAutoProneAtk:initialise()
				toggleAutoProneAtk.tooltip = getText("IGUI_ToggleAutoProneAtkTooltip", getKeyName(getCore():getKey("ManualFloorAtk")), getKeyName(getCore():getKey("Melee"))),
				-- Must addChild *before* addOption() or ISUIElement:getKeepOnScreen() will restrict y-position to screen height
				self.mainPanel:addChild(toggleAutoProneAtk)
				toggleAutoProneAtk:addOption(getText("IGUI_ToggleAutoProneAtk"))
				self.mainPanel:insertNewLineOfButtons(toggleAutoProneAtk)
				self.mainPanel:setScrollHeight(y + 50);
				
				gameOption = GameOption:new('autoProneAtk', toggleAutoProneAtk)
				function gameOption.toUI(self)
					local box = self.control
					box:setSelected(1, getCore():isOptionAutoProneAtk())
					box.options[1] = getText("IGUI_ToggleAutoProneAtk")
				end
				function gameOption.apply(self)
					local box = self.control
					getCore():setOptionAutoProneAtk(box:isSelected(1))
				end
				self.gameOptions:add(gameOption)
				y = y + 2;
				
				toggleAutoProneAtk.isLeftColumn = left
				table.insert(self.keyTickBoxes, toggleAutoProneAtk)
			end
		
			if v.value == "Run" then
				-- RUN KEY TOGGLE
				y = y + fontHgtSmall + 2 + 2;
				local toggleToRunTickbox = ISTickBox:new(x + 10, y, 300, 20, "HELLO?")
				toggleToRunTickbox.choicesColor = {r=1, g=1, b=1, a=1}
				toggleToRunTickbox:initialise()
				-- Must addChild *before* addOption() or ISUIElement:getKeepOnScreen() will restrict y-position to screen height
				self.mainPanel:addChild(toggleToRunTickbox)
				toggleToRunTickbox:addOption(getText("IGUI_ToggleToRun", getKeyName(getCore():getKey("Run"))))
				self.mainPanel:insertNewLineOfButtons(toggleToRunTickbox)
				self.mainPanel:setScrollHeight(y + 50);

				gameOption = GameOption:new('toggleToRun', toggleToRunTickbox)
				function gameOption.toUI(self)
					local box = self.control
					box:setSelected(1,getCore():isToggleToRun())
					local runKeyName = getKeyName(getCore():getKey("Run"))
					box.options[1] = getText("IGUI_ToggleToRun", runKeyName)
					self.gameOptions:get("dblTapRunToSprint").control.options[1] = getText("UI_optionscreen_DblTapRunToSprint", runKeyName)
				end
				function gameOption.apply(self)
					local box = self.control
					getCore():setToggleToRun(box.selected[1])
				end
				self.gameOptions:add(gameOption)
				y = y + 2;

				toggleToRunTickbox.isLeftColumn = left
				table.insert(self.keyTickBoxes, toggleToRunTickbox)
			end

		-- adding touble tab shift option
			if v.value == "Sprint" then
				self.sprintBtn = btn;
				y = y + fontHgtSmall + 2 + 2;
				local tblTapSprint = ISTickBox:new(x + 10, y, 300, 20, "");
				tblTapSprint.selected[1] = getCore():isOptiondblTapJogToSprint();
				self.sprintBtn.enable = not getCore():isOptiondblTapJogToSprint();
				tblTapSprint.choicesColor = {r=1, g=1, b=1, a=1};
				tblTapSprint:initialise();
				local runKeyName = getKeyName(getCore():getKey("Run"))
				tblTapSprint:addOption(getText("UI_optionscreen_DblTapRunToSprint", runKeyName), "");
				tblTapSprint.tooltip = getText("UI_optionscreen_DblTapRunToSprintTooltip", runKeyName, runKeyName):gsub("\\n", "\n");
				self.mainPanel:addChild(tblTapSprint);
				self.mainPanel:insertNewLineOfButtons(tblTapSprint)
				y = y + fontHgtSmall + 2 + 2;

				gameOption = GameOption:new('dblTapRunToSprint', tblTapSprint)
				function gameOption.toUI(self)
					local box = self.control
					box:setSelected(1,getCore():isOptiondblTapJogToSprint())
				end
				function gameOption.onChange(self, index, selected)
					MainOptions.instance.sprintBtn.enable = not selected
				end
				function gameOption.apply(self)
					local box = self.control
					getCore():setOptiondblTapJogToSprint(box.selected[1])
				end
				self.gameOptions:add(gameOption)

				tblTapSprint.isLeftColumn = left
				table.insert(self.keyTickBoxes, tblTapSprint)

				-- SPRINT KEY TOGGLE
				local toggleToSprintTickbox = ISTickBox:new(x + 10, y, 300, 20, "HELLO?")
				toggleToSprintTickbox.choicesColor = {r=1, g=1, b=1, a=1}
				toggleToSprintTickbox:initialise()
				-- Must addChild *before* addOption() or ISUIElement:getKeepOnScreen() will restrict y-position to screen height
				self.mainPanel:addChild(toggleToSprintTickbox)
				toggleToSprintTickbox:addOption(getText("IGUI_ToggleToSprint", getKeyName(getCore():getKey("Sprint"))))
				self.mainPanel:insertNewLineOfButtons(toggleToSprintTickbox)
				self.mainPanel:setScrollHeight(y + 50);

				gameOption = GameOption:new('toggleToSprint', toggleToSprintTickbox)
				function gameOption.toUI(self)
					local box = self.control
					box:setSelected(1,getCore():isToggleToSprint())
					box.options[1] = getText("IGUI_ToggleToSprint", getKeyName(getCore():getKey("Sprint")))
				end
				function gameOption.apply(self)
					local box = self.control
					getCore():setToggleToSprint(box.selected[1])
				end
				self.gameOptions:add(gameOption)
				y = y + 2;

				toggleToSprintTickbox.isLeftColumn = left
				table.insert(self.keyTickBoxes, toggleToSprintTickbox)
			end

			if v.value == "Aim" then
				-- AIM KEY TOGGLE
				y = y + fontHgtSmall + 2 + 2;
				local toggleAimTickbox = ISTickBox:new(x + 10, y, 300, 20, "HELLO?")
				toggleAimTickbox.choicesColor = {r=1, g=1, b=1, a=1}
				toggleAimTickbox:initialise()
				-- Must addChild *before* addOption() or ISUIElement:getKeepOnScreen() will restrict y-position to screen height
				self.mainPanel:addChild(toggleAimTickbox)
				toggleAimTickbox:addOption(getText("UI_optionscreen_ToggleToAim", getKeyName(getCore():getKey("Aim"))))
				self.mainPanel:insertNewLineOfButtons(toggleAimTickbox)
				self.mainPanel:setScrollHeight(y + 50);

				gameOption = GameOption:new('toggleToAim', toggleAimTickbox)
				function gameOption.toUI(self)
					local box = self.control
					box:setSelected(1, getCore():isToggleToAim())
					box.options[1] = getText("UI_optionscreen_ToggleToAim", getKeyName(getCore():getKey("Aim")))
				end
				function gameOption.apply(self)
					local box = self.control
					getCore():setToggleToAim(box:isSelected(1))
				end
				self.gameOptions:add(gameOption)
				y = y + 2;

				toggleAimTickbox.isLeftColumn = left
				table.insert(self.keyTickBoxes, toggleAimTickbox)
			end

			if x > MainOptions.keyBindingLength + 30 then
				x = MainOptions.keyBindingLength + 30;
				y = y + fontHgtSmall + 2 + 2;
				left = true;
			else
				x = splitpoint + MainOptions.keyBindingLength + 30;
				left = false;
			end
		end
	end

	self.mainPanel:setScrollHeight(y + 50);

	y = y + 40;

	----- ACCESSIBILITY -----
	
	self:addPage(getText("UI_optionscreen_accessibility"))
	y = 20;
	x = splitpoint
	self.addY = 0

	-- SINGLE CONTEXT MENU
	label = ISLabel:new(splitpoint, y + self.addY, fontHgtSmall, getText("UI_optionscreen_SingleContextMenu"), 1, 1, 1, 1, UIFont.Small, false)
	label:initialise()
	self.mainPanel:addChild(label)
	local singleContextMenu = ISTickBox:new(splitpoint + 20, y + self.addY, 200, 20, "HELLO?")
	singleContextMenu.choicesColor = {r=1, g=1, b=1, a=1}
	singleContextMenu:initialise();
	self.mainPanel:addChild(singleContextMenu)
	self.mainPanel:insertNewLineOfButtons(singleContextMenu)
	-- Must addChild *before* addOption() or ISUIElement:getKeepOnScreen() will restrict y-position to screen height
	for i = 1,4 do
		singleContextMenu:addOption(getText("UI_optionscreen_player"..i), nil)
	end
	self.addY = self.addY + singleContextMenu:getHeight() + 4

	gameOption = GameOption:new('singleContextMenu', singleContextMenu)
	function gameOption.toUI(self)
		local box = self.control
		for i = 1,4 do
			box:setSelected(i, getCore():getOptionSingleContextMenu(i-1))
		end
	end
	function gameOption.apply(self)
		local box = self.control
		for i = 1,4 do
			getCore():setOptionSingleContextMenu(i-1, box:isSelected(i))
		end
	end
	self.gameOptions:add(gameOption)

	-- RADIAL MENU KEY TOGGLE
	local radialMenuToggle = self:addYesNo(splitpoint, y, 300, 20, getText("IGUI_RadialMenuKeyToggle"))

	gameOption = GameOption:new('radialMenuKeyToggle', radialMenuToggle)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1,getCore():getOptionRadialMenuKeyToggle())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionRadialMenuKeyToggle(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	-- RELOAD RADIAL INSTANT
	local reloadRadialInstant = self:addYesNo(splitpoint, y, 300, 20, getText("IGUI_ReloadRadialInstant"))

	gameOption = GameOption:new('reloadRadialInstant', reloadRadialInstant)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1,getCore():getOptionReloadRadialInstant())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionReloadRadialInstant(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- CYCLE CONTAINER KEY -----
	local cycleContainerKey = self:addCombo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_CycleContainerKey"),
		{ getText("UI_optionscreen_CycleContainerKey1"), getText("UI_optionscreen_CycleContainerKey2"),
		getText("UI_optionscreen_CycleContainerKey3") }, 1)
    cycleContainerKey:setToolTipMap({ defaultTooltip = getText("UI_optionscreen_CycleContainerKey_tt") })

	gameOption = GameOption:new('cycleContainerKey', cycleContainerKey)
	function gameOption.toUI(self)
		local box = self.control
		local values = { "control", "shift", "control+shift" }
		box.selected = luautils.indexOf(values, getCore():getOptionCycleContainerKey())
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			local values = { "control", "shift", "control+shift" }
			getCore():setOptionCycleContainerKey(values[box.selected])
		end
	end
	self.gameOptions:add(gameOption)

	-- DROP ITEMS ON SQUARE CENTER
	local dropItemsOnSquareCenter = self:addYesNo(splitpoint, y, 300, 20, getText("IGUI_DropItemsOnSquareCenter"))

	gameOption = GameOption:new('dropItemsOnSquareCenter', dropItemsOnSquareCenter)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1,getCore():getOptionDropItemsOnSquareCenter())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionDropItemsOnSquareCenter(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	-- TIMED ACTION GAME SPEED RESET
	local timedActionSpeedReset = self:addYesNo(splitpoint, y, 300, 20, getText("UI_optionscreen_TimedActionGameSpeedReset"))

	gameOption = GameOption:new('timedActionGameSpeedReset', timedActionSpeedReset)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1,getCore():getOptionTimedActionGameSpeedReset())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionTimedActionGameSpeedReset(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	-- SHOULDER BUTTON CONTAINER SWITCH
	local shoulderButton = self:addCombo(splitpoint, y, 300, 20, getText("UI_optionscreen_ShoulderButtonContainerSwitch"),
		{
			getText("UI_optionscreen_ShoulderButtonContainerSwitch1"),
			getText("UI_optionscreen_ShoulderButtonContainerSwitch2"),
			getText("UI_optionscreen_ShoulderButtonContainerSwitch3")
		},
		1)

	gameOption = GameOption:new('shoulderButtonContainerSwitch', shoulderButton)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionShoulderButtonContainerSwitch()
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionShoulderButtonContainerSwitch(box.selected)
		end
	end
	self.gameOptions:add(gameOption)

	-- ENABLE LEFT JOYSTICK RADIAL MENU
	local leftJoystickRadial = self:addYesNo(splitpoint, y, 300, 20, getText("UI_optionscreen_EnableLeftJoystickRadialMenu"))

	gameOption = GameOption:new('enableLeftJoystickRadialMenu', leftJoystickRadial)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1,getCore():getOptionEnableLeftJoystickRadialMenu())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionEnableLeftJoystickRadialMenu(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)


	-- SHOW PROGRESS BAR
--	local progressBar = self:addTickBox(splitpoint, y, 300, 20)
--	progressBar:addOption(getText("UI_optionscreen_ShowProgressBar"))
--	self.addY = self.addY + progressBar:getHeight()
--
--	gameOption = GameOption:new('showProgressBar', progressBar)
--	function gameOption.toUI(self)
--		local box = self.control
--		box:setSelected(1, getCore():isOptionProgressBar())
--	end
--	function gameOption.apply(self)
--		local box = self.control
--		getCore():setOptionProgressBar(box:isSelected(1))
--	end
--	self.gameOptions:add(gameOption)

	----- AUTO DRINK -----
    local autoDrink = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_AutoDrink"));

	gameOption = GameOption:new('autoDrink', autoDrink)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionAutoDrink())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionAutoDrink(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- LEAVE KEY IN IGNITION -----
    local keyInIgnition = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_LeaveKeyInIgnition"));

	gameOption = GameOption:new('keyInIgnition', keyInIgnition)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionLeaveKeyInIgnition())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionLeaveKeyInIgnition(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- CLICK TO WALK TO NEARBY CONTAINERS -----
---
	local autoWalkContainer = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_AutoWalkContainer"));
	autoWalkContainer.tooltip = getText("UI_optionscreen_AutoWalkContainer_tt");

	gameOption = GameOption:new('autoWalkContainer', autoWalkContainer)
	function gameOption.toUI(self)
		local box = self.control
		box:setSelected(1, getCore():getOptionAutoWalkContainer())
	end
	function gameOption.apply(self)
		local box = self.control
		getCore():setOptionAutoWalkContainer(box:isSelected(1))
	end
	self.gameOptions:add(gameOption)

	----- SET GOOD HIGHLIGHT COLOR -----

	local ghc = getCore():getGoodHighlitedColor()
	local rgba = {r = ghc:getR(), g = ghc:getG(), b = ghc:getB(), a = 1}
	self.goodHighColor = self:addColorButton(splitpoint, y, getText("UI_optionscreen_goodHighlightColor"), rgba, MainOptions.onGoodHighlightColor)

	if MainScreen.instance.inGame then
		self.goodHighColor.tooltip = getText("UI_optionscreen_needreboot")
	end

	self.colorPicker3 = ISColorPicker:new(0, 0)
	self.colorPicker3:initialise()
	self.colorPicker3.pickedTarget = self
	self.colorPicker3.resetFocusTo = self
	self.colorPicker3:setInitialColor(getCore():getGoodHighlitedColor());

	gameOption = GameOption:new('goodHighColor', self.goodHighColor)
	function gameOption.toUI(self)
		local color = getCore():getGoodHighlitedColor()
		self.control.backgroundColor = {r = color:getR(), g = color:getG(), b = color:getB(), a = 1}
	end
	function gameOption.apply(self)
		local color = self.control.backgroundColor
		local current = getCore():getGoodHighlitedColor()
		if current:getR() == color.r and current:getG() == color.g and current:getB() == color.b then
			return
		end
		getCore():setGoodHighlitedColor(ColorInfo.new(color.r, color.g, color.b, 1))
	end
	self.gameOptions:add(gameOption)

	----- SET BAD HIGHLIGHT COLOR -----

	local bhc = getCore():getBadHighlitedColor()
	local rgba = {r = bhc:getR(), g = bhc:getG(), b = bhc:getB(), a = 1}
	self.badHighColor = self:addColorButton(splitpoint, y, getText("UI_optionscreen_badHighlightColor"), rgba, MainOptions.onBadHighlightColor)

	if MainScreen.instance.inGame then
		self.badHighColor.tooltip = getText("UI_optionscreen_needreboot")
	end

	self.colorPicker4 = ISColorPicker:new(0, 0)
	self.colorPicker4:initialise()
	self.colorPicker4.pickedTarget = self
	self.colorPicker4.resetFocusTo = self
	self.colorPicker4:setInitialColor(getCore():getBadHighlitedColor());

	gameOption = GameOption:new('badHighColor', self.badHighColor)
	function gameOption.toUI(self)
		local color = getCore():getBadHighlitedColor()
		self.control.backgroundColor = {r = color:getR(), g = color:getG(), b = color:getB(), a = 1}
	end
	function gameOption.apply(self)
		local color = self.control.backgroundColor
		local current = getCore():getBadHighlitedColor()
		if current:getR() == color.r and current:getG() == color.g and current:getB() == color.b then
			return
		end
		getCore():setBadHighlitedColor(ColorInfo.new(color.r, color.g, color.b, 1))
	end
	self.gameOptions:add(gameOption)


	--[[
        ----- IGNORE PRONE ZOMBIE DIST -----
        local ignoreProne = self:addCombo(splitpoint, y, 300, 20, getText("UI_optionscreen_IgnoreProneZombieRange"),
            {
                getText("UI_optionscreen_IgnoreProneZombieRange1"),
                getText("UI_optionscreen_IgnoreProneZombieRange2"),
                getText("UI_optionscreen_IgnoreProneZombieRange3"),
                getText("UI_optionscreen_IgnoreProneZombieRange4"),
                getText("UI_optionscreen_IgnoreProneZombieRange5")
            },
            2)
        ignoreProne:setToolTipMap({ defaultTooltip = getText("UI_optionscreen_IgnoreProneZombieRange_tt") })

        gameOption = GameOption:new('ignoreProneZombieRange', ignoreProne)
        function gameOption.toUI(self)
            local box = self.control
            box.selected = getCore():getOptionIgnoreProneZombieRange()
        end
        function gameOption.apply(self)
            local box = self.control
            if box.options[box.selected] then
                getCore():setOptionIgnoreProneZombieRange(box.selected)
            end
        end --]]
--	self.gameOptions:add(gameOption)

	-----
	self.mainPanel:setScrollHeight(y + self.addY + 20)

	----- CONTROLLER -----
	self:addPage(getText("UI_optionscreen_controller"))
	y = 20;
	x = 64

	label = ISLabel:new(x, y, fontHgtSmall, getText("UI_optionscreen_controller_tip"), 1, 1, 1, 1, UIFont.Small, true)
	label:initialise()
	self.mainPanel:addChild(label)

    local controllerTickBox = ISTickBox:new(x + 20, label:getY() + label:getHeight() + 10, 200, 20, "HELLO?")
    controllerTickBox.choicesColor = {r=1, g=1, b=1, a=1}
    controllerTickBox:initialise();
    self.mainPanel:addChild(controllerTickBox)

	for i = 0, getControllerCount()-1 do
		if isControllerConnected(i) then
			local name = getControllerName(i)
			controllerTickBox:addOption(name, nil)
		end
	end

	gameOption = GameOption:new('controllers', controllerTickBox)
	function gameOption.toUI(self)
		local box = self.control
		box:clearOptions()
		for i = 1,getControllerCount() do
			if isControllerConnected(i-1) then
				local name = getControllerName(i-1)
				local guid = getControllerGUID(i-1)
				local index = box:addOption(name, i-1)
				local active = getCore():getOptionActiveController(guid)
				box:setSelected(index, active)
			end
		end
	end
	function gameOption.apply(self)
		local box = self.control
		for i = 1,box:getOptionCount() do
			local controllerIndex = box:getOptionData(i)
			getCore():setOptionActiveController(controllerIndex, box:isSelected(i))
		end
	end
	self.gameOptions:add(gameOption)

	y = controllerTickBox:getY() + controllerTickBox:getHeight()

	local panel = ISPanel:new(x, y, self.width / 2 - x, 100)
	panel:noBackground()
	self.mainPanel:addChild(panel)
	self.stuffBelowControllerTickbox = panel

	local btn = ISButton:new(0, 10, 120, fontHgtSmall + 2 * 2, getText("UI_optionscreen_controller_reload"), self, MainOptions.ControllerReload)
	btn:initialise()
	btn:instantiate()
	self.stuffBelowControllerTickbox:addChild(btn)
	
	y = btn:getY() + btn:getHeight()
	
	label = ISLabel:new(0, y + 10, fontHgtSmall, getText("UI_optionscreen_gamepad_sensitivity"), 1, 1, 1, 1, UIFont.Medium, true)
	label:initialise()
	self.stuffBelowControllerTickbox:addChild(label)
	
	y = label:getY() + label:getHeight()

	local buttonSize = fontHgtSmall
	self.btnJoypadSensitivityM = ISButton:new(0, y + 10, buttonSize, buttonSize, "-", self, MainOptions.joypadSensitivityM)
	self.btnJoypadSensitivityM:initialise()
	self.btnJoypadSensitivityM:instantiate()
	self.btnJoypadSensitivityM:setEnable(false)
	self.stuffBelowControllerTickbox:addChild(self.btnJoypadSensitivityM)
	self.labelJoypadSensitivity = ISLabel:new(self.btnJoypadSensitivityM:getX()+self.btnJoypadSensitivityM:getWidth()+10, y + 10, fontHgtSmall, getText("UI_optionscreen_select_gamepad"), 1, 1, 1, 1, UIFont.Small, true)
	self.labelJoypadSensitivity:initialise()
	self.stuffBelowControllerTickbox:addChild(self.labelJoypadSensitivity)
	self.btnJoypadSensitivityP = ISButton:new(self.labelJoypadSensitivity:getX()+self.labelJoypadSensitivity:getWidth()+10, y + 10, buttonSize, buttonSize, "+", self, MainOptions.joypadSensitivityP)
	self.btnJoypadSensitivityP:initialise()
	self.btnJoypadSensitivityP:instantiate()
	self.btnJoypadSensitivityP:setEnable(false)
	self.stuffBelowControllerTickbox:addChild(self.btnJoypadSensitivityP)


	local panel = ISControllerTestPanel:new(self.width / 2, 20, (self.width - 64 - (self.width / 2)), self.mainPanel.height - 20 - 20)
	panel:setAnchorRight(true)
	panel:setAnchorBottom(true)
	panel.drawBorder = true
	panel.mainOptions = self
	panel:initialise()
	self.mainPanel:addChild(panel)
	self.controllerTestPanel = panel

	self.mainPanel:insertNewLineOfButtons(controllerTickBox, self.controllerTestPanel.combo)
	self.mainPanel:insertNewLineOfButtons(btn)
	self.mainPanel:insertNewLineOfButtons(self.btnJoypadSensitivityM, self.btnJoypadSensitivityP)
	
--[[
	----- GAMEPLAY PAGE -----
	self:addPage(getText("UI_optionscreen_game"))
	
	y = 30;
	self.addY = 0;

	----- RELOADING -----
	local label = ISLabel:new(self.width / 3 - 120, y+5, fontHgtMedium, getText("UI_optionscreen_reloading"), 1, 1, 1, 1, UIFont.Medium, true)
	self.mainPanel:addChild(label);
	local difficulties = {getText("UI_optionscreen_easy"), getText("UI_optionscreen_normal"), getText("UI_optionscreen_hardcore")};--> Stormy
	MainOptions.reloadLabel = ISLabel:new(self.width / 3 - 100, label:getBottom(), fontHgtSmall * 3, '', 1, 1, 1, 1, UIFont.Small);--> Stormy
	self.mainPanel:addChild(MainOptions.reloadLabel);--> Stormy
	local difficultyCombo = self:addCombo(splitpoint, y + 5 + label:getHeight() + MainOptions.reloadLabel:getHeight(), comboWidth, 20, getText("UI_optionscreen_reloadDifficulty"), difficulties, 1);--> Stormy
	
	gameOption = GameOption:new('reloadDifficulty', difficultyCombo)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionReloadDifficulty()
		MainOptions.instance.reloadLabel.name = ReloadManager[1]:getDifficultyDescription(box.selected):gsub("\\n", "\n")
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionReloadDifficulty(box.selected)
		end
	end
	function gameOption:onChange(box)
		MainOptions.instance.reloadLabel.name = ReloadManager[1]:getDifficultyDescription(box.selected):gsub("\\n", "\n")
	end
	self.gameOptions:add(gameOption)
	
	----- RACKING PROGRESS -----
	local combo = self:addCombo(splitpoint, y + 5 + label:getHeight() + MainOptions.reloadLabel:getHeight(), comboWidth, 20, getText("UI_optionscreen_rack_progress"), {getText("UI_Yes"), getText("UI_No")}, 1)
	local map = {};
	map["defaultTooltip"] = getText("UI_optionscreen_rack_progress_tt");
	combo:setToolTipMap(map);
	
	gameOption = GameOption:new('rackProgress', combo)
	function gameOption.toUI(self)
		local box = self.control
		box.selected = getCore():getOptionRackProgress() and 1 or 2
	end
	function gameOption.apply(self)
		local box = self.control
		if box.options[box.selected] then
			getCore():setOptionRackProgress(box.selected == 1)
		end
	end
	self.gameOptions:add(gameOption)
--]]
    self:addPage(getText("UI_optionscreen_multiplayer"))

    y = 20
    self.addY = 0;

    local showUsernameTickbox = self:addYesNo(splitpoint, y, comboWidth, 20, getText("UI_optionscreen_showUsername"));
    showUsernameTickbox.tooltip = getText("UI_optionscreen_showUsernameTooltip");
    self.mainPanel:addChild(showUsernameTickbox);

    gameOption = GameOption:new('showUsername', showUsernameTickbox)
    function gameOption.toUI(self)
        local box = self.control;
        local selected = true;
        box:setSelected(1, getCore():isShowYourUsername());
    end
    function gameOption.apply(self)
        local box = self.control;
        getCore():setShowYourUsername(box:isSelected(1));
    end
    self.gameOptions:add(gameOption)

    local mpc = getCore():getMpTextColor()
    local rgba = {r = mpc:getR(), g = mpc:getG(), b = mpc:getB(), a = 1}
    self.mpColor = self:addColorButton(splitpoint, y, getText("UI_optionscreen_personalTextColor"), rgba, MainOptions.onMPColor);

    self.colorPicker = ISColorPicker:new(0, 0)
    self.colorPicker:initialise()
    self.colorPicker.pickedTarget = self
    self.colorPicker.resetFocusTo = self
    self.colorPicker:setInitialColor(getCore():getMpTextColor());

    gameOption = GameOption:new('mpTextColor', self.mpColor)
    function gameOption.toUI(self)
        local color = getCore():getMpTextColor()
        self.control.backgroundColor = {r = color:getR(), g = color:getG(), b = color:getB(), a = 1}
    end
    function gameOption.apply(self)
        local color = self.control.backgroundColor
        local current = getCore():getMpTextColor()
        if current:getR() == color.r and current:getG() == color.g and current:getB() == color.b then
            return
        end
        getCore():setMpTextColor(ColorInfo.new(color.r, color.g, color.b, 1))
        if isClient() and MainScreen.instance.inGame then
            getPlayer():setSpeakColourInfo(getCore():getMpTextColor())
            sendPersonalColor(getPlayer())
        end
    end
    self.gameOptions:add(gameOption)
    
    --XXX This is where Native Settings modification of create() begins
    --******************************************************************
    self:addPage(getText("UI_Native_Settings_PageTitle"))
    y = 0
    self.addY = 20 --add some space for our first HorizontalLine

    for _, ModOptions in ipairs(NativeSettings.mods) do
        if not ModOptions.isHidden() then
            self:addHorizontalLine(y, ModOptions.modName)

            for _, NativeSetting in ipairs(ModOptions.settings) do
                if not NativeSetting.isHidden() then
                    gameOption = NativeSetting:addToOptionsPage(self)
                    self.gameOptions:add(gameOption)
                end
            end
        end
    end

	self.mainPanel:setScrollHeight(y + self.addY + 20)


    --******************************************************************
	--gameOption = GameOption:new('soundVolume', control)
	--function gameOption.toUI(self)
	--	local volume = getCore():getOptionSoundVolume()
	--	volume = math.min(10, math.max(0, volume))
	--	self.control:setVolume(volume)
	--end
	--function gameOption.apply(self)
	--	getCore():setOptionSoundVolume(self.control:getVolume())
	--end

	self:setVisible(false);

	if reload then
		-- we erase our previous file (by setting the append boolean to false);
		local fileOutput = getFileWriter("keys.ini", true, false)
		fileOutput:write("VERSION="..tostring(MainOptions.KEYS_VERSION).."\r\n")
		for i,v in ipairs(MainOptions.keyText) do
			-- if it's a label (like [Player Visual])
			if v.value then
				fileOutput:write(v.value .. "\r\n")
			else
				fileOutput:write(v.txt:getName() .. "=" .. v.keyCode .. "\r\n")
				getCore():addKeyBinding(v.txt:getName(), v.keyCode)
			end
		end
		fileOutput:close()
	end

	self:centerKeybindings()
	self:centerTabChildrenX(getText("UI_optionscreen_display"))
	self:centerTabChildrenX(getText("UI_optionscreen_audio"))
	self:centerTabChildrenX(getText("UI_optionscreen_accessibility"))
	self:centerTabChildrenX(getText("UI_optionscreen_multiplayer"))
end
