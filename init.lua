--[[
   _   _   __    _   _   _____   ______   _____    _____
  | | | | |  \  | | | | |  ___| |  __  | |  __ \  |  ___|
  | | | | |   \ | | | | | |     | |  | | | |  \ \ | |___
  | | | | | |\ \| | | | | |     | |  | | | |  | | |  ___|
  | |_| | | | \   | | | | |___  | |__| | | |_ / / | |___
  |_____| |_|  \__| |_| |_____| |______| |_____/  |_____|
      ____     ____    ____    ______   _____   _____
     |  _  \  / __ \  |  _  \ /  ____| |  ___| |  _  \
     | |_| | | |__| | | |_| | | |____  | |___  | |_| |
     |  ___/ |  __  | |    _/ \____  \ |  ___| |    _/
     | |     | |  | | | |\ \   ____| | | |___  | |\ \
     |_|     |_|  |_| |_| \_\ |______/ |_____| |_| \_\

written by (C) 2018 muhdnurhidayat (MNH48.com) and contributors
               released under The MIT License
--]]

-- Load support for intllib.
-- local S, NS = dofile("/intllib.lua")
local texttemp = ""    -- declare as empty string
local serverprotocol   -- declare the name without type

-- on connect to server, gets server protocol version
minetest.register_on_connect(function()
    serverprotocol = minetest.get_server_info().protocol_version
end)

-- command .uc for cli version
minetest.register_chatcommand("uc", {
	params = "<escapecode>",
	description = "Directly convert and send out converted unicode escape.",
	func = function(param)
		texttemp = string.gsub(param, "\\u", "\\0x")
        sendForProcess(texttemp)
	end
})

-- command .ug for gui version
minetest.register_chatcommand("ug", {
	--description = S("Open the GUI to paste unicode escape, then press \"Say\" to send in chat."),
	description = "Open the GUI to paste unicode escape, then press \"Say\" to send in chat.",
    func = function(name, escuni)
        minetest.show_formspec("unicodeparser:upgui",
            "size[6,3]"..
			"field[1,1;5,2;text;Input the unicode escape;]"..
			"button_exit[2,2;2,1;say;Say]")
    end
})

-- define what to do when gui accepted input
minetest.register_on_formspec_input(function(formname, fields)
    if formname ~= "unicodeparser:upgui" then
        return false
    end
    texttemp = string.gsub(fields.text, "\\u", "\\0x")
    sendForProcess(texttemp)
end)

-- parse the input escaped strings
function sendForProcess(texts)
    local allinput=half(texts,"\\")
	
	local toProcess = {}
	if allinput == nil then
	    return false
	else
        for i,line in ipairs(allinput) do
	        local lineTemp = utf8(tonumber(line))
            table.insert(toProcess,lineTemp)
        end
	    local finalOut = table.concat(toProcess)
        if serverprotocol < 32 then
            minetest.display_chat_message("You wrote: "..finalOut)
        end
	    minetest.send_chat_message(finalOut)
        return true
	end
end

-- split the input escaped strings
function half(inStr, inToken)
    if inStr == nil then
        return nil
    else
        local TableWord = {}
        local fToken = "(.-)" .. inToken
        local l_end = 1
        local w, t, halfPos = inStr:find(fToken, 1)
        while w do
            if w ~= 1 or halfPos ~= "" then
                table.insert(TableWord,halfPos)
            end
            l_end = t+1
            w, t, halfPos = inStr:find(fToken, l_end)
        end
        if l_end <= #inStr then
            halfPos = inStr:sub(l_end)
            table.insert(TableWord, halfPos)
        end
        return TableWord
    end
end

-- convert the strings back to original unicode
do
    local string_char = string.char
    function utf8(codep)
        if codep < 128 then
            return string_char(codep)
        end
        local s = ""
        local max_pf = 32
        while true do
            local suffix = codep % 64
            s = string_char(128 + suffix)..s
            codep = (codep - suffix) / 64
            if codep < max_pf then
                return string_char((256 - (2 * max_pf)) + codep)..s
            end
            max_pf = max_pf / 2
        end
    end
end

-- log the CSM
local msg = "[unicodeparser] CSM loaded."
minetest.log("info", msg)

