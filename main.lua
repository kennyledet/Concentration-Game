require "resource_defs"
require "resource_manager"
require "input_mgr"
require "game"

-- Base dimensions
WORLD_RES_X = 320
WORLD_RES_Y = 480

SCREEN_RES_X = 1 * WORLD_RES_X
SCREEN_RES_Y = 1 * WORLD_RES_Y

-- Main window
MOAISim.openWindow ( "Concentration", SCREEN_RES_X, SCREEN_RES_Y )

-- Setup viewport
viewport = MOAIViewport.new ()
viewport:setSize ( SCREEN_RES_X, SCREEN_RES_Y )
viewport:setScale ( WORLD_RES_X, WORLD_RES_Y )

function main ()
    Game:start ()
end

-- Detach game loop from main coroutine flow
game_thread = MOAICoroutine.new ()
game_thread:run ( main )
