Settings = GetSettings()

Paths = {}
Paths.ModPath = GetModPath()
Paths.Resources = Paths.ModPath .. "/Resources/"
dofile(Paths.Resources .. "lib/P3D.lua")
dofile(Paths.Resources .. "lib/P3DFunctions.lua")
dofile(Paths.Resources .. "lib/Checksum.lua")

print("Loaded libraries OK");

if IsModEnabled("Fully Connected Map") then
	print("Supporting Colou's Fully Connected Map!")
end

Map = {}

