module ( "ResourceDefinitions", package.seeall )
-- Module functions accessible through
-- ResourceDefinitions

local defs = {}

-- Setter, getter and remove methods for definitions
function ResourceDefinitions:set(name, def)
  defs[name] = def
end

function ResourceDefinitions:get(name)
  return defs[name]
end

function ResourceDefinitions:remove(name)
  defs[name] = nil
end

function ResourceDefinitions:setDefinitions( rdefs )
    -- Iterate through definitions, call set on each
    for k, v in pairs(rdefs) do self:set(k, v) end
end

