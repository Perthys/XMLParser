local XML = require(script:WaitForChild("XML"));

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
local Tree = XML:GenerateTreeFromXML(Text)
print(Tree)

local NewText = XML:GenerateXMLFromTree(Tree)

print(NewText == Text)