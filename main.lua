function _init()
end

g_color_update = 15
g_hello_world_color = 1
function _update()
    g_color_update -= 1
    if g_color_update == 0 then
        g_color_update = 15
        g_hello_world_color += 1
        -- only go up to 15 so that our text doesn't have to wrap around
        if g_hello_world_color == 15 then
            g_hello_world_color = 0
        end
    end
end

function _draw()
    map(0, 0, 0, 0, 32, 32)
    spr(1, 40, 40, 2, 2)
    print("Hello World", 60, 60, g_hello_world_color + 1)
end
