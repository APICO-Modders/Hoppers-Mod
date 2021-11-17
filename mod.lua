MOD_NAME = "hopper"

DEFINITION_CACHED = {}
DEFINITION_CACHE = {}

HOPPERS = {}

function register()
  return {
    name = MOD_NAME,
    hooks = {"click", "clock", "draw"}, 
    modules = {"utils", "hopper"}
  }
end


function init()
  -- only init if both defines work
  return util_define_hopper()
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
      if (item_id == "") then
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
      if (item_id == "") then
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
    api_draw_circle(ox+8, oy+8, 64, "OUTLINE", true)
  end
end


function clock()
  new_list = {}
  for i=1,#HOPPERS do
    if (api_inst_exists(HOPPERS[i])) then
      hopper_process(HOPPERS[i])
      table.insert(new_list, HOPPERS[i])
    end
  end
  HOPPERS = new_list
end

