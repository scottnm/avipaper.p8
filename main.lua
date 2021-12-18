-- TODO:
-- add header comments to all functions describing what they do in "plane" english ☜(ﾟヮﾟ☜)
-- collide with targets
-- only move vertically when hitting aircurrents (replace 'faux' movement)
-- better target spawning patterns
-- success particle fx when you collide with targets
-- add sound

-- FURTHER IDEAS:
-- day night/cycle for the background
-- wobble on the plane
-- add clouds that you pass by (very top of the perspective plane) just for visual flair
-- add trees to the map for obstacle dodging
-- target tweaks:
-- 1. add some sort of "fog" effect
-- 2. make the targets start closer in the fog and move more slowly towards you

-- GLOBAL CONSTANTS
-- the z coordinate of where the screen/near-plane lives
c_eye_z = 1
c_pico_8_screen_size = 128
-- N.B. constrain a number of gameplay elements to only happen within some border of the game window.
-- FIXME NOW: we should update our sprite selection to take into account these new boundaries
c_gameplay_boundaries = { left = 10, right = 118, top = 10, bottom = 118 }
c_lanes = {
    top = 20,
    mid = 64,
    bottom = 108
}

function get_spritesheet_pos(sprite_n)
    return {
        x = (sprite_n % 16) * 8,
        y = (sprite_n \ 16) * 8
    }
end

-- GLOBAL VARIABLES
g_input = nil
g_plane_pos = nil
g_plane_vertical_slide = nil
g_plane_size = { width = 16, height = 16 }
g_plane_sprites = {
    -- contains a separate table for each 'lane' that the plane can fly in
    -- each lane contains 3 sprite indices: 1 for the far left, one for left, and one for center
    -- the right side is done by flipping the left sprites
    top_lane =    { outside =  1, leaning =  3, center =  5 },
    mid_lane =    { outside =  7, leaning =  9, center = 11 },
    bottom_lane = { outside = 33, leaning = 35, center = 37 },
}
g_score = 0

g_target_spritesheet_index = 13
g_target_spritesheet_sprite_pos = get_spritesheet_pos(g_target_spritesheet_index)
g_targets = {}

function clamp(lower, value, upper)
    return mid(lower, value, upper)
end

function rnd_int_range(lower, upper)
    return flr(rnd(upper - lower)) + lower
end

function get_3d_distance(p1, p2)
    local x_diff = p1.x - p2.x
    local y_diff = p1.y - p2.y
    local z_diff = p1.z - p2.z
    return sqrt((x_diff * x_diff) + (y_diff * y_diff) + (z_diff * z_diff))
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

function move_plane_horizontal(input, plane_pos_x, plane_size, move_speed)
    local new_x = plane_pos_x
    if input.btn_left then
        new_x -= move_speed
    end
    if input.btn_right then
        new_x += move_speed
    end

    -- constrain the plane to only be able to move within the given game box
    new_x = clamp(
        c_gameplay_boundaries.left + (plane_size.width / 2),
        new_x,
        c_gameplay_boundaries.right - (plane_size.width / 2))

    return new_x
end

function move_plane_vertical(input, plane_pos, lanes, move_speed)
    local dest_y
    if input.btn_up and input.btn_up_change then
        if plane_pos.y <= lanes.top then
            -- we are in the top lane and tried to move up.
            -- noop
            return nil
        elseif plane_pos.y <= lanes.mid then
            dest_y = lanes.top
        else
            dest_y = lanes.mid
        end
    elseif input.btn_down and input.btn_down_change then
        if plane_pos.y <= lanes.top then
            dest_y = lanes.mid
        elseif plane_pos.y <= lanes.mid then
            dest_y = lanes.bottom
        else
            -- we are in the bottom lane and tried to move down.
            -- noop
            return nil
        end
    else
        -- neither up nor down was just pressed
        -- noop
        return nil
    end

    local move_to_next_lane =
        function()
            assert(move_speed != 0, "Attempted to perform a move without speed")

            local update_count = 0
            local total_update_count = 30 / move_speed
            local original_y = plane_pos.y
            while true do
                update_count += 1
                local move_completion_ratio = 1 - (update_count / total_update_count)
                -- cubic ease out
                local ease_out_factor = 1 - (move_completion_ratio * move_completion_ratio * move_completion_ratio)
                local cumulative_offset = (dest_y - original_y) * ease_out_factor
                plane_pos.y = cumulative_offset + original_y

                if plane_pos.y != dest_y then
                    yield()
                else
                    break
                end
            end
        end

    return cocreate(move_to_next_lane)
