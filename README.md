# XMLParser

awfully made xml parser probably can have like A MILLION optimizations

but parses xml into ast


## TODO:
- Make code not look bad [ ]
- Optimize code [ ]
- Make Sequencer not use patterns [ ]
- Sequences probably dont need extra statements to return bools as they probably get casted to booleans on return anyway when checking in a equality statement (Remove If Statements) [ ]
- Move the TAG_TYPE operation code into a table [ ]
- Actually make this recursive instead of using a while loop [ ]
- add a true linter instead of erroring [ ]

```lua
local Prolog = `<?xml version="1.0" encoding="UTF-8"?>`
local Comment = `<!--- text --->`
local Single = `<image ImageID="rbxassetid://15102015050" OtherArgument="test"/>`
local String = Prolog..Comment..Single..`<bold><font size="40"> test </font><font size="40"> test </font></bold>`..Single..Comment

print((GenerateTreeRecursive(String)))

-- becomes

local Joe = {
    Children = {
        {
            Parent = '[Cyclic table: 0xa24c7a9bb6a70ca6, path: ROOT]',
            Type = "Prolog",
            Children = {},
            Attributes = {
                encoding = ""UTF-8"?",
                version = ""1.0"",
                type = "xml"
            }
        },
        {
            Parent = '[Cyclic table: 0xa24c7a9bb6a70ca6, path: ROOT]',
            Type = "Comment",
            Attributes = {
                Comment = " text "
            }
        },
        {
            Parent = '[Cyclic table: 0xa24c7a9bb6a70ca6, path: ROOT]',
            Type = "image",
            Attributes = {
                OtherArgument = ""test"/",
                ImageID = ""rbxassetid://15102015050""
            }
        },
        {
            Parent = '[Cyclic table: 0xa24c7a9bb6a70ca6, path: ROOT]',
            Type = "bold",
            Children = {
                {
                    Parent = '[Cyclic table: 0x2492aa6c4d07ef46, path: ROOT.Children[4]]',
                    Type = "font",
                    Children = {},
                    Attributes = {
                        size = ""40""
                    }
                },
                {
                    Parent = '[Cyclic table: 0x2492aa6c4d07ef46, path: ROOT.Children[4]]',
                    Type = "font",
                    Children = {},
                    Attributes = {
                        size = ""40""
                    }
                }
            },
            Attributes = {}
        },
        {
            Parent = '[Cyclic table: 0xa24c7a9bb6a70ca6, path: ROOT]',
            Type = "image",
            Attributes = {
                OtherArgument = ""test"/",
                ImageID = ""rbxassetid://15102015050""
            }
        },
        {
            Parent = '[Cyclic table: 0xa24c7a9bb6a70ca6, path: ROOT]',
            Type = "Comment",
            Attributes = {
                Comment = " text "
            }
        }
    },
    Type = "Root"
}

```
