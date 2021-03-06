module ( "ResourceManager", package.seeall )
-- Module in charge of creating & storing
-- decks and assets in general

require "resource_defs"

-- Asset type constants
ASSET_TYPE_IMG = 0
ASSET_TYPE_TILED_IMG = 1
ASSET_TYPE_FONT = 2
ASSET_TYPE_SOUND = 3

ASSETS_PATH = 'assets/'

local cache = {}

function ResourceManager:get ( name )
  -- Get resource & load if not already cached
  if (not self:loaded ( name )) then
    self:load ( name )
  end

  return cache[name]
end

function ResourceManager:loaded ( name )
  -- Check if resource is cached 
  return cache[name] ~= nil
end

function ResourceManager:load ( name )
  -- Load resource into cache
  local resource_def = ResourceDefinitions:get( name )
  
  if not resource_def then
    print("Error: Missing resource definition for " .. name)
  else
    local resource

    if (resource_def.type == ASSET_TYPE_IMG) then
      resource = self:loadImage( resource_def )
    elseif (resource_def.type == ASSET_TYPE_TILED_IMG) then
      resource = self:loadTiledImage( resource_def )
    elseif (resource_def.type == ASSET_TYPE_FONT) then
      resource = self:loadFont( resource_def )
    elseif (resource_def.type == ASSET_TYPE_SOUND ) then
      resource = self:loadSound( resource_def )
    end
    
    cache[name] = resource
  end
end 

function ResourceManager:loadImage ( definition )
  local image
  
  local file_path = ASSETS_PATH .. definition.file_name

  if definition.coords then
    image = self:loadGfxQuad2D ( file_path, definition.coords )
  else
    -- image defined using width and height
    local half_width = definition.width / 2
    local half_height = definition.height / 2
    image = self:loadGfxQuad2D(file_path, {-half_width, -half_height, 
                                            half_width, half_height})
  end
  return image
end

function ResourceManager:loadGfxQuad2D ( file_path, coords )
  local image = MOAIGfxQuad2D.new ()
  image:setTexture ( file_path )
  image:setRect ( unpack(coords) )
  return image
end

function ResourceManager:loadTiledImage ( definition )
  local tiled_image = MOAITileDeck2D.new ()
  local file_path = ASSETS_PATH .. definition.file_name

  tiled_image:setTexture ( file_path )
  -- Load x by y tilemap
  tiled_image:setSize ( unpack(definition.tile_map_size) )

  return tiled_image
end

function ResourceManager:loadFont ( definition )
  local font = MOAIFont.new ()
  local file_path = ASSETS_PATH .. definition.file_name
  -- load specific characters defined in glyphs
  font:loadFromTTF ( file_path, definition.glyphs,
                     definition.font_size, definition.dpi )
  return font
end

function ResourceManager:loadSound ( definition )
  local sound = MOAIUntzSound.new ()
  local file_path = ASSETS_PATH .. definition.file_name
  sound:load( file_path )
  sound:setVolume( definition.volume )
  sound:setLooping( definition.loop )

  return sound
end
