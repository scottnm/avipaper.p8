-- TODO:
-- projecticles come out of screen
-- simulate moving to vertical lanes when o/x buttons
    -- slowly transition between fixed lanes via air currents
-- only move vertically when hitting aircurrents

-- FURTHER IDEAS:
-- day night/cycle for the background
-- wobble on the plane

-- GLOBAL CONSTANTS
-- the z coordinate of where the screen/near-plane lives
c_eye_z = 1
c_pico_8_screen_size = 128

-- GLOBAL VARIABLES
g_input = nil
g_plane_pos = { x = 10, y = 10 }
g_plane_size = { width = 16, height = 16 }
g_plane_sprites = {
    -- contains a separate table for each 'lane' that the plane can fly in
    -- each lane contains 3 sprite indices: 1 for the far left, one for left, and one for center
    -- the right side is done by flipping the left sprites
    top_lane =    { outside =  1, leaning =  3, center =  5 },
    mid_lane =    { outside =  7, leaning =  9, center = 11 },
    bottom_lane = { outside = 33, leaning = 35, center = 37 },
}

g_targets = {}

function rnd_int_range(lower, upper)
    return flr(rnd(upper - lower)) + lower
end

function rnd_choice(choices)
    local choice_count = 0
    local choice_map = {}
    for k,v in pairs(choices) do
        add(choice_map, k)
        choice_count += 1
    end

    local rnd_choice_index = rnd_int_range(1, choice_count + 1)
    return choice_map[rnd_choice_index]
end

function poll_input(input)
    if input == nil then
        input = {
            btn_left = false,
            btn_left_change = false,
            btn_right = false,
            btn_right_change = false,
            btn_up = false,
            btn_up_change = false,
            btn_down = false,
            btn_down_change = false,
            btn_o = false,
            btn_o_change = false,
            btn_x = false,
            btn_x_change = false,
        }
    end

    local new_input = {
        btn_left = btn(0),
        btn_right = btn(1),
        btn_up = btn(2),
        btn_down = btn(3),
        btn_o = btn(4),
        btn_x = btn(5),
    }

    input.btn_left_change = (input.btn_left ~= new_input.btn_left)
    input.btn_left = new_input.btn_left
    input.btn_right_change = (input.btn_right ~= new_input.btn_right)
    input.btn_right = new_input.btn_right
    input.btn_up_change = (input.btn_up ~= new_input.btn_up)
    input.btn_up = new_input.btn_up
    input.btn_down_change = (input.btn_down ~= new_input.btn_down)
    input.btn_down = new_input.btn_down
    input.btn_o_change = (input.btn_o ~= new_input.btn_o)
    input.btn_o = new_input.btn_o
    input.btn_x_change = (input.btn_x ~= new_input.btn_x)
    input.btn_x = new_input.btn_x

    return input
end

function handle_plane_input(input, plane_pos)
    local new_pos = {
        x = plane_pos.x,
        y = plane_pos.y,
    }

    if input.btn_left then
        new_pos.x -= 1
    end
    if input.btn_right then
        new_pos.x += 1
    end

    -- FIXME: drop these eventually
    if input.btn_up then
        new_pos.y -= 1
    end
    if input.btn_down then
        new_pos.y += 1
    end

    return new_pos
end

function get_plane_sprite(plane_sprites, plane_tl_pos, plane_size)

    -- the plane's position starts at its top left corner.
    -- For slightly nicer visuals, calcuate the current sprite based off the center of the plane's 'position'
    local pos = {
        x = (plane_tl_pos.x + plane_size.width / 2),
        y = (plane_tl_pos.y + plane_size.height / 2),
    }

    local lane
    if pos.y < 43 then
        lane = 'top_lane'
    elseif pos.y < 86 then
        lane = 'mid_lane'
    else
        lane = 'bottom_lane'
    end

    local flip
    local sprite_type
    if pos.x < 26 then
        flip = false
        sprite_type = 'outside'
    elseif pos.x < 52 then
        flip = false
        sprite_type = 'leaning'
    elseif pos.x < 78 then
        flip = false
        sprite_type = 'center'
    elseif pos.x < 104 then
        flip = true
        sprite_type = 'leaning'
    else
        flip = true
        sprite_type = 'outside'
    end

    return {
        index = plane_sprites[lane][sprite_type],
        flip = flip
    }
