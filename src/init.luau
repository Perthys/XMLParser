--!strict
--!native
--!optimize 2

const Parser = require("@self/Parser")
const Serializer = require("@self/Serializer")
const Entities = require("@self/Entities")
const Node = require("@self/Node")

export type Node = Node.Node
export type Attribute = Node.Attribute

return {
	GenerateTreeFromXML = Parser.GenerateTreeFromXML;
	GenerateXMLFromTree = Serializer.GenerateXMLFromTree;
	Escape = Entities.Escape;
	Unescape = Entities.Unescape;
	Node = Node;
}
