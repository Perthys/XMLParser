--!strict
--!native
--!optimize 2

const Entities = require("./Entities")

const Unescape: (String: string) -> string = Entities.Unescape

const Node = {}; Node.__index = Node

export type Attribute = {
	Name: string;
	Value: string;
}

type NodeFields = {
	Type: string;
	TagType: string?;
	Text: string?;
	Attributes: { Attribute };
	Children: { Node };
}

export type Node = typeof(setmetatable({} :: NodeFields, Node))

type NodeData = {
	TagType: string?;
	Text: string?;
	Attributes: { Attribute }?;
	Children: { Node }?;
}

function Node.new(Type: string, Data: NodeData?): Node
	const Info: NodeData = Data or {}

	return setmetatable({
		Type = Type;
		TagType = Info.TagType;
		Text = Info.Text;
		Attributes = Info.Attributes or {};
		Children = Info.Children or {};
	} :: NodeFields, Node)
end

function Node.AddChild(self: Node, Child: Node): ()
	table.insert(self.Children, Child)
end

function Node.RemoveChild(self: Node, Child: Node): ()
	const Find: number? = table.find(self.Children, Child)

	if (Find) then table.remove(self.Children, Find) end
end

function Node.GetChildren(self: Node): { Node }
	return self.Children
end

function Node.GetAttribute(self: Node, Name: string): string?
	for _, Attribute: Attribute in (self.Attributes) do
		if (Attribute.Name == Name) then return Unescape(Attribute.Value) end
	end

	return nil
end

function Node.GetText(self: Node): string?
	const Text: string? = self.Text; if not Text then return nil end

	return Unescape(Text)
end

return Node
