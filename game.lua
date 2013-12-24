module("Game", package.seeall)

require "resource_defs"
require "resource_manager"
require "input_mgr"

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
EMPTY_TILE = 12

-- Time before swapping back tiles
DELAY_TIME = 0.5

local base_defs = { -- core resource definitions
    tiles = {
        type = ASSET_TYPE_TILED_IMG,
        file_name = 'tiles.png',
        tile_map_size = {6, 2},
    },
}

function sleepCoroutine( time )
    local timer = MOAITimer.new ()
    timer:setSpan(time)
    timer:start ()
    MOAICoroutine.blockOnAction(timer)
end

function Game:removedTile( column, row )
    return self.tiles.grid:getTile(column, row) == EMPTY_TILE
end

function Game:removeTiles ()
    -- Set empty tile on selected cells
    sleepCoroutine(DELAY_TIME)
    self.tiles.grid:setTile(self.selected_cells[1][1], self.selected_cells[1][2], EMPTY_TILE)
    self.tiles.grid:setTile(self.selected_cells[2][1], self.selected_cells[2][2], EMPTY_TILE)
    self.selected_cells = {nil, nil}

    -- Check if user won, show congrats
    if 
end

function Game:resetTiles ()
    -- Set back tile on both selected cells
    sleepCoroutine(DELAY_TIME)
    self.tiles.grid:setTile(self.selected_cells[1][1], self.selected_cells[1][2], BACK_TILE)
    self.tiles.grid:setTile(self.selected_cells[2][1], self.selected_cells[2][2], BACK_TILE)
    self.selected_cells = {nil, nil}
end

function Game:swapTile( column, row )
    -- Swap tile in rendered grid with value from distribution grid
    local val = self.distribution_grid:getTile(column, row)
    self.tiles.grid:setTile(column, row, val)
end

function Game:chooseCell( column, row )
    print(column, row)
    if not self.selected_cells[1] then
        if not self:removedTile(column, row) then
            self.selected_cells[1] = {column, row}
            self:swapTile(column, row) -- swap to reveal color
        end
    else
        if (self.selected_cells[1][1] == column) and (self.selected_cells[1][2] == row) then -- if selected tile selected previously
            self.selected_cells[2] = {column, row} -- force tile reset
            self:resetTiles ()
        else
            if not self:removedTile(column, row) then
                self.selected_cells[2] = {column, row}
                self:swapTile(column, row)

                -- Main gameplay, check for match
                local val1 = self.distribution_grid:getTile(unpack(self.selected_cells[1]))
                local val2 = self.distribution_grid:getTile(unpack(self.selected_cells[2]))

                if (val1 == val2) then
                    self:removeTiles ()
                else
                    self:resetTiles ()
                end
            end
        end
    end
end

function Game:processInput ()
    if InputManager:isDown () and not self.was_clicking then -- select tile
        x, y = MOAIInputMgr.device.pointer:getLoc () -- grab mouse pos. in window coord system
        print(x, y)

        world_x, world_y = self.layer:wndToWorld(x, y)
        -- get offset in px from bottom-left corner of grid
        model_x, model_y = self.tiles.prop:worldToModel(world_x, world_y)
        -- get cell column & row indices by dividing model dimensions by cell dimensions
        cell_col = math.floor(model_x / GRID_TILE_WIDTH) + 1
        cell_row = math.floor(model_y / GRID_TILE_HEIGHT) + 1 

        self:chooseCell(cell_col, cell_row)
    end

    self.was_clicking = InputManager:isDown ()
end

function Game:start ()
    -- Begin & handle game loop
    self:initialize ()

    -- Input processing
    self.was_clicking = false

    while (true) do
        self:processInput ()
        coroutine.yield () -- Delegate flow to main routine
    end
end

function Game:initialize ()
    -- Run all initialization
    self.layer = MOAILayer2D.new ()
    self.layer:setViewport( viewport )

    MOAIRenderMgr.setRenderTable({ self.layer })

    ResourceDefinitions:setDefinitions( base_defs )

    self:initializeTiles ()
    self:restartGameplay ()
end

function Game:initializeTiles ()
    -- Initialize new grid and cover with back tiles
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
