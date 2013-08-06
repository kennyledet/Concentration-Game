module("Game", package.seeall)

require "resource_defs"
require "resource_manager"

-- Asset type constants
ASSET_TYPE_IMG = 0
ASSET_TYPE_TILED_IMG = 1
ASSET_TYPE_FONT = 2
ASSET_TYPE_SOUND = 3

-- Grid constants
GRID_COLS = 5
GRID_ROWS = 4
GRID_TILE_WIDTH = 62
GRID_TILE_HEIGHT = 62
BACK_TILE = 1

local base_defs = { -- core resource definitions
    tiles = {
        type = ASSET_TYPE_TILED_IMG,
        file_name = 'tiles.png',
        tile_map_size = {6, 2},
    },
}

function Game:start ()
    -- Begin & handle main game loop
    self:initialize ()

    -- Input processing
    
end

function Game:initialize ()
    -- Create new layer, add to viewport
    self.layer = MOAILayer2D.new ()
    self.layer:setViewport( viewport )

    MOAIRenderMgr.setRenderTable({ self.layer })

    ResourceDefinitions:setDefinitions( base_defs )

    self:initializeTiles ()
    self:restartGameplay ()
end

function Game:initializeTiles ()
    local grid = MOAIGrid.new ()
    grid:setSize(GRID_COLS, GRID_ROWS,
                 GRID_TILE_WIDTH, GRID_TILE_HEIGHT)

    grid:setRow( 1, BACK_TILE, BACK_TILE, BACK_TILE, BACK_TILE, BACK_TILE )
    grid:setRow( 2, BACK_TILE, BACK_TILE, BACK_TILE, BACK_TILE, BACK_TILE )
    grid:setRow( 3, BACK_TILE, BACK_TILE, BACK_TILE, BACK_TILE, BACK_TILE )
    grid:setRow( 4, BACK_TILE, BACK_TILE, BACK_TILE, BACK_TILE, BACK_TILE )

    self.tiles = {}
    self.tiles.grid = grid
    self.tiles.tileset = ResourceManager:get('tiles')

    self.tiles.prop = MOAIProp2D.new ()
    self.tiles.prop:setDeck(self.tiles.tileset)
    self.tiles.prop:setGrid(self.tiles.grid)
 
    self.tiles.prop:setLoc( - GRID_COLS/2 * GRID_TILE_WIDTH,
                            - GRID_ROWS/2 * GRID_TILE_HEIGHT )

    self.layer:insertProp(self.tiles.prop)

end

function Game:restartGameplay ()
    self.distribution_grid = MOAIGrid.new ()
    self.distribution_grid:setSize(GRID_COLS, GRID_ROWS)
    -- Temporary tile placement - to be randomized
    local tiles = {
        2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7,
        8, 8, 9, 9, 10, 10, 11, 11
    }
    -- Iterate over grid placement spots and place random tiles
    for x=1, GRID_COLS, 1 do
        for y=1, GRID_ROWS, 1 do
            local random = math.random(1, #tiles)
            local value = tiles[random]
            table.remove( tiles, random )
            self.distribution_grid:setTile(x, y, value)
        end
    end

    self.selected_cells = { nil, nil }



end
