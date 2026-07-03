--!strict
--!native
--!optimize 2

const Node = require("./Node")

type Node = Node.Node
type Attribute = Node.Attribute

type Constructor = (Tree: Node, Parts: { string }) -> ()

local function GenerateAttributeString(Attributes: { Attribute }): string
	local Text: string = ""

	for _, Attribute: Attribute in (Attributes) do
		Text ..= ` {Attribute.Name}="{Attribute.Value}"`
	end

	return Text
end

local Constructors: { [string]: Constructor }

Constructors = {
	["STRING"] = function(Tree: Node, Parts: { string })
		table.insert(Parts, Tree.Text :: string)
	end;
	["ROOT"] = function(Tree: Node, Parts: { string })
		for _, Child: Node in (Tree.Children) do
			Constructors[Child.Type](Child, Parts)
		end
	end;
	["TAG"] = function(Tree: Node, Parts: { string })
		table.insert(Parts, `<{Tree.TagType}{GenerateAttributeString(Tree.Attributes)}>`)

		for _, Child: Node in (Tree.Children) do
			Constructors[Child.Type](Child, Parts)
		end

		table.insert(Parts, `</{Tree.TagType}>`)
	end;
	["SINGLE"] = function(Tree: Node, Parts: { string })
		table.insert(Parts, `<{Tree.TagType}{GenerateAttributeString(Tree.Attributes)}/>`)
	end;
	["COMMENT"] = function(Tree: Node, Parts: { string })
		table.insert(Parts, `<!--{Tree.Text}-->`)
	end;
	["PROLOG"] = function(Tree: Node, Parts: { string })
		table.insert(Parts, `<?{Tree.TagType}{GenerateAttributeString(Tree.Attributes)}?>`)
	end;
}

local function GenerateXMLFromTree(self: unknown, Tree: Node?): string
	const Root: Node = (if Tree == nil then self else Tree) :: Node

	const Parts: { string } = {}

	Constructors[Root.Type](Root, Parts)

	return table.concat(Parts)
end

return {
	GenerateXMLFromTree = GenerateXMLFromTree;
}
