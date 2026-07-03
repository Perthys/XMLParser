--!strict
--!native
--!optimize 2

const EscapeMap: { [string]: string } = {
	["&"] = "&amp;";
	["<"] = "&lt;";
	[">"] = "&gt;";
	["\""] = "&quot;";
	["'"] = "&apos;";
}

const UnescapeMap: { [string]: string } = {
	["amp"] = "&";
	["lt"] = "<";
	["gt"] = ">";
	["quot"] = "\"";
	["apos"] = "'";
}

const function Escape(String: string): string
	const Escaped: string = String:gsub("[&<>\"']", EscapeMap)

	return Escaped
end

const function Unescape(String: string): string
	const Unescaped: string = String:gsub("&(#?x?%w+);", function(Entity: string): string
		const Named: string? = UnescapeMap[Entity]; if Named then return Named end

		const Hex: string? = Entity:match("^#x(%x+)$"); if Hex then return utf8.char(tonumber(Hex, 16) :: number) end
		const Decimal: string? = Entity:match("^#(%d+)$"); if Decimal then return utf8.char(tonumber(Decimal) :: number) end

		return `&{Entity};`
	end)

	return Unescaped
end

return {
	Escape = Escape;
	Unescape = Unescape;
}
