module("InputManager", package.seeall)

function InputManager:initialize ()
    if MOAIInputMgr.device.pointer then
        local pointerCallback = function ( x, y )
            prev_x, prev_y = pointer_x, pointer_y
            pointer_x, pointer_y = x, y

            if touchCallback then
                touchCallback(MOAITouchSensor.TOUCH_MOVE, 1,
                                pointer_x, pointer_y)
            end
        end
    -- body
    MOAIInputMgr.device.pointer:setCallback (pointerCallback)
    end
end

function InputManager:isDown ()
    if MOAIInputMgr.device.touch then
        return MOAIInputMgr.device.touch:isDown ()
    elseif MOAIInputMgr.device.pointer then
        return MOAIInputMgr.device.mouseLeft:isDown ()
    end
end