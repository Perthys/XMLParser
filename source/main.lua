local HttpService = game:GetService("HttpService");

local function VerifyArrows(String)
	local First = String:sub(1, 1)
	local Last = String:sub(#String, #String)

	return First == "<" and Last == ">"
end

local function ValidateSize(String, Size)
	return #String == Size
end

local Validators; 

Validators = {
	["PROLOG"] = function(String)
		local HasArrows = VerifyArrows(String) if not HasArrows then return end
		local IsProlog = String:match("<%?(.+)%?>") if not IsProlog then return end

		local SecondLetter = String:sub(2, 2) if SecondLetter ~= "?" then return end
		local SecondToLastLetter = String:sub(#String - 1, #String - 1) if SecondToLastLetter ~= "?" then return end

		return true
	end;
	["START"] = function(String)
		local IsLiterallyAnyOther = Validators["END"](String) or Validators["SINGLE"](String) or Validators["COMMENT"](String) or Validators["PROLOG"](String) if IsLiterallyAnyOther then return end
		local IsLiterallyAnyOtherPattern =  String:match("</(.+)>") or String:match("<(.+)/>") or String:match("<!%-%-(.+)%-%->") or String:match("<%?(.+)%?>") if IsLiterallyAnyOtherPattern then return end

		local HasArrows = VerifyArrows(String) if not HasArrows then return end
		local IsTagStart = String:match("<(.+)>") if not IsTagStart then return end

		local SecondLetter = String:sub(2, 2) if SecondLetter == "/" then return end

		return true
	end;
	["END"] = function(String)
		local HasArrows = VerifyArrows(String) if not HasArrows then return end
		local IsTagEnd = String:match("</(.+)>") if not IsTagEnd then return end

		local SecondLetter = String:sub(2, 2) if SecondLetter ~= "/" then return end

		return true
	end;
	["SINGLE"] = function(String)
		local HasArrows = VerifyArrows(String) if not HasArrows then return end
		local IsTagSingle = String:match("<(.+)/>") if not IsTagSingle then return end

		local SecondLetter = String:sub(2, 2) if SecondLetter == "/" then return end
		local SecondToLast = String:sub(#String - 1, #String - 1) if SecondToLast ~= "/" then return end

		return true
	end;
	["COMMENT"] = function(String)
		local HasArrows = VerifyArrows(String) if not HasArrows then return end

		local IsComment = String:match("<!%-%-(.+)%-%->") if not IsComment then return end

		return true
	end;
}

local Extractors;
Extractors = {
	["START"] = function(String)
		String = String:sub(2, #String - 1)

		local Split = String:split(" ") or {}
		local Tag = Split[1] or String

		local Attributes = {}
		if Split[1] then table.remove(Split, 1) end

		for _, Attribute in (Split) do
			local SplitAttribute = Attribute:split("=")

			local AttributeName = SplitAttribute[1]
			local AttributeValue = SplitAttribute[2]

			table.insert(Attributes, {
				Type = AttributeName;
				Value = AttributeValue;
			})
		end

		return Tag, Attributes
	end;
	["END"] = function(String)
		String = String:sub(3, #String - 1)

		return String
	end;
	["SINGLE"] = function(String)
		String = String:sub(2, #String - 2)

		local Split = String:split(" ") or {}
		local Tag = Split[1] or String

		local Attributes = {}

		if Split[1] then table.remove(Split, 1) end;

		for _, Attribute in (Split) do
			local SplitAttribute = Attribute:split("=")

			local AttributeName = SplitAttribute[1]
			local AttributeValue = SplitAttribute[2]

			table.insert(Attributes, {
				Type = AttributeName;
				Value = AttributeValue;
			})
		end

		return Tag, Attributes
	end;
	["COMMENT"] = function(String)
		String = String:sub(5, #String - 3)

		return "COMMENT", {
			{	
				Type = "Comment";
				Value = String
			}
		}
	end;
	["PROLOG"] = function(String)
		String = String:sub(3, #String - 2)

		local Split = String:split(" ") or {}
		local Tag = Split[1] or String

		local Attributes = {}

		if Split[1] then table.remove(Split, 1) end;

		for _, Attribute in (Split) do
			local SplitAttribute = Attribute:split("=")

			local AttributeName = SplitAttribute[1]
			local AttributeValue = SplitAttribute[2]

			table.insert(Attributes, {
				Type = AttributeName;
				Value = AttributeValue;
			})
		end

		return Tag, Attributes
	end;
}

local function SequenceIsATag(CurrentSequence)
	for TagType, Validator in (Validators) do
		local IsTag = Validator(CurrentSequence)
		if (IsTag) then return TagType end
	end
end

local function GetTagNameAndData(Type, String)
	local Extractor = Extractors[Type]

	if (Extractor) then
		return Extractor(String)
	end
end

local function RemoveParentRecursive(Tree)
	Tree.Parent = nil
	local Children = Tree.Children

	if (#Children == 0) then return end
	for _, Child in (Tree.Children) do
		RemoveParentRecursive(Child)
	end
end

local Node = {}; Node.__index = Node

function Node.new(TagType, Data)
	Data = Data or {}
	local self = setmetatable({}, Node)

	self.TagType = TagType or error("No TagType")
	self.Attributes = Data.Attributes or {};
	self.Children = Data.Children or {};
	self.Parent = Data.Parent;
	self.Type = Data.Type;
--	self.ID = HttpService:GenerateGUID(true) for debug visuals for cyclic tables

	return self
end

function Node:AddChild(Child)
	Child.Parent = self
	table.insert(self.Children, Child)
end

function Node:RemoveChild(Child)
	local Find = table.find(self.Children, Child)

	if (Find) then table.remove(self.Children, Find) end
end

function Node:GetChildren()
	return self.Children
end

local function GenerateTreeFromXML(self, String)
	String = if String == nil then self else String;

	local Tree = Node.new("ROOT", {Type = "ROOT"});
	local Root = Tree

	local CurrentSequence = ""
	local CurrentNode = Tree

	local StringSize = #String

	local CurrentNodeIndex = 1

	local BiggestDepth = 0;
	local CurrentDepth = 0;

	local CurrentIsGettingSequence = false

	local Serializers = {
		["START"] = function(String)
			local TagName, Attributes = GetTagNameAndData("START", String)

			local NewNode = Node.new(TagName, {
				Attributes = Attributes;
				Type = "TAG";
			})

			CurrentNode:AddChild(NewNode)
			CurrentNode = NewNode

			CurrentDepth += 1
			if (CurrentDepth > BiggestDepth) then BiggestDepth = CurrentDepth end;
		end;
		["END"] = function(String)
			local TagName = GetTagNameAndData("END", String)

			if (CurrentNode.TagType == TagName) then
				CurrentNode = CurrentNode.Parent
				CurrentDepth -= 1
			end
		end;
		["SINGLE"] = function(String)
			local TagName, Attributes = GetTagNameAndData("SINGLE", String)

			local NewNode = Node.new(TagName, {
				Attributes = Attributes;
				Type = "SINGLE";
			})

			CurrentNode:AddChild(NewNode)
		end;

		["COMMENT"] = function(String)
			local TagName, Attributes = GetTagNameAndData("COMMENT", String)

			local NewNode = Node.new(TagName, {
				Type = "COMMENT";
				Attributes = Attributes;
			})

			CurrentNode:AddChild(NewNode)
		end;

		["PROLOG"] = function(String)
			local TagName, Attributes = GetTagNameAndData("PROLOG", String)

			local NewNode = Node.new(TagName, {
				Type = "PROLOG";
				Attributes = Attributes;
			})

			CurrentNode:AddChild(NewNode)
		end;

	};

	while (true) do 
		local CurrentCharacter = String:sub(CurrentNodeIndex, CurrentNodeIndex)
		local IsSequenceStarter = CurrentCharacter == "<"

		if IsSequenceStarter and not CurrentIsGettingSequence and CurrentSequence ~= "" then
			CurrentIsGettingSequence = true

			local PreviousString = CurrentSequence
			CurrentSequence = ""

			local Type = "String"

			local NewNode = Node.new(Type, {
				Attributes = {
					{
						Type = "String";
						Value = PreviousString
					}
				};
				Type = "STRING";
			})

			CurrentNode:AddChild(NewNode)
		end

		CurrentSequence ..= CurrentCharacter;

		local TagType = SequenceIsATag(CurrentSequence)

		if TagType then
			CurrentIsGettingSequence = false

			local Operation = Serializers[TagType] if not Operation then return end

			Operation(CurrentSequence)
			CurrentSequence = ""
		end

		if CurrentNodeIndex > StringSize then 
			if #CurrentNode.Children == 0 then
				local NewNode = Node.new("String", {Attributes = {Text = CurrentSequence}; Type = "STRING"})
				CurrentNode:AddChild(NewNode)
			end

			break 
		end

		CurrentNodeIndex += 1
	end

	RemoveParentRecursive(Root)
	
	return Root;
end

local function GenerateAttributeString(Attributes)
	local Text = ""

	for _, Attribute in (Attributes) do
		local Type = Attribute.Type
		local Value = Attribute.Value

		Text ..= ` {Type}={Value}`
	end

	return Text
end

local function GenerateXMLFromTree(self, Tree)
	Tree = if Tree == nil then self else Tree;

	local Text = ""
	local Constructors;

	Constructors = {
		["STRING"] = function(Tree)
			local Attributes = Tree.Attributes

			local First = Attributes[1]; if not First then return end;

			Text ..= First.Value
		end;
		["ROOT"] = function(Tree)
			for _, Child in (Tree.Children) do
				Constructors[Child.Type](Child)
			end
		end;
		["TAG"] = function(Tree)
			local TagName = Tree.TagType
			local Attributes = Tree.Attributes

			local TagStart = `<{TagName}{GenerateAttributeString(Attributes)}>`
			local TagEnd = `</{TagName}>`

			Text ..= TagStart
			for _, Child in (Tree.Children) do
				Constructors[Child.Type](Child)
			end

			Text ..= TagEnd
		end;
		["SINGLE"] = function(Tree)
			local TagName = Tree.TagType
			local Attributes = Tree.Attributes

			local TagStart = `<{TagName}{GenerateAttributeString(Attributes)}/>`
			Text ..= TagStart

		end;
		["COMMENT"] = function(Tree)
			local Attributes = Tree.Attributes

			local Comment = Attributes[1].Value;

			local TagStart = `<!--{Comment}-->`
			Text ..= TagStart
		end;
		["PROLOG"] = function(Tree)
			local TagName = Tree.TagType
			local Attributes = Tree.Attributes

			local TagStart = `<?{TagName}{GenerateAttributeString(Attributes)}?>`
			Text ..= TagStart
		end;
	}

	local function Recursive(Tree)
		local Type = Tree.Type;

		Constructors[Type](Tree)
	end

	Recursive(Tree)

	return Text
end

return {
	GenerateTreeFromXML = GenerateTreeFromXML;
	GenerateXMLFromTree = GenerateXMLFromTree;
}