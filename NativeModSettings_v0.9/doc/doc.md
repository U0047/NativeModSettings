# NATIVE MOD SETTINGS DOCUMENTATION (RELEASE v0.9)
https://github.com/U0047/NativeModSettings/
Please report bugs to u_0047@protonmail.com or open an issue on the [github repo](https://www,github.com/u0047/NativeModSettings/issue)


## Table of Contents 

1. [Overview](#Overview)
2. [Installation](#Installation)
3. [About Multiplayer Use](#about-multiplayer-use)
4. [Quick Guide](#quick-guide)
5. [Settings Setup](#settings-setup)
6. [Disabling and Hiding Settings](#disabling-and-hiding-Settings)
7. [Custom Settings](#custom-settings)
8. [Disabling and Hiding Settings](#disabling-and-hiding-settings)
9. [Appendix](#appendix)
	1. [The Nitty-Gritty Details](#the-nitty-gritty-details)
	2. [Miscellaneous Functions](#miscellanoeous-functions)

---

## Overview
Native Mod Settings is a Zomboid modder's resource that gives mod developers the ability to add a variety of user-friendly, seamless mod settings to the Main Options page (accessed when clicking 'Options' from the Intro Screen or Pause Screen), under a new 'Native Mod Settings' tab. This allows mod users to easily configure mods without needing to edit mod files directly.


Native Mod Settings currently offers the following settings:
- `YesNoBox` - a boolean tick mark box
- `YesNoMultiBox` - a titled list of boolean tick mark boxes
- `ColorBox` - a button that allows users to pick from an assortment of colors when clicked
- `ComboBox` - a drop-down menu allowing selection from a list of items
- `Slider` - a draggable slider

Native Mod Settings also gives mod developers the ability to create and add [custom settings](custom-settings).

---

## Installation
Native Mod Settings can be installed like most mods; by subscribing to the Steam Workshop or through [manual installation](https://pzwiki.net/wiki/Installing_mods).

Native Mod Settings must be enabled in the main menu's ['Mods' page as well as in individual savefiles' mods](https://pzwiki.net/wiki/Using_mods).

---

## A Word About Multiplayer Use
At it's current version *(release v0.9),* Native Mod Settings **is completely untested** in multiplayer. 

While problems are not anticipated, Native Mod Settings makes **zero** guarantee that Native Mod Settings will work in multiplayer.

While security would more likely than not depend on how Native Mod Settingss is utilized by mod developers, Native Mod Settings makes **zero** guarantee that it's settings are secure for multiplayer use.

---

## Quick Guide
*This quick guide introduces the basic concepts and usage of Native Mod Settings, by showing how to create a `YesNoBox` and add it to the Options Screen.*

Every mod that utilizes Native Mod Settings needs to create a `ModSettings` object with a title. The `ModSettings` object acts as a container for your mod's settings, and is rendered as it's own section in the Mod Settings page, with a title and horizontal line divider.

```lua
require('NativeSettings')

Settings = ModSettings:new('My Mod Settings Title')

```

Now that our `ModSettings` container is created, we can create a `YesNoBox` that modifies a variable:

```lua
myBooleanVariable = false
MyYesNoBox = YesNoBox:new('My YesNoBox Title')
function MyYesNoBox.toUI(box)
	box:setSelected(1, myBooleanVariable)
end

function MyYesNoBox.apply(box)
	if box:isSelected(1) then
		myBooleanVariable = True
	else
		myBooleanVariable = False
	end
end

```
While each setting has a slightly different implementation, every setting object requires a few things:

- A `name`, to be displayed as a title for the setting.
- A `toUI` function, that takes a parameter `box`.
- An `apply` function, that takes a parameter `box`. 

The `toUI` function dictates how the setting should be displayed when a user enters the Options screen, and the `apply` function dictates what should happen when users click 'Accept' or 'Apply' in the Options screen.

Both `toUI` and `apply` require a parameter `box` . `box` is a vanilla UI component (such as a tickbox or a drop-down menu) that Native Mod Settings wraps. As of now, all settings wrap one of these vanilla UI components, who have their own methods and attributes.

*Note: While the examples in ['Settings Setup'](#settings-setup) are sufficient enough for learning basic setting creation, it is recommended that mod developers consult the game file of the UI component that is being wrapped by each setting (listed in ['Settings Setup'](#settings-setup) ) for a better understanding of their methods and attributes.*

Now we need to add our `YesNoBox` to our `ModSettings` container, and then add our `ModSettings` container to the `NativeSettings` class (which acts as a container for all mods) with `NativeSettings.addModSettings`.

```lua
Settings:addOption(MyYesNoBox)
NativeSettings.addModSettings(Settings)
```
In order to be displayed in the settings page, all settings will need to be added to our `ModSettings` container before they are added to `NativeSettings` with `NativeSettings.addModSettings`

---
## Settings Setup

#### YesNoBox:new(name, tooltip)
Returns YesNoBox, a simple boolean tick box.
*wraps: client/ISUI/ISTickBox*

##### parameters
- name - the title of the YesNoBox.
- tooltip *(optional)* - a hint that is displayed when users mouse-over the setting.

```lua
require('NativeSettings')

myBooleanVariable = false

MyYesNoBox = YesNoBox:new('MyYesNoBox', 'My Tooltip')
function MyYesNoBox.toUI(box)
	--set the first (and only) box to the value of MyBooleanVariable
	box:setSelected(1, MyBooleanVariable)
end

function MyYesNoBox.apply(box)
	--if the first(and only) box is selected
	if box:isSelected(1) then
		myBooleanVariable = true
	else
		myBooleanVariable = false
	end
end

MySettings = ModSettings:new('My Settings')
MySettings:addOption(MyYesNoBox)

NativeSettings.addModSettings(MySettings)
```


#### YesNoMultiBox:new(name, YesNoBoxes, tooltip)
Returns YesNoMultiBox, a list of `YesNoBox`es with its own title .
*wraps: client/ISUI/ISTickBox*

##### parameters 
- name - the title of the YesNoMultiBox.
- YesNoBoxes - a table of `YesNoBox`s.
- tooltip *(optional)* - a hint that is displayed when users mouse-over the setting.


```lua
require('NativeSettings')

MyBooleanVariable1 = false
MyBooleanVariable2 = true

--create our YesNoBoxes
MyYesNoBox1 = YesNoBox:new('My YesNoBox 1')
MyYesNoBox2 = YesNoBox:new('My YesNoBox 2')
MyYesNoBoxes = {MyYesNoBox1, MyYesNoBox2}

--create a YesNoMultiBox and add our YesNoBoxes to it
YesNoMultiBox = YesNoMultiBox:new('My YesNoMultiBox', MyYesNoBoxes)

function YesNoMultiBox.toUI(box)
	--set MyYesNoBox1's selected status to MyBooleanVariable1
	box:setSelected(1, MyBooleanVariable1)
	--set MyYesNoBox2's selected status to MyBooleanVariable2
	box:setSelected(2, MyBooleanVariable2)
end

function YesNoMultiBox.apply(box)
	--set MyBooleanVariable1 based on MyYesNoBox1's selected status
	if box:isSelected(1) then
		MyBooleanVariable1 = true
	else
		MyBooleanVariable1 = false
	end
	
	--set MyBooleanVariable2 based on MyYesNoBox2's selected status
	if box:isSelected(2) then
		MyBooleanVariable2 = true
	else
		MyBooleanVariable2 = false
	end
end

MySettings = ModSettings:new('My Settings')
MySettings:addOption(MyYesNoMultiBox)

NativeSettings.addModSettings(MySettings)
```

#### ComboBox:new(name, options, tooltip)
Returns ComboBox, a drop down menu with selectable items.
*wraps: client/ISUI/ISComboBox*

##### parameters
- name - a string that will be displayed as the ComboBox's title.
- Options - a table of strings that will appear as items in the drop down menu.
- tooltip *(optional)* - a string that will display as a hint when users mouse-over the setting.

```lua
require('NativeSettings')

local myVariable = 2

local myOptions = {}
table.insert(myOptions, 'My option 1')
table.insert(myOptions, 'My option 2')

myComboBox = ComboBox:new('My Combo Box', myOptions)
function myComboBox.toUI(box)
	if myVariable == 1 then
		box.selected = 1
	elseif myVariable == 2:
		box.selected = 2
	end
end

function myComboBox.apply(box)
	if box.selected == 1 then
		myVariable = 1
	elseif box.selected == 2 then
		myVariable =2
	end
end

MySettings = ModSettings:new('My Settings')
MySettings:addOption(MyYesNoBox)

NativeSettings.addModSettings(MySettings)
```

#### ColorBox:new(name, rgba, tooltip)
Returns ColorBox, a button that opens a window with selectable colors when pressed.
*wraps: client/ISUI/ISButton*

##### parameters
- name - a string that will be displayed as the ColorBox's title.
- rgba- a table defining the color's initial button. includes the keys `r`, `g`, `b`, and `a`, all with numbers between 0 and 1 as values.
- tooltip *(optional)* - a string that will display as a hint when users mouse-over the setting.

```lua
require('NativeSettings')

local myColor = {r=0, g=0, b=0, a=1}
myColorBox = ColorBox:new('My ColorBox', myColor)
function myColorBox.toUI(box)
	box.backgroundColor = myColor --set button's color
end

function myColorBox.apply(box)
	local color = box.backgroundColor
	myColor.r = color.r
	myColor.g = color.g
	myColor.b = color.b
end

MySettings = ModSettings:new('My Settings')
MySettings:addOption(myColorBox)

NativeSettings.addModSettings(MySettings)
```

#### Slider:new(name, tooltip)
Returns Slider, a slider that returns a number between 0 and 10.
*wraps: client/ISUI/ISVolumeControl*

##### parameters
- name - a string that will be displayed as the Slider's title.
- tooltip *(optional)* - a string that will display as a hint when users mouse-over the setting.

```lua
require('NativeSettings') 

myIntVariable = 1
mySlider = Slider:new('my Slider')
function mySlider.toUI(box)
	--ensure our int is between 10 and 0
	myIntVariable = math.min(10, math.max(0, myIntVariable))
	--while the funciton is named setVolume(), it
	-- is simply a value setter 
	box:setVolume(myIntVariable)
end

function mySlider.apply(box)
	--while the function is named getVolume, it
	--is simply a value getter
	myIntVariable = box:getVolume()
end

MySettings = ModSettings:new('My Settings')
MySettings:addOption(myColorBox)

NativeSettings.addModSettings(MySettings)
```

---

## Disabling and Hiding Settings

Some settings will not make sense in certain contexts. For example, a `ComboBox` that allows users to change the current weather does not make sense if the user is idle in the Main Menu page, and not in-game. Settings can be disabled or completely hidden for these cases.

when a setting or `ModSettings` container should be hidden can be defined by creating a `isHidden` function for it:

```lua
local hiddenYesNoBox = YesNoBox.new('My Hidden YesNoBox')
function hiddenYesNoBox.isHidden()
	if <conditional> then
		return true
	end
end
```

Settings can (and in most cases should) be disabled, so they are still visible to users, but not configurable outside the desired context. Disabling each setting is implemented differently (and sometimes in an admittedly hack-y fashion):

##### ColorButton
``` lua
rgba = {r=1, g=1, b=1, a=1}
local ColorBox = ColorBox.new('My Disabled ColorBox', rgba)
function ColorBox.toUI(box)
if <conditional> then
	box:setEnable(true)
else
	box:setEnable(false)
end
```

##### ComboBox
```lua
local options = {'option 1', 'option 2'}
ComboBox = ComboBox.new('My Disabled ComboBox', options)
function ComboBox.toUI(box)
	if <conditional> then
		box.disabled = false
	else
		box.disabled = true
	end
```

##### YesNoBox
```lua
local myBoolean = false
YesNoBox = YesNoBox.new('My Disabled YesNoBox')
function YesNoBox.toUI(box)
	if <conditional> then
		box.enable = false
	else
		box.enable = true
	end 
end
```

Developers may also want to change the `borderColor` of the `box`, to make it's disabled status more explicit to users:

```lua
local myBoolean = false
YesNoBox = YesNoBox.new('My Disabled YesNoBox')
function YesNoBox.toUI(box)
	if <conditional> then
		box.enable = false
		box.borderColor = {r=1, g=0, b=0, a=0.8}
	else
		box.enable = true
		box.borderColor = {r=1, g=1, b=1, a=0.8}
	end 
end
```


##### YesNoMultiBox

The `YesNoMultiBox` offers a method to disable all `YesNoBox`s and a method to disable only certain `YesNoBox`s.

To disable all `YesNoBoxes`:
```lua
local myBoolean1 = false
local myBoolean2 = true

local YesNoBox1 = YesNoBox.new('My YesNoBox 1')
local YesNoBox2 = YesNoBox.new('My YesNoBox 2')

local YesNoMultiBox = YesNoBox.new('My MultiYesNoBox', {YesNoBox1, YesNoBox2})
function YesNoMultiBox.toUI(box)
	if <conditional> then
		box.enable = false
	else
		box.enable = true
	end
end
```


To disable only certain `YesNoBox`s:
```lua
local myBoolean1 = false
local myBoolean2 = true

local YesNoBox1 = YesNoBox.new('My YesNoBox 1')
local YesNoBox2 = YesNoBox.new('My YesNoBox 2')

local YesNoMultiBox = YesNoBox.new('My MultiYesNoBox', {YesNoBox1, YesNoBox2})
function YesNoMultiBox.toUI(box)
	if <conditional> then
		--disable option
		box:disableOption('My YesNoBox 1', true)
	else
		--enable option
		box.disableOption('My YesNoBox 1', false)
	end
end
```

##### Slider
```lua
local myNumberVar = 1

Slider = Slider:new('My Disabled Slider')
function Slider.toUI(box)
	local val = math.min(10, math.max(0, val * 10))
	box:setVolume(val)
	if not <conditional> then
		-- overwrite  the  mouse  dragging function
		-- with a dummy function so nothing happens
		-- when a user tries to drag the slider
		function box:OnMouseDown(x, y)
		end
	end
end
```

Developers may also want to change the borderColor of the Slider, to make it's disabled status more explicit to users:

```lua
local myNumberVar = 1

Slider = Slider:new('My Disabled Slider')
function Slider.toUI(box)
	local val = math.min(10, math.max(0, val * 10))
	box:setVolume(val)
	if not <conditional> then
		-- overwrite  the  mouse  dragging function
		-- with a dummy function so nothing happens
		-- when a user tries to drag the slider
		function box:OnMouseDown(x, y)
		end
		-- give our slider a red border so users
		-- know it is disabled
		box.borderColor = {r=0.7, g=0, r=0, a=0.7}
	else
		box.borderColor = {r=1, g=1, b=1, a=0.5}
	end
end
```


---

## Custom Settings

Native Mod Settings provides mod developers the ability to create custom settings from the vanilla game's UI components.

Below is an example, where a setting with a dummy button is created and added to the Main Options Screen:

```lua
require('NativeSettings')

local myCustomSetting = {}

function myCustomSetting:new(name)
	local o = NativeSetting:new(name)
    setmetatable(o, self)
    self.__index = self
    o.name = name
    return o
end

function myCustomSetting:addToOptionsPage(MainOptionsPage)
    local fontHgtSmall = getTextManager():getFontHeight(UIFont.Small)
    local splitpoint = MainOptionsPage:getWidth() / 3
    dummyButton = ISButton:new(splitpoint, MainOptionsPage.addY, 5, fontHgtSmall + 3, self.name, MainOptionsPage, nil, nil, nil)
	dummyButton:initialise();
	dummyButton:instantiate();
	dummyButton:setFont(UIFont.Small);
    MainOptionsPage.mainPanel:addChild(dummyButton)
    MainOptionsPage.addY = MainOptionsPage.addY + label:getHeight() + 8 --add some space for the next Option
    gameOption = NativeSettings.createGameOption(label, self)
    return gameOption
end

e = myCustomSetting:new('My Custom Settings\'s Title')
function e.toUI(box)
end

function e.apply(box)
end 

Settings = ModSettings:new('MY CUSTOM SETTING')
Settings:addOption(e)
NativeSettings.addModSettings(Settings)
```
This button does nothing when clicked, besides show the possibilities of powerful, fully custom settings.

All custom settings require:
- a `new` function, with a parameter `name`, that allows developers to create a new setting object. This function should inherit the `NativeSetting` base class.
- an `addToOptionsPage` function, with a parameter `MainOptionsPage`. This function dictates how your setting should be created. `MainOptionsPage` is a pointer to the MainOptions page (source code can be found in '*client/OptionScreen/MainOptions*'), which allows mod developers to perform useful tasks, like getting the total width of the MainOptions' page. 

## Appendix

### The Nitty-Gritty Details

*This section is intended for those who want a deeper understanding of how Native Mod Settings works. It is unlikely that you will need to read this unless you are developing custom settings.*

When users start Zomboid and enter the main menu or start a game, a `MainScreen` object is created and instantiated from `MainScreen.instantiate`. This sets up a variety of user menus (and hides them), such as the character creation menus, world creation menus, and many more. Among these menus is  `mainOptions` , which is created with `mainOptions:create`. Native Mod Settings works through a very light modification (less than 20 lines) of the `mainOptions:create`  function.

The `mainOptions:create` method creates all the options menu's buttons, tabs, and settings. The creation of each setting makes up most of the `mainOptions:create` function, and typically looks close to the following:

```lua
local newSetting = self:addYesNo(x, y, width, height, "Setting title")
newSetting.tooltip = "I am a tooltip. I give additional info when users mouse over newSetting"

gameOption = GameOption:new('new_setting', newSetting)
function gameOption.toUI(self)
	local box = self.control
	box:setSelected(1, getSomeBooleanValue())
end
function gameOption.apply(self)
	local box = self.control
	SetSomeBooleanValue((box:isSelected(1)))
end
self.gameOptions:add(gameOption)
```

1. An X position, Y position, width, height, and title is passed to a function that creates a setting. A tooltip is then set.
2. A `GameOption` is created with `GameOption:new`, which takes an option name and the just-created setting as arguments. The `GameOption` object more or less wraps the newly-created setting.
3. `GameOption.toUI` and `GameOption.apply` functions are defined, that both take `self` as an argument. Inside both functions, a `box` variable is set to `self.control`, which is the `newSetting` we just created. Just like a setting made with Native Mod Settings, `toUI` defines how a setting should be displayed, and `apply` defines what should happen when users click "Apply" or "Accept" in the options menu.
4. Finally, the `GameOption` is added to `mainOptions.gameOptions` (which acts as a container for all `GameOption`s) with `self.gameOption:add`. 
5. When a user enters the options menu, `GameOptions:toUI` is executed, which iterates through all the added `GameOption` objects' `toUI` functions, adding them to the screen.
6. When a user applies the settings by clicking "Accept" or "Apply", `GameOptions:apply` is executed, which iterates through all the added `GameOption` objects' `apply` functions.

Native Mod Settings implements a very similar system:

1. When a user enters the options menu, all `ModSettings` containers inside `NativeSettings.mods` are iterated over, and their `isHidden` function is executed. 
2. if `isHidden` returns false, the `ModSettings`' section is created, with a horizontal line divider and title.
3. The settings inside the `ModSettings` container are then iterated over, executing each setting's `isHidden` function. 
4. If `isHidden` returns false, the setting's `addToOptionsPage` function is executed. This function constructs and adds the setting's UI components to the options menu, then creates and returns a `GameOption` (constructed from the setting) with the `NativeSettings.CreateGameOption` function.
5. The newly constructed `gameOption` is added to the `MainOptions.GameOptions` object.
6. All of Native Mod Settings, along with the vanilla settings, are added to the screen when `GameOptions:toUI` is executed and all Native Mod Settings are applied when `GameOptions:apply` is executed.

### Miscellaneous Functions

#### NativeSettings
*table that acts as a parent container for all `ModSettings` containers*

attributes:
- `mods` - child table that mods are stored in

##### NativeSettings.addModSettings(Settings)
inserts `Settings` into the `NativeSettings.mods` table

##### NativeSettings.createGameOption(VanillaOption, nativeSetting)
Creates and returns a `GameOption` using the `VanillaOption` that `nativeSetting`  wraps

#### ModSettings
*container for mod settings that is rendered as its own section, with a title and horizontal line divider*

attributes:
- `modName` - The Mods name, which will be displayed as the title.
- `settings` - table acting as a container for the mod's settings
- `isHidden` function that defines when a `ModSettings` container should be hidden. By default, this is a one-liner function that returns false. This function is intended to be overwritten by developers, and should always return either true or false.

##### ModSettings:new(modName)
Function that creates a `ModSettings` container.

##### ModSettings:addOption(nativeSetting)
Function that adds a setting to the container's `settings` table.

#### NativeSetting
*base class object for NativeSettings*

attributes:
- `name` - The setting's name
- `tooltip` - a hint or description that is typically displayed when users mouse-over the setting.
- `isHidden` - function that defines when a a `NativeSetting`  should be hidden. By default, this is a one-liner function that returns false. This function is intended to be overwritten by developers, and should always return either true or false.
