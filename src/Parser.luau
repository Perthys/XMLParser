--!strict
--!native
--!optimize 2

const Node = require("./Node")

type Node = Node.Node
type Attribute = Node.Attribute

const ExclamationByte: number = ("!"):byte()
const QuestionByte: number = ("?"):byte()
const SlashByte: number = ("/"):byte()
const DashByte: number = ("-"):byte()

local function FindTagEnd(String: string, Position: number): number?
	local Index: number? = String:find("[\"'>]", Position)

	while (Index) do
		const Character: string = String:sub(Index, Index)
		if (Character == ">") then return Index end

		const QuoteEnd: number? = String:find(Character, Index + 1, true); if not QuoteEnd then return nil end
		Index = String:find("[\"'>]", QuoteEnd + 1)
	end

	return nil
end

local function ExtractTagAndAttributes(String: string): (string, { Attribute }?)
	const HasWhitespace: number? = String:find("%s"); if not HasWhitespace then return String, nil end

	const Tag: string?, AttributeText: string? = String:match("^%s*(%S+)%s*(.*)$")
	if not (Tag and AttributeText) then return String, nil end

	const Attributes: { Attribute } = {}
	const Pattern: string = [[([^%s=]+)%s*=%s*(["'])(.-)%2]]

	for Attribute: string, _, Value: string in AttributeText:gmatch(Pattern) do
		table.insert(Attributes, {
			Name = Attribute;
			Value = Value;
		})
	end

	return Tag, Attributes
end

local function GenerateTreeFromXML(self: unknown, Source: string?): Node
	const String: unknown = if Source == nil then self else Source

	if (typeof(String) ~= "string") then error("GenerateTreeFromXML expects a string") end

	const Root: Node = Node.new("ROOT")
	local Current: Node = Root

	const Stack: { Node } = { Root }
	local Depth: number = 1

	local Position: number = 1
	const StringSize: number = #String

	while (Position <= StringSize) do
		const TagStart: number? = String:find("<", Position, true)

		const HasText: boolean = TagStart ~= Position
		if HasText then
			const TextEnd: number = if TagStart then TagStart - 1 else StringSize

			table.insert(Current.Children, Node.new("STRING", {Text = String:sub(Position, TextEnd)}))

			if not TagStart then break end
			Position = TagStart
		end

		const NextByte: number? = String:byte(Position + 1)

		const IsComment: boolean = NextByte == ExclamationByte and String:byte(Position + 2) == DashByte and String:byte(Position + 3) == DashByte
		const IsProlog: boolean = NextByte == QuestionByte
		const IsEnd: boolean = NextByte == SlashByte

		local NextPosition: number?

		if IsComment then
			const CommentEnd: number? = String:find("-->", Position + 4, true)

			if CommentEnd then
				table.insert(Current.Children, Node.new("COMMENT", {Text = String:sub(Position + 4, CommentEnd - 1)}))
				NextPosition = CommentEnd + 3
			end
		elseif IsProlog then
			const PrologEnd: number? = String:find("?>", Position + 2, true)

			if PrologEnd then
				const Tag: string, Attributes: { Attribute }? = ExtractTagAndAttributes(String:sub(Position + 2, PrologEnd - 1))

				table.insert(Current.Children, Node.new("PROLOG", {TagType = Tag; Attributes = Attributes}))
				NextPosition = PrologEnd + 2
			end
		elseif IsEnd then
			const TagEnd: number? = String:find(">", Position + 2, true)

			if TagEnd then
				const Tag: string? = String:sub(Position + 2, TagEnd - 1):match("^%s*(.-)%s*$")

				for Index = Depth, 2, -1 do
					if (Stack[Index].TagType == Tag) then
						Depth = Index - 1
						Current = Stack[Depth]

						break
					end
				end

				NextPosition = TagEnd + 1
			end
		else
			const TagEnd: number? = FindTagEnd(String, Position + 1)

			if TagEnd then
				const IsSingle: boolean = String:byte(TagEnd - 1) == SlashByte
				const Body: string = String:sub(Position + 1, TagEnd - (if IsSingle then 2 else 1))

				const Tag: string, Attributes: { Attribute }? = ExtractTagAndAttributes(Body)

				const NewNode: Node = Node.new(if IsSingle then "SINGLE" else "TAG", {TagType = Tag; Attributes = Attributes})
				table.insert(Current.Children, NewNode)

				if not IsSingle then
					Depth += 1
					Stack[Depth] = NewNode
					Current = NewNode
				end

				NextPosition = TagEnd + 1
			end
		end

		if not NextPosition then
			table.insert(Current.Children, Node.new("STRING", {Text = String:sub(Position)}))

			break
		end

		Position = NextPosition
	end

	return Root
end

return {
	GenerateTreeFromXML = GenerateTreeFromXML;
}
