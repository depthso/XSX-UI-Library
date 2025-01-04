# XSX UI Library improved
🖼️ This is an improved version of the xsx UI library by bungie. 

This was created a while ago and I forgot to publish this more openly

# Screenshots
#### Interface
<table>
	<tr>
		<td width="600">
			<img src="https://github.com/user-attachments/assets/82f7838a-c044-496b-8727-4f9a66dd1e37" height="100%">
		</td>
		<td width="600">
			<img src="https://github.com/user-attachments/assets/59fa6b21-8775-48bc-8a0b-5ab3a83f24fc" height="100%">
		</td>
	</tr>
</table>

#### Loader interface (The D is based on the first letter of the company string, Depso -> D)
<table>
	<tr>
		<td width="600">
			<img src="https://github.com/user-attachments/assets/e8614124-192f-4599-84ec-bd2a68ea1776" height="100%">
		</td>
		<td width="600">
			<img src="https://github.com/user-attachments/assets/42a645d0-079d-4df9-a271-35b6eecb9e39" height="100%">
		</td>
	</tr>
</table>

# Example
```lua
local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/XSX-UI-Library/refs/heads/main/xsx%20lib.lua'))()

--/ Changable Colors (Optional)
library.headerColor = Color3.fromRGB(51, 158, 190)
library.companyColor = Color3.fromRGB(163, 151, 255)
library.acientColor = Color3.fromRGB(159, 115, 255)
--/ Activate library

--/ Required configuation (Check the xsx lib.lua for more configuation options)
library:Init({
    version = "3.2",
    title = "Depso UI demo",
    company = "Depso",
    keybind = Enum.KeyCode.RightShift, -- (Optional, automatically sets the best keybind)
    BlurEffect = true,
})

--/ Watermarks
library:Watermark("Depso")

local FPSWatermark = library:Watermark("FPS")
game:GetService("RunService").RenderStepped:Connect(function(v)
    FPSWatermark:SetText("FPS: "..math.round(1/v))
end)

--/ Intro (Optional)
library:BeginIntroduction()
library:AddIntroductionMessage("Searching for addresses...")
wait(1)
library:AddIntroductionMessage("Successfully found addresses!")
wait(1)
library:EndIntroduction()

local Tab1 = library:NewTab("Example tab")
Tab1:NewSection("Example Components")

local Label1 = Tab1:NewLabel("Example label", "left") -- "left", "center", "right"

--/ Toggle
local Toggle1 = Tab1:NewToggle("Example toggle", false, function(value)
    local vers = value and "on" or "off"
    print("one " .. vers)
end):AddKeybind(Enum.KeyCode.RightControl)
print("Toggle1 value:", Toggle1:GetValue())

--/ Button
local Button1 = Tab1:NewButton("Button", function()
    print("Hello world - Button")
end)

local Button1 = Tab1:NewButton("Notification", function()
    library:Notify("Hello world!", 3)
    library:Notify("Hello world!", 3, "success")
    library:Notify("Hello world!", 3, "alert")
    library:Notify("Hello world!", 3, "error")
end)

--/ Keybind
local Keybind1 = Tab1:NewKeybind("Keybind 1", Enum.KeyCode.RightAlt, function(key)
    library:SetKeybind(Enum.KeyCode[key])
end)

--/ [ Text boxes ]
--/ Small
local Textbox1 = Tab1:NewTextbox("Text box [small]", "Default Text", "PlaceHolder: 1", "small", true, false, function(val)
    print(val)
end)
--/ Medium
local Textbox2 = Tab1:NewTextbox("Text box [medium]", "", "2", "medium", true, false, function(val)
    print(val)
end)
--/ Large
local Textbox3 = Tab1:NewTextbox("Text box [large]", "", "3", "large", true, false, function(val)
    print(val)
end)

--/ Selector
local Selector1 = Tab1:NewSelector("Selector 1", "bungie", {"A", "B", "C", "D"}, function(d)
    print(d)
end):AddOption("What the dog doing?")

--/ Number Slider
local Slider1 = Tab1:NewSlider("Slider 1", "", true, "/", {min = 1, max = 100, default = 20})
print("Slider value:", Slider1:GetValue())

--/ Type-writer title
local HeaderString = "Bozo-Softworks"
local Time = 1
Time = Time/(#HeaderString*2)

while wait() do
    for i = 0, #HeaderString do
        library:SetCompany(HeaderString:sub(1, i))
        wait(Time)
    end
    for i = #HeaderString, 1, -1  do
        library:SetCompany(HeaderString:sub(1, i))
        wait(Time)
    end
end
```