end

function get_plane_sprite(plane_sprites, plane_pos)
    -- N.B lane bands are NOT perfectly even
    -- top lane and bottom lane are slightly larger than the mid lane
    -- IMO this looks better
    local lane
    if plane_pos.y < 52 then
        lane = 'top_lane'
    elseif plane_pos.y < 76 then
        lane = 'mid_lane'
    else
        lane = 'bottom_lane'
    end

    -- N.B. the different zones which correspond to each type of sprite 'lean' are not even
    -- 'outside' and 'center' are wider than 'leaning'.
    -- IMO this looks better
    local flip
    local sprite_lean
    if plane_pos.x < 39 then
        flip = false
        sprite_lean = 'outside'
    elseif plane_pos.x < 50 then
        flip = false
        sprite_lean = 'leaning'
    elseif plane_pos.x < 79 then
        flip = false
        sprite_lean = 'center'
    elseif plane_pos.x < 90 then
        flip = true
        sprite_lean = 'leaning'
    else
        flip = true
        sprite_lean = 'outside'
    end

    return {
        index = plane_sprites[lane][sprite_lean],
        flip = flip
    }
end

function debug_render_sprite_grid(plane_pos)
    -- N.B. currently these grid positions are hardcoded here and in get_plane_sprite and must be manually kept in sync.
    -- probably worth improving in the future

    local divider_color = 7 -- white
    local plane_pos_marker_color = 8 -- white

    -- lane dividers
    line(0, 52, c_pico_8_screen_size, 52, divider_color)    -- draw top lane divider
    line(0, 76, c_pico_8_screen_size, 76, divider_color)    -- draw mid lane divider

    -- lean zone dividers
    line(39, 0, 39, c_pico_8_screen_size, divider_color) -- left outside zone divider
    line(50, 0, 50, c_pico_8_screen_size, divider_color) -- left leaning zone divider
    line(79, 0, 79, c_pico_8_screen_size, divider_color) -- center zone divider
    line(90, 0, 90, c_pico_8_screen_size, divider_color) -- right leaning zone divider zone divider

    -- render the center of the plane
    pset(plane_pos.x, plane_pos.y, plane_pos_marker_color)

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

function apply_weighted_scale(value, scale, weight)
    local weighted_portion = value * weight * scale
    local unweighted_portion = value * (1 - weight)
    return weighted_portion + unweighted_portion
end

function apply_perspective_scale_to_screen_pos(screen_pos, perspective_scale, perspective_weight)
    assert(perspective_weight >= 0 or weight <= 1.0, 'Perspective weight must be a ratio value between 0 and 1')

    local world_pos = screen_space_to_world_space(screen_pos, c_pico_8_screen_size)

    -- this helper function scales a value but allows for weighting how much that scale applies.
    -- i.e. 'I want to scale down by 75% but only apply that scale at roughly 80% potency'
    local scaled_world_pos = {
        x = apply_weighted_scale(world_pos.x, perspective_scale, perspective_weight),
        y = apply_weighted_scale(world_pos.y, perspective_scale, perspective_weight)
    }

    return world_space_to_screen_space(scaled_world_pos, c_pico_8_screen_size)
end

function try_spawn_target(lanes)
    -- spawn a target on average about once every second (with random variation)
    local should_spawn = (rnd_int_range(0, 30) == 1)
    if not should_spawn then
        return nil
    end

    local target_size = { width = 16, height = 16 }

    -- a target can be generated anywhere within the gameplay zone
    -- make sure to account for the target's width when determining those borders
    local rnd_x_pos = rnd_int_range(
        c_gameplay_boundaries.left + (target_size.width / 2),
        c_gameplay_boundaries.right + 1 - (target_size.width / 2))

    local rnd_lane = rnd_choice(lanes)
    local rnd_y_pos = lanes[rnd_lane]

    return {
        pos = { x = rnd_x_pos, y = rnd_y_pos, z = -20 },
        size = target_size
    }
end

