# XMLParser
A intuitive XMLParser entirely implemented in LuaU <br>
Parses a XML strings into similar AST <br>

## Guide
>[Supports](#Supports) <br>
>[Install](#Install) <br>
>[Usage](#Usage) <br>
>[API](#API) <br>
>[Maintainers](#Maintainers) <br>

## Supports
- Prologs
- Tags
- Singles
- Comments

## Install

**Roblox Console**
```lua
-- Run in Roblox Studio Console
local HttpService = game:GetService("HttpService"); 
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local LastValue = HttpService.HttpEnabled

HttpService.HttpEnabled = true

local ChalkModule = Instance.new("ModuleScript");
ChalkModule.Name = "XML";
ChalkModule.Parent = ReplicatedStorage;

local Request = HttpService:RequestAsync({
    Url = "https://raw.githubusercontent.com/Perthys/XMLParser/main/source/main.lua";
    Method = "GET";
});

HttpService.HttpEnabled = LastValue

if Request.Success and Request.StatusCode == 200 then
    ChalkModule.Source = Request.Body

    print("Successfully installed XMLParser module. At:", ChalkModule);
else
    error("Failed to install XMLParser module.");
end
```

## Usage

**Example**
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local XML = require(ReplicatedStorage:WaitForChild("XML"));

local TagStart = `<b>`;
local TagEnd = `</b>`;

local TagStartArg = `<font size="50">`
local TagEndArg = `</font>`

local Single = `<image ImageID="rbxassetid://15102015050" OtherArgument="test"/>`
local Prolog = `<?xml version="1.0" encoding="UTF-8"?>`
local Comment = `<!-- text -->`

local Text = "hello";

Text = `{TagStart}{Text}{TagEnd}`
Text = `{TagStartArg}{Text}{TagEndArg}`
Text = `{Single}{Text}`
Text = `{Prolog}{Text}`
Text = `{Comment}{Text}`

print(Text)

local Tree = XML:GenerateTreeFromXML(Text); print(Tree)
local NewText = XML:GenerateXMLFromTree(Tree); print(NewText == Text) -- true
```

**Example Output**

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local XML = require(ReplicatedStorage:WaitForChild("XML"));

local TagStart = `<b>`;
local TagEnd = `</b>`;

local TagStartArg = `<font size="50">`
local TagEndArg = `</font>`

local Single = `<image ImageID="rbxassetid://15102015050" OtherArgument="test"/>`
local Prolog = `<?xml version="1.0" encoding="UTF-8"?>`
local Comment = `<!-- text -->`

local Text = "hello";

Text = `{TagStart}{Text}{TagEnd}`
Text = `{TagStartArg}{Text}{TagEndArg}`
Text = `{Single}{Text}`
Text = `{Prolog}{Text}`
Text = `{Comment}{Text}`

local Tree = {
    TagType = "ROOT",
    Attributes = {},
    Children = {
        {
            TagType = "COMMENT",
            Attributes = {
                {
                    Value = " text ",
                    Type = "Comment"
                }
            },
            Children = {},
            Type = "COMMENT"
        },
        {
            TagType = "xml",
            Attributes = {
                {
                    Value = `"1.0"`,
                    Type = "version"
                },
                {
                    Value = `"UTF-8"`,
                    Type = "encoding"
                }
            },
            Children = {},
            Type = "PROLOG"
        },
        {
            TagType = "image",
            Attributes = {
                {
                    Value = `"rbxassetid://15102015050"`,
                    Type = "ImageID"
                },
                {
                    Value = `"test"`,
                    Type = "OtherArgument"
                }
            },
            Children = {},
            Type = "SINGLE"
        },
        {
            TagType = "font",
            Attributes = {
                {
                    Value = `"50"`,
                    Type = "size"
                }
            },
            Children = {
                {
                    TagType = "b",
                    Attributes = {},
                    Children = {
                        {
                            TagType = "String",
                            Attributes = {
                                {
                                    Value = "hello",
                                    Type = "String"
                                }
                            },
                            Children = {},
                            Type = "STRING"
                        }
                    },
                    Type = "TAG"
                }
            },
            Type = "TAG"
        }
    },
    Type = "ROOT"
}

print(Text == XML:GenerateXMLFromTree(Tree)) -- true

```

## API
**`XML:GenerateTreeFromXML(XML: string)` `-> XML_AST: {}`** <br/>
**`XML:GenerateXMLFromTree(XML_AST: {})` `-> XML: string`** <br/>

## Maintainers
- [Perth](https://github.com/Perthys) | `Perthys#0`