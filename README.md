# Random Locators Test

A proof of concept mod to shuffle wasps and mission collectibles to *truly* random positions in the map, no constraints on roads or anything.

Compatable with the base game and with Colou's fully connected map 1.0.7

This is very basic as a proof-of-concept, it is suggested you use the "No Time Limits" hack if playing missions, as the random positions may be very far away.

The random shuffle and data may be used in other mods! 

## Using in a mod

*Note*: These descriptions are quite basic at the moment!

You should copy LoadMap.lua and the *.map Files to your mod's Resources folder

- In your CustomFiles.lua declare an empty table Map 
```lua
Map = {}
```

- Run Resources/LoadMap.lua on `art/*_TERRA.p3d` load to read the map data

- You can look at Resources/Shuffle.lua for how to use it - The functions `Rescale` and `RandomCoordinate` are the ones you want to copy
- Call `RandomCoordinate` to generate a random coordinate for the current map!
