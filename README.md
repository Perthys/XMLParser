# XMLParser
A intuitive XMLParser entirely implemented in LuaU <br>
Parses XML strings into similar AST <br>
Also Parses AST back into XML <br>

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

local Base = "https://raw.githubusercontent.com/Perthys/XMLParser/main/src/"
local Modules = { "init", "Entities", "Node", "Parser", "Serializer" }

local XMLModule = Instance.new("ModuleScript");
XMLModule.Name = "XML";

for _, Name in (Modules) do
    local Request = HttpService:RequestAsync({
        Url = `{Base}{Name}.luau`;
        Method = "GET";
    });

    local Success = Request.Success and Request.StatusCode == 200 if not Success then error(`Failed to install XMLParser module: {Name}`) end

    if (Name == "init") then
        XMLModule.Source = Request.Body
    else
        local Child = Instance.new("ModuleScript");
        Child.Name = Name;
        Child.Source = Request.Body;
        Child.Parent = XMLModule;
    end
end

HttpService.HttpEnabled = LastValue

XMLModule.Parent = ReplicatedStorage;
print("Successfully installed XMLParser module. At:", XMLModule);
```

**Wally**
```lua
xmlparser = "perthys/xmlparser@1.0.1"
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
    Type = "ROOT",
    Attributes = {},
    Children = {
        {
            Type = "COMMENT",
            Text = " text ",
            Attributes = {},
            Children = {}
        },
        {
            Type = "PROLOG",
            TagType = "xml",
            Attributes = {
                { Name = "version", Value = "1.0" },
                { Name = "encoding", Value = "UTF-8" }
            },
            Children = {}
        },
        {
            Type = "SINGLE",
            TagType = "image",
            Attributes = {
                { Name = "ImageID", Value = "rbxassetid://15102015050" },
                { Name = "OtherArgument", Value = "test" }
            },
            Children = {}
        },
        {
            Type = "TAG",
            TagType = "font",
            Attributes = {
                { Name = "size", Value = "50" }
            },
            Children = {
                {
                    Type = "TAG",
                    TagType = "b",
                    Attributes = {},
                    Children = {
                        {
                            Type = "STRING",
                            Text = "hello",
                            Attributes = {},
                            Children = {}
                        }
                    }
                }
            }
        }
    }
}

print(Text == XML:GenerateXMLFromTree(Tree)) -- true

```

## API
**`XML:GenerateTreeFromXML(XML: string)` `-> XML_AST: {}`** <br/>
**`XML:GenerateXMLFromTree(XML_AST: {})` `-> XML: string`** <br/>
**`XML.Escape(Text: string)` `-> string`** — escapes `& < > " '` into entities <br/>
**`XML.Unescape(Text: string)` `-> string`** — decodes `&amp; &lt; &gt; &quot; &apos; &#65; &#x41;` <br/>

**Node methods** <br/>
**`Node:GetAttribute(Name: string)` `-> string?`** — entity-decoded attribute value <br/>
**`Node:GetText()` `-> string?`** — entity-decoded text of a `STRING`/`COMMENT` node (`Node.Text` keeps the raw source) <br/>
**`Node:GetChildren()` / `Node:AddChild(Node)` / `Node:RemoveChild(Node)`** <br/>

## Maintainers
- [Perth](https://github.com/Perthys) | `Perthys#0`