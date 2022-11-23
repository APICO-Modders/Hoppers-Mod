--[[
--  @method - util_define_hopper()
--  @desc - defines the custom hopper menu object and adds it to the workbench
--  
--  @return {string} - returns "Success" or nil if something fails to define
]]--
function util_define_hopper()

  -- define hopper
  define_obj = api_define_menu_object({
    id = "hopper",
    name = "Hopper",
    category = "Tools",
    tooltip = "Let's you automatically gather and distribute items to other machines",
    shop_key = false,
    shop_buy = 0,
    shop_sell = 0,
    layout = {
      {19, 29, "InputX"},
      {64, 29, "OutputX"},
      {7, 67},
      {30, 67},
      {53, 67},
      {76, 67},
      {7, 90},
      {30, 90},
      {53, 90},
      {76, 90},
      {7, 113},
      {30, 113},
      {53, 113},
      {76, 113},
    },
    buttons = {"Help", "Target", "Close"},
    info = {
      {"1. Gather Item", "GREEN"},
      {"2. Distribute Item", "RED"},
      {"3. Hopper Storage", "WHITE"},
    },
    tools = {"mouse1", "hammer1"},
    placeable = true
  }, "sprites/hopper_item.png", "sprites/hopper_menu.png", {
    define = "hopper_define",
    tick = "hopper_tick"
  })

  -- define workbench recipe
  recipe = {
    { item = "cog", amount = 10 },
    { item = "planks2", amount = 5},
    { item = "sticks2", amount = 5},
  }
  define_recipe = api_define_recipe("crafting", "hopper_hopper", recipe, 1)
  api_define_workbench("Hoppers", {
    t1 = "Hoppers"
  })

  -- return "Success" only if both defines work
  if (define_obj == "Success" and define_recipe == "Success") then return "Success" end
  return nil

end


--[[
--  @method - util_get_id()
--  @desc - gets a data id for a given slot, usually the oid but special for bees/frames to include extra data
--          i.e "bee:common" or "frame:filled" etc
--  
--  @return {string} - returns the data id for the given slot
]]--
function util_get_id(inst)
  item_id = inst["item"]
  if (inst["stats"] ~= nil) then 
    -- bee species check
    if (item_id == "bee") then
      item_id = "bee:" .. inst["stats"]["species"]
    end
    -- frame prop check
    if (inst["stats"]["uncapped"] == 1 or inst["stats"]["uncapped"] == true) then 
      item_id = item_id .. ":uncapped" 
    elseif (inst["stats"]["filled"] == 1 or inst["stats"]["filled"] == true) then 
      item_id = item_id .. ":filled" 
    end
  end
  return item_id
end


--[[
--  @method - util_get_slot_definition()
--  @desc - gets the input and output slots for a given oid, caching the result
--  
--  @return {table} - returns the definition table containing "input" and "output" keys
]]--
function util_get_slot_definition(oid)

  -- if we already setup the definition for this oid just return it
  if (DEFINITION_CACHED[oid] == true) then 
    return DEFINITION_CACHE[oid] 
  end

  -- otherwise get the definition in the layout we need and cache it
  if (DEFINITION_CACHED[oid] ~= true) then

    -- get the layout info
    definition = api_get_definition(oid)
    slots = definition["layout"]
  
    -- create empty lists for i/o slots
    input_slots = {}
    output_slots = {}
  
    -- if there is a layout find the input/output slots
    -- slots with no type specified are defaulted to output
  
    -- for some reason mod defined definitions are showing as their GM ID not json parsed?
    if (slots ~= nil and type(slots) ~= "number") then
      for i=1,#slots do
        slot_type = ""
        slot = slots[i]
        allowed = {} -- defalt empty allowed for slots without
        frames = false -- check for hive frames (defined as "input" but we want them as output too)
        if (#slot >= 3) then slot_type = slot[3] end
        if (#slot >= 4) then allowed = slot[4] end
        if (#slot >= 5 and string.find(oid, "hive") == 1) then frames = true end
        if (string.find(slot_type, "Input")) then table.insert(input_slots, { index = i, allowed = allowed }) end
        if ((slot_type == "" and string.find(oid, "crate")) or frames == true or string.find(slot_type, "Output")) then table.insert(output_slots, { index = i, allowed = allowed }) end
      end
    end
  
    -- store definition in cache and return it
    DEFINITION_CACHE[oid] = {
      input = input_slots,
      output = output_slots
    }
    DEFINITION_CACHED[oid] = true;
    return DEFINITION_CACHE[oid]
  end
  
end