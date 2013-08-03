WORLD_RES_X = 320
WORLD_RES_Y = 480

SCREEN_RES_X = 2 * WORLD_RES_X
SCREEN_RES_Y = 2 * WORLD_RES_Y

-- Main window
MOAISim.openWindow ( "Concentration", SCREEN_RES_X, SCREEN_RES_Y )

-- Setup viewport
viewport = MOAIViewport.new ()
viewport:setSize ( SCREEN_RES_X, SCREEN_RES_Y )
viewport:setScale ( WORLD_RES_X, WORLD_RES_Y )

-- Create new layer, add to viewport
layer = MOAILayer2D.new ()
layer:setViewport ( viewport )

-- Create new Deck object for back of tile
tile_back_deck = MOAIGfxQuad2D.new ()
tile_back_deck:setTexture ( 'assets/tile_back.png' )
tile_back_deck:setRect ( -31, -31, 31, 31 )

-- New Prop for tile_back Deck
tile_back = MOAIProp2D.new ()
tile_back:setDeck (tile_back_deck)
tile_back:setLoc (0, 0)

layer:insertProp(tile_back)

-- Make layer renderable by adding to renderTable
renderTable = { layer }
MOAIRenderMgr.setRenderTable (renderTable)

-- Resource definitions: define assets to be called in ResourceManager
---- Asset type constants
ASSET_TYPE_IMG = 0
ASSET_TYPE_TILED_IMG = 1
ASSET_TYPE_FONT = 2
ASSET_TYPE_SOUND = 3