end

function calculate_perspective_scale(target_z, screen_z, eye_z)
    assert(eye_z > target_z, 'The camera (eye_z) must be in front of the target (target_z)')
    assert(eye_z > screen_z, 'The camera (eye_z) must be in front of the screen (screen_z)')
    assert(screen_z >= target_z, 'The screen (screen_z) must be in front of the target (target_z)')
    local world_space_z_distance = eye_z - target_z
    local screen_space_z_distance = eye_z - screen_z
    local scale = screen_space_z_distance / world_space_z_distance
    return scale
end

function screen_space_to_world_space(screen_pos, screen_size)
    local half_screen_size = screen_size / 2
    return {
        x = screen_pos.x - half_screen_size,
        y = -1 * (screen_pos.y - half_screen_size)
    }
end

function world_space_to_screen_space(world_pos, screen_size)
    local half_screen_size = screen_size / 2
    return {
        x = world_pos.x + half_screen_size,
        y = (-1 * world_pos.y) + half_screen_size
    }
end

function apply_perspective_scale_to_screen_pos(screen_pos, perspective_scale, perspective_weight)
    assert(perspective_weight >= 0 or weight <= 1.0, 'Perspective weight must be a ratio value between 0 and 1')

    local world_pos = screen_space_to_world_space(screen_pos, c_pico_8_screen_size)

    -- this helper function scales a value but allows for weighting how much that scale applies.
    -- i.e. 'I want to scale down by 75% but only apply that scale at roughly 80% potency'
    local function apply_weighted_scale(value, scale, weight)
        local weighted_portion = value * weight * scale
        local unweighted_portion = value * (1 - weight)
        return weighted_portion + unweighted_portion
    end

    local scaled_world_pos = {
        x = apply_weighted_scale(world_pos.x, perspective_scale, perspective_weight),
        y = apply_weighted_scale(world_pos.y, perspective_scale, perspective_weight)
    }

    return world_space_to_screen_space(scaled_world_pos, c_pico_8_screen_size)
end

function try_spawn_target()
    -- spawn a target on average about once every second (with random variation)
    local should_spawn = (rnd_int_range(0, 30) == 1)
    if not should_spawn then
        return nil
    end

    local rnd_x_pos = rnd_int_range(10, 119)
    local lanes = {
        top = 20,
        mid = 64,
        bottom = 108
    }

    local rnd_lane = rnd_choice(lanes)
    local rnd_y_pos = lanes[rnd_lane]

    return { x = rnd_x_pos, y = rnd_y_pos, z = -20 }
end

function _init()
end

function _update()
    -- handle using player input to move the plane
    g_input = poll_input(g_input)
    g_plane_pos = handle_plane_input(g_input, g_plane_pos)

    -- handle perodically spawning a new target
    local maybe_new_target = try_spawn_target()
    if maybe_new_target != nil then
        add(g_targets, maybe_new_target)
    end

    -- move targets into the screen
    for target in all(g_targets) do
        -- N.B. we need this to be a power of 2 so that it will eventually sum
        -- to exactly 0 without any precision issues.
        target.z += (1/16)
    end

    -- check for any despawned targets
    local next_target_index = 1
    while next_target_index <= count(g_targets) do
        if g_targets[next_target_index].z == 0 then
            deli(g_targets, next_target_index)
        else
            next_target_index += 1
        end
    end
end

function _draw()
    -- first draw the map
    map(0, 0, 0, 0, 32, 32)


    -- then draw targets in perspective
    for target in all(g_targets) do
        local perspective_scale = calculate_perspective_scale(target.z, 0, 1)
        -- fudge the numbers here for a better perspective view. True perspective view makes the dots appear too close to the center of the screen when they start
        local perspective_weight = 0.85
        local perspective_pos = apply_perspective_scale_to_screen_pos(target, perspective_scale, perspective_weight)
        local target_radius = 5 * perspective_scale
        circfill(perspective_pos.x, perspective_pos.y, target_radius, 2)
    end

    -- lastly draw the plane
    sprite_data = get_plane_sprite(g_plane_sprites, g_plane_pos, g_plane_size)
    spr(sprite_data.index, g_plane_pos.x, g_plane_pos.y, 2, 2, sprite_data.flip)
end
