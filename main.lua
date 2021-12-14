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

function _init()
end

g_color_update = 15
g_hello_world_color = 1
g_spr_pos = { x = 10, y = 10 }

g_input = nil
function _update()
    g_input = poll_input(g_input)
    if g_input.btn_left then
        g_spr_pos.x -= 1
    end
    if g_input.btn_right then
        g_spr_pos.x += 1
    end
    if g_input.btn_up then
        g_spr_pos.y -= 1
    end
    if g_input.btn_down then
        g_spr_pos.y += 1
    end
end

function _draw()
    map(0, 0, 0, 0, 32, 32)
    spr(1, g_spr_pos.x, g_spr_pos.y, 2, 2)
    print("Hello World", 60, 60, g_hello_world_color + 1)
end
