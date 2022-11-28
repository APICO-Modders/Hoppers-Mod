MOD_NAME = "hopper"

DEFINITION_CACHED = {}
DEFINITION_CACHE = {}

-- narrow down menu oids to check for distribution
VALID_INPUT_OIDS = {
  'beehive1', 'beehive2', 'beehive3', 'beehive4', 'beehive5', 'beehive6', 'beehive7', 'beehive8',
  'beehive9', 'beehive10', 'beehive11', 'beehive13',
  'hive1', 'hive2', 'hive3', 'uncappingbench', 'uncapper', 'extractor', 'centrifuge', 'centrifuge2'
}

HOPPERS = {}

function register()
  return {
    name = MOD_NAME,
    hooks = {"click", "draw"}, 
    modules = {"utils", "hopper"}
  }
end


function init()
  -- only init if both defines work
  define_check = util_define_hopper()
  -- get all current hoppers
  existing_hoppers = api_get_menu_objects(nil, "hopper_hopper", nil)
  for i=1,#existing_hoppers do
    table.insert(HOPPERS, existing_hoppers[i]["menu_id"])
  end
  return define_check
end


-- used to set the imprint for the gather or distribute slots on a given hopper
function click()

  -- get mouse
  mouse = api_get_mouse_inst()

  -- check if we're in a hopper
  menu = api_get_highlighted("menu")
  if (menu ~= nil and api_gp(menu, "oid") == "hopper_hopper") then

    -- gather imprint slot
    slot = api_get_highlighted("slot")
    if (slot ~= nil and api_gp(slot, "index") == 0) then
      item_id = util_get_id(mouse)
      api_log("click()", "Gather: " .. item_id)
      if (item_id == "") then
        api_sp(menu, "gather", "")
        api_slot_clear(slot)
      else
        api_sp(menu, "gather", item_id)
        api_slot_set(slot, mouse["item"], 0, mouse["stats"])
      end
    end

    -- distribute imprint slot
    slot = api_get_highlighted("slot")
    if (slot ~= nil and api_gp(slot, "index") == 1) then
      item_id = util_get_id(mouse)
      api_log("click()", "Distribute: " .. item_id)
      if (item_id == "") then
        api_sp(menu, "distribute", "")
        api_slot_clear(slot)
      else
        api_sp(menu, "distribute", item_id)
        api_slot_set(slot, mouse["item"], 0, mouse["stats"])
      end
    end

  end

end


function draw() 
  hopper = api_get_highlighted("menu_obj")
  if (hopper ~= nil and api_gp(hopper, "oid") == "hopper_hopper") then
    cam = api_get_camera_position()
    ox = api_gp(hopper, "x") - cam["x"]
    oy = api_gp(hopper, "y") - cam["y"]
    api_draw_circle(ox+8, oy+8, 32, "OUTLINE", true)
  end
end