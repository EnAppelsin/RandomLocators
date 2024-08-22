local Data = ReadFile("/GameData/" .. GetPath())
local hash = Hash(Data)

local map_loc = Paths.Resources .. string.format("%x.map", hash)
if not Exists(map_loc, true, false) then
	Alert("Could not find a collision map for the level, random locations are not possible")
	Map.ID = 0
	return
end

local map = ReadFile(map_loc)

Map.ID = string.unpack("=c4", map)

if Map.ID ~= "MAP\255" then 
	Alert(string.format("Invalid collision map in the mod (ID=%s, expected MAP)", Map.ID))
	Map.ID = 0
	return
end

Map.ID, Map.Xmin, Map.Xmax, Map.Ymin, Map.Ymax, Map.Hmin, Map.Hmax, Map.Bheight, Map.Bwidth = string.unpack("=c4ffffffii", map)

local bitmap = map:sub(37)
local unpacked = {}
local prev = -1
local i = 1
-- RLE unpack
while i < #bitmap do
	local new = bitmap:sub(i, i)
	unpacked[#unpacked + 1] = new
	if new == prev then
		local length = string.unpack("=i4", bitmap, i + 1) - 2
		if length < 0 then
			Alert("Error unpacking RLE data from collision map, the file is corrupt?")
			Map.ID = 0
			return
		end
		unpacked[#unpacked + 1] = string.rep(new, length)
		i = i + 4
	end
	prev = new
	i = i + 1
end

Map.Bitmap = table.concat(unpacked)
if Map.Bitmap:len() ~= (Map.Bheight * Map.Bwidth) then
	Alert(string.format("RLE unpacked collision map was not the expected size %d instead of %d", Map.Bitmap:len(), (Map.Bheight * Map.Bwidth)))
	Map.ID = 0
	Map.Bitmap = ""
	return
end	


print(string.format("Using map %s (ID=%s) for level %s", map_loc, Map.ID, GetPath()))

