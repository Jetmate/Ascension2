classtools = require 'classtools'
SpriteSheet = require 'classes/SpriteSheet'
Vector = require 'classes/Vector'

local BlockSheet = {}
function BlockSheet:constructor(name, tile_size)
	SpriteSheet.constructor(self, name)
	self.tile_size = Vector(tile_size, tile_size)
end
function BlockSheet:get_tile(no_table)
	return self:get_sprite(self.tile_size, no_table)
end
function BlockSheet:get_tiles(constant)
	return self:get_equal_sprites(self.tile_size, constant)
end

classtools.inherit(BlockSheet, SpriteSheet)
classtools.callable(BlockSheet)

return BlockSheet