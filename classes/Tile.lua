classtools = require 'classtools'
Thing = require 'classes/Thing'
Rect = require 'classes/Rect'
SimpleMultiSpriteManager = require 'classes/SimpleMultiSpriteManager'

Tile = {}
function Tile:constructor(coords, size, type, sprites, speed, rotation)
	Thing.constructor(self, coords, size, rotation)
	SimpleMultiSpriteManager.constructor(self, nil, sprites, speed)
	self.type = type
end

classtools.inherit(Tile, Thing, Rect, SimpleMultiSpriteManager)
classtools.callable(Tile)

return Tile