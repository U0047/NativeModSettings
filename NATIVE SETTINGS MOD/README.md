# NATIVE SETTINGS MODS (v0.9)
*mod resource allowing addition of custom settings to main options screen*
https://github.com/U0047/NativeSettingsMod/
---


Native Settings Mod is a Zomboid modder's resource that gives mod developers the ability to add a variety of user-friendly, seamless mod settings to the native Main Options page (accessed when clicking 'Options' from the Intro Screen or Pause Screen), under a new 'Native Mod Settings' tab. This allows mod users to easily configure mods without needing to edit mod files directly.

Native Settings Mod currently offers the following settings:
- `YesNoBox` - a boolean tick mark box
- `YesNoMultiBox` - a titled list of boolean tick mark boxes
- `ColorBox` - a button that allows users to pick from an assortment of colors when clicked
- `ComboBox` - a drop-down menu allowing selection from a list of items
- `Slider` - a draggable slider

Native Settings Mod also gives mod developers the ability to create and add custom settings (consult the documentation under /doc/doc.md or the [github wiki]() for more info).

---

## Installation
Native Settings Mod can be installed like most mods; by subscribing to the Steam Workshop or through [manual installation](https://pzwiki.net/wiki/Installing_mods).

Native Settings Mod must be enabled in the main menu's ['mods' page as well as in individual savefiles' mods](https://pzwiki.net/wiki/Using_mods).

---

## About Multiplayer Use

At it's current version *(release v0.9),* Native Settings Mod **is completely untested** in multiplayer. 

While problems are not anticipated, Native Settings makes **zero** guarantee that Native Settings Mod will work in multiplayer.

While security would more likely than not depend on how Native Settings Mods is utilized by mod developers, Native Setting Mods makes **zero** guarantee that it's settings are secure for multiplayer use.

---

## Quick Guide
*This quick guide introduces the basic concepts and usage of Native Settings Mod, by showing how to create a `YesNoBox` and add it to the Options Screen.*

Every mod that utilizes Native Settings Mod needs to create a `ModSettings` object with a title. The `ModSettings` object acts as a container for your mod's settings, and is rendered as it's own section in the Mod Settings page, with a title and horizontal line divider.

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

Both `toUI` and `apply` require a parameter `box` . `box` is a vanilla UI component (such as a tickbox or a drop-down menu) that Native Settings Mod wraps. As of now, all settings wrap one of these vanilla UI components, who have their own methods and attributes.

*Note: While the examples in ['Settings Setup'](#settings-setup) are sufficient enough for learning basic setting creation, it is recommended that mod developers consult the game file of the UI component that is being wrapped by each setting (listed in ['Settings Setup'](#settings-setup) ) for a better understanding of their methods and attributes.*

Now we need to add our `YesNoBox` to our `ModSettings` container, and then add our `ModSettings` container to the `NativeSettings` class (which acts as a container for all mods) with `NativeSettings.addModSettings`.

```lua
Settings:addOption(MyYesNoBox)
NativeSettings.addModSettings(Settings)
```
In order to be displayed in the settings page, all settings will need to be added to our `ModSettings` container before they are added to NativeSetting with `NativeSettings.addModSettings`

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