function handle_target_collisions(plane_pos, targets)
    local next_target_index = 1
    while next_target_index <= count(targets) do
        local target_plane_distance = get_3d_distance(plane_pos, targets[next_target_index].pos)
        if target_plane_distance <= 1 then
            sfx(1)
            g_score += 100
            deli(targets, next_target_index)
        elseif target_plane_distance <= 4 then
            sfx(2)
            g_score += 10
            deli(targets, next_target_index)
        else
            -- target and plane haven't collided. move onto next target
            next_target_index += 1
        end
    end
end

function check_for_despawned_targets(targets)
    local next_target_index = 1
    while next_target_index <= count(targets) do
        if targets[next_target_index].pos.z == 0 then
            sfx(0)
            deli(targets, next_target_index)
        else
            next_target_index += 1
        end
    end
end

function draw_plane(pos, size, plane_sprites)
    sprite_data = get_plane_sprite(plane_sprites, pos)

    topleft_corner_pos = {
        x = pos.x - (size.width / 2),
        y = pos.y - (size.height / 2),
    }
    spr(sprite_data.index, topleft_corner_pos.x, topleft_corner_pos.y, 2, 2, sprite_data.flip)
end

function draw_target(target)
    local perspective_pos_weight = 0.85
    local perspective_size_weight = 0.80

    local perspective_scale = calculate_perspective_scale(target.pos.z, 0, 1)
    -- fudge the numbers here for a better perspective view. True perspective view makes the dots appear too close to the center of the screen when they start
    -- the target's position is at its center but we need its topleft coordinate to do the sprite draw
    local target_topleft_corner_pos = {
        x = target.pos.x - (target.size.width / 2),
        y = target.pos.y - (target.size.height / 2) }
    local perspective_pos = apply_perspective_scale_to_screen_pos(target_topleft_corner_pos, perspective_scale, perspective_pos_weight)

    local scaled_target_size = {
        width = apply_weighted_scale(target.size.width, perspective_scale, perspective_size_weight),
        height = apply_weighted_scale(target.size.height, perspective_scale, perspective_size_weight),
    }

    -- draw the target sprite
    sspr(
        g_target_spritesheet_sprite_pos.x, -- sx
        g_target_spritesheet_sprite_pos.y, -- sy
        target.size.width,                 -- sw
        target.size.height,                -- sh
        perspective_pos.x,                 -- dx
        perspective_pos.y,                 -- dy
        scaled_target_size.width,          -- dw
        scaled_target_size.height)         -- dh
end

function _init()
    -- initialize the plane's position to the center of the bottom lane
    g_plane_pos = {
        x = c_pico_8_screen_size / 2,
        y = c_lanes.bottom,
        z = 0
    }
end

function _update()
    -- handle using player input to move the plane
    g_input = poll_input(g_input)
    g_plane_pos.x = move_plane_horizontal(g_input, g_plane_pos.x, g_plane_size, 1.5)

    if g_plane_vertical_slide == nil then
        g_plane_vertical_slide = move_plane_vertical(g_input, g_plane_pos, c_lanes, 1.1)
    end

    if g_plane_vertical_slide != nil then
        assert(costatus(g_plane_vertical_slide) != 'dead')
        local active, exception = coresume(g_plane_vertical_slide)
        if exception then
            printh(exception)
            printh(trace(g_plane_vertical_slide, exception))
        end

        if costatus(g_plane_vertical_slide) == 'dead' then
            g_plane_vertical_slide = nil
        end
    end

    -- handle perodically spawning a new target
    local maybe_new_target = try_spawn_target(c_lanes)
    if maybe_new_target != nil then
        add(g_targets, maybe_new_target)
    end

    -- move targets into the screen
    for target in all(g_targets) do
        -- N.B. we need this to be a power of 2 so that it will eventually sum
        -- to exactly 0 without any precision issues.
        target.pos.z += (1/16)
    end

    -- check for any target collisions
    handle_target_collisions(g_plane_pos, g_targets)

    -- check for any despawned targets
    check_for_despawned_targets(g_targets)
end

function _draw()
    -- first draw the map
    map(0, 0, 0, 0, 32, 32)

    -- draw targets in perspective
    foreach(g_targets, draw_target)

    -- draw the plane
    draw_plane(g_plane_pos, g_plane_size, g_plane_sprites)

    -- uncomment this to draw a debug grid showing where plane sprites change
    -- debug_render_sprite_grid(g_plane_pos)

    -- draw the score
    print("score: "..g_score, 0, 0, 7)
end
