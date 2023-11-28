local Dump = require(script:WaitForChild("Dump"))

local RecongizedSymbols = {
	"<";
}

local Sequence = {
	["TAG_START"] = function(String)
		local TagType = String:match("<(.+)>") and not String:match("<(.+)/>") and not String:match("</(.+)>") and not String:match("<%?(.+)%?>") and not String:match("<!%-%-(.+)%-%->") 

		if (TagType) then return true end

		return false
	end; 
	["TAG_END"] = function(String)
		local TagType = String:match("</(.+)>") 

		if (TagType) then return true end
	end;
	["TAG_SINGLE"] = function(String)
		local TagType = String:match("<(.+)/>")

		if (TagType) then return true end
	end; 

	["TAG_COMMENT"] = function(String)
		local TagType = String:match("<!%-%-(.+)%-%->")

		if (TagType) then return true end
	end;
	["TAG_PROLOG"] = function(String)
		local TagType = String:match("<%?(.+)%?>")

		if (TagType) then return true end
	end
}

local function GetAttributesAndTagTypeFromTag(Tag)
	local TagType = Tag:match("<(.+)>") or Tag:match("</(.+)>") or Tag:match("<(.+)/>")

	local Split = TagType:split(" ") or {}

	local Tag = Split[1] or TagType

	local Attributes = {}
	if Split[1] then table.remove(Split, 1) end

	for Index, Attribute in (Split) do
		local SplitAttribute = Attribute:split("=")

		local AttributeName = SplitAttribute[1]
		local AttributeValue = SplitAttribute[2]

		Attributes[AttributeName] = AttributeValue
	end

	return Tag:gsub("/", ""), Attributes
end

local function GetKeyWord(CurrentSequence)
	for KeyWord, Function in Sequence do
		local IsKeyWord = Function(CurrentSequence)

		if (IsKeyWord) then return KeyWord end
	end
end

local function IsSequenceStarter(CurrentCharacter)
	if table.find(RecongizedSymbols, CurrentCharacter) then
		return true
	end

	return false
end

local function CheckIfStringOnlyHasSpaces(String)
	return if String:match("^%s*$") then true else false 
end 

local Parsers = {
}

local DefaultFormat = {
	["Type"] = "";
	["Children"] = {};
}


local function GenerateTreeRecursive(String)
	local Tree = table.clone(DefaultFormat);
	Tree.Type = "Root";

	local StringSize = #String

	local CurrentSequence = ""
	local CurrentNode = Tree
	local CurrentNodeIndex = 1

	local CurrentTagType = "";

	local SequenceStarterAlreadyActive = false;
	local TotalString = "";

	local AlreadyHasProlog = false;

	while (true) do
		local CurrentCharacter = String:sub(CurrentNodeIndex, CurrentNodeIndex)
		local IsSequenceStarter = IsSequenceStarter(CurrentCharacter)

		TotalString ..= CurrentCharacter;

		if IsSequenceStarter then
			if not SequenceStarterAlreadyActive then
				SequenceStarterAlreadyActive = true;

				if CurrentSequence ~= "" then
					local Cloned = table.clone(DefaultFormat)
					Cloned.Type = "text"
					Cloned.Attributes = {
						Text = CurrentSequence
					};
					Cloned.Children = nil
					Cloned.Parent = CurrentNode

					table.insert(CurrentNode.Children, Cloned)
				end

				CurrentSequence = ""

			else
				SequenceStarterAlreadyActive = false;
			end
		end

		CurrentSequence ..= CurrentCharacter

		local KeyWord = GetKeyWord(CurrentSequence); 

		if KeyWord then
			local TagType, Attributes = GetAttributesAndTagTypeFromTag(CurrentSequence)

			if KeyWord == "TAG_START" then
				local Cloned = table.clone(DefaultFormat)
				Cloned.Type = TagType
				Cloned.Attributes = Attributes
				Cloned.Children = {};
				Cloned.Parent = CurrentNode

				table.insert(CurrentNode.Children, Cloned)

				CurrentNode = Cloned
				CurrentTagType = TagType

			elseif KeyWord == "TAG_END" then
				CurrentTagType = CurrentNode.Type;
				CurrentNode = CurrentNode.Parent

				if CurrentTagType ~= TagType then error("how the fuck") end
			elseif KeyWord == "TAG_SINGLE" then
				local Cloned = table.clone(DefaultFormat)
				Cloned.Type = TagType
				Cloned.Attributes = Attributes
				Cloned.Children = nil;
				Cloned.Parent = CurrentNode

				table.insert(CurrentNode.Children, Cloned)
			elseif KeyWord == "TAG_COMMENT" then
				local Cloned = table.clone(DefaultFormat)
				Cloned.Type = "Comment"
				Cloned.Attributes = {
					Comment = CurrentSequence:gsub(`([%<>!%-]+)`, "")
				};
				Cloned.Children = nil
				Cloned.Parent = CurrentNode

				table.insert(CurrentNode.Children, Cloned)
			elseif KeyWord == "TAG_PROLOG" then
				if AlreadyHasProlog then error "Cant have more than one Prlog Dumbo" end
				if #CurrentNode.Children ~= 0 then error "Prolog needs to be first dumbo" end

				AlreadyHasProlog = true;

				local Cloned = table.clone(DefaultFormat)
				Cloned.Type = "Prolog"
				Cloned.Attributes = Attributes
				Cloned.Children = {

				};
				Cloned.Parent = CurrentNode
				Cloned.Attributes["type"] = TagType:gsub("?", "");

				table.insert(CurrentNode.Children, Cloned)
			end

			CurrentSequence = KeyWord and "" or CurrentSequence
		end

		if CurrentNodeIndex >= StringSize then
			break
		end

		CurrentNodeIndex += 1
	end

	return Tree
end

local Prolog = `<?xml version="1.0" encoding="UTF-8"?>`
local Comment = `<!--- text --->`
local Single = `<image ImageID="rbxassetid://15102015050" OtherArgument="test"/>`
local String = Prolog..Comment..Single..`<bold><font size="40"> test </font><font size="40"> test </font></bold>`..Single..Comment

print(Dump(GenerateTreeRecursive(String)))
