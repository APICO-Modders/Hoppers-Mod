--[[
--  @method - hopper_define()
--  @desc - called by the define event for a hopper menu
--  
--  @param {string} menu_id - id of hopper menu to define
--  
--  @return nil
]]--
function hopper_define(menu_id)

  -- create imprint props
  api_dp(menu_id, "gather", "")
  api_dp(menu_id, "distribute", "")
  api_dp(menu_id, "ticks", 0)

  -- set self as immortal
  api_set_immortal(api_gp(menu_id, "obj"), true)

  -- set gather/distribute slots as modded so we can make custom click interaction
  slots = api_get_slots(menu_id)
  api_slot_set_modded(slots[1]["id"], true)
  api_slot_set_modded(slots[2]["id"], true)

  -- save props for future
  fields = {"gather", "distribute"}
  fields = api_sp(menu_id, "_fields", fields)

  -- add to global list
  table.insert(HOPPERS, menu_id)

end



function hopper_tick(menu_id)

  ticks = api_gp(menu_id, "ticks")
  ticks = ticks + 1
  api_sp(menu_id, "ticks", ticks)
  if (ticks >= 20) then
    hopper_process(menu_id)
    api_sp(menu_id, "ticks", 0)
  end

end


--[[
--  @method - hopper_process()
--  @desc - called by the clock event for all hoppers every 1s
--  
--  @param {string} menu_id - id of hopper menu to define
--  
--  @return nil
]]--
function hopper_process(menu_id)

  gather = api_gp(menu_id, "gather")
  distro = api_gp(menu_id, "distribute")
  coord = {
    x = api_gp(menu_id, "obj_x"),
    y = api_gp(menu_id, "obj_y")
  }

  -- if theres no imprint why bother
  if (gather ~= "" or distro ~= "") then 

    hopper_slots = api_get_slots(menu_id)

    -- get nearby menus in 32px radius and check for actions
    nearby = api_get_menu_objects(32, nil, coord)

    for n=1,#nearby do

      -- set nearby as immortal if not already
      api_set_immortal(nearby[n]["id"], true)

      -- dont use self 
      if (nearby[n]["oid"] ~= "hopper_hopper") then

        finished = false

        -- get slot definitions (cached)
        oid = nearby[n]["oid"]
        slot_defs = util_get_slot_definition(oid)
        output_slots = slot_defs["output"]
        input_slots = slot_defs["input"]
        nearby_menu_id = nearby[n]["menu_id"]
        
        -- gather items
        if (gather ~= "" and output_slots ~= nil and #output_slots > 0) then

          -- get output slots for the menu
          for o=1,#output_slots do
            -- why check if no item?
            slot = api_get_slot(nearby_menu_id, output_slots[o]["index"])
            if slot["item"] ~= '' then
              -- if output slot has the item we want to gather_item
              gather_item = util_get_id(slot)
              -- prevent hoppers taking empty frames from apiarys
              is_valid = true
              is_frame = gather == "frame1" or gather == "frame2" or gather == "frame3" or gather == "frame4" or gather == "frame5"
              if (string.find(oid, "hive") and is_frame == true) then
                is_valid = false
              end
              -- if valid then we can add to slot
              if (is_valid == true and gather_item == gather) then
                api_add_slot_to_menu(slot["id"], menu_id)
                break;
              end
            end
          end
        end

        -- no point checking menu objects like crates or bottlers for distribution etc
        oid_valid = false
        for o=1,#VALID_INPUT_OIDS do
          if oid == VALID_INPUT_OIDS[o] then oid_valid = true end
        end

        -- also no point checking distribution if we have nothing left distribute!
        have_items = 0
        for h=3,#hopper_slots do
          item_id = util_get_id(hopper_slots[h])
          if item_id ~= '' and item_id == distro then 
            have_items = have_items + 1 
          end
        end

        -- distribute items
        if (distro ~= "" and have_items > 0 and oid_valid == true and input_slots ~= nil and #input_slots > 0) then

          -- get input slots for the menu
          for i=1,#input_slots do
            slot_def = input_slots[i]
            -- find out what the input slot wants
            input_want = slot_def["allowed"]
            distro_slot = api_get_slot(nearby_menu_id, slot_def["index"])
            -- need to make sure the target slot is either empty or can handle adding more items
            can_add = distro_slot["item"] == "" or (distro_slot["count"] >= 1 and distro_slot["count"] < 99)
            if (can_add == true) then 
              for w=1,#input_want do
                -- need to also check the slot can take this item (good example, while beehive has queen, second slot is always invalid)
                wanted_item = input_want[w]
                for h=3,#hopper_slots do -- ignore the first 2 slots
                  -- if we have that item in the hopper, try to add it to the menu
                  current_item = util_get_id(hopper_slots[h])
                  allowed_item = current_item .. ""
                  if (string.find(current_item, "bee:")) then allowed_item = "bee" end
                  if (string.find(current_item, ":uncapped") ~= nil) then 
                    allowed_item = "framex:uncapped"
                  elseif (string.find(current_item, ":filled") ~= nil) then 
                    allowed_item = "framex:filled"
                  elseif (string.find(current_item, "frame")) then
                    allowed_item = "framex"
                  end
                  -- only if the wanted item matches what we are supposed to distribute
                  if (allowed_item == wanted_item and current_item == distro) then
                    is_valid = api_slot_validate(distro_slot["id"], wanted_item, hopper_slots[h]["stats"])
                    if is_valid == true then
                      api_add_slot_to_menu(hopper_slots[h]["id"], nearby[n]["menu_id"])
                      finished = true
                      break
                    end
                  end
                end
                if (finished == true) then break end
              end
            end
            if (finished == true) then break end
          end
        end

      end
    end

  end

end