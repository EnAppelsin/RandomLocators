local Data = ReadFile("/GameData/" .. GetPath())

if Map.ID == 0 then
	print("Not handling as no map is present")
	return Output(Data)
end

local level, map = GetPath():match('level(%d*)[\\/]m(%d*)%.p3d$')
local locators = {}

if level ~= nil and map ~= nil then
	local script = ReadFile(string.format("/GameData/scripts/missions/level%s/m%si.mfk", level, map))
	for n in script:gmatch("SetDestination%(\"(.-)\"%s-,%s-\"(.-)\"%)") do
		locators[n] = 1
	end
	for n in script:gmatch("AddCollectible%(\"(.-)\"%s-,%s-\"(.-)\"%)") do
		locators[n] = 1
	end
end

local file = P3D.P3DChunk:new{Raw = Data}

local function Rescale(a, omin, omax, nmin, nmax) 
	return (a - omin) / (omax - omin) * (nmax - nmin) + nmin
end

local function RandomCoordinate()
	while 1 do
		local rX = math.random(0, Map.Bwidth - 1)
		local rY = math.random(0, Map.Bheight - 1)
		
		local I = rY * Map.Bwidth + rX + 1
		local H = string.byte(Map.Bitmap, I)
		if H ~= 255 then
			local X = Rescale(rX, 0, Map.Bwidth - 1, Map.Xmin, Map.Xmax)
			local Z = Rescale(rY, 0, Map.Bheight - 1, Map.Ymin, Map.Ymax)
			local Y = Rescale(H, 0, 255, Map.Hmin, Map.Hmax)
			return X, Y, Z
		end
	end
end

-- Pick a random coordinate

for idx in file:GetChunkIndexes(P3D.Identifiers.Locator) do
	local Locator = P3D.LocatorP3DChunk:new{Raw = file:GetChunkAtIndex(idx)}
	if (Locator.Type == 0 and Locator:GetType0Data() == 2 and locators[P3D.CleanP3DString(Locator.Name)] == 1) or Locator.Type == 2 then
		local x, y, z = RandomCoordinate()
		print(string.format("Moving Locator %s to new location (%f,%f,%f)", Locator.Name, x, y, z))
		Locator.Position.X = x
		Locator.Position.Y = y
		Locator.Position.Z = z
		for triggers in Locator:GetChunkIndexes(P3D.Identifiers.Trigger_Volume) do
			local Trigger = P3D.TriggerVolumeP3DChunk:new{Raw = Locator:GetChunkAtIndex(triggers)}
			Trigger.Matrix.M41 = x
			Trigger.Matrix.M42 = y
			Trigger.Matrix.M43 = z
			Locator:SetChunkAtIndex(triggers, Trigger:Output())
		end
		for triggers in Locator:GetChunkIndexes(P3D.Identifiers.Locator_Matrix) do
			local Trigger = P3D.LocatorMatrixP3DChunk:new{Raw = Locator:GetChunkAtIndex(triggers)}
			Trigger.Matrix.M41 = x
			Trigger.Matrix.M42 = y
			Trigger.Matrix.M43 = z
			Locator:SetChunkAtIndex(triggers, Trigger:Output())
		end		
		file:SetChunkAtIndex(idx, Locator:Output())
	end	
end


Output(file:Output())