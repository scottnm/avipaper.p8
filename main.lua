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

function _init()
end

g_color_update = 15
g_hello_world_color = 1
function _update()
    g_input = poll_input(g_input)
    g_plane_pos = handle_plane_input(g_input, g_plane_pos)
end

function _draw()
    map(0, 0, 0, 0, 32, 32)

    sprite_data = get_plane_sprite(g_plane_sprites, g_plane_pos, g_plane_size)
    spr(sprite_data.index, g_plane_pos.x, g_plane_pos.y, 2, 2, sprite_data.flip)
end
