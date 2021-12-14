pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

-- run the main game
#include main.lua

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000077775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000755555077777770077777777777770007777770000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777600755550005555570075555550555567076555500000000000000000000000000000000000000000000000000000000000000000000000000
00000000775557567655550000555567065555500055566066555000000000000777777700000000000000000000000000000000000000000000000000000000
00000000055555757655500000055557765555000005556765550000777777700755555077777770077777777777770007777770000000000000000000000000
00000000000555576655500000005556765550000000556765500000055557667665550000555576776555500555557075555500000000000000000000000000
00000000000005556665500000000555665500000000055655000000000000767666000000000077766500000000006760000000000000000000000000000000
00000000000000055665000000000005665000000000005650000000000000076600000000000007600000000000000700000000000000000000000000000000
00000000000000005665000000000000560000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000007700000000007000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777700000000077700000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077777700000007777700000000007770000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007777767700000077767770000000077777000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000777777677700000777667777000000777777700000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000077777776677700007777657777000000777677700000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000777777766777700777777657777700007777677770000000000000000000000000000000000000000000000000000000000000000000000000000
00000000677777777667777707777776657777700077777677777000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666777776657777766666776557777770777776667777700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000666776577777700000066567766665666666666666650000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000666566677700000066560000000000056665000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000665600066600000006600000000000005650000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000065600000000000006000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000766700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007666670000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000076677667000077777700007777770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000076666666700005555570075555500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000766766766700000555560065555000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007777007666666666670000055567765550007777770000777777000000000000000000000000000000000000000000000000
00000000000000000000007777775555076666766766667000005557755500000555557007555550000000000000000000000000000000000000000000000000
00000000000000000007775555555555777777755777777700000556655000000000066776600000000000000000000000000000000000000000000000000000
00000000007770000007555555555550000000777700000000000056650000000000000770000000000000000000000000000000000000000000000000000000
00007777775576000076555555555550000000077000000000000005500000000000000000000000000000000000000000000000000000000000000000000000
77775555555557600076555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
75555555555557560766555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555555555555756766555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055555555555777666555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000555555555577666655555550000000000000000007700000000007000000000000000000000000000000000000000000000000000000000000000000000
00000055555555557666655555550000000000000000776700000000076700000000000000000000000000000000000000000000000000000000000000000000
00000000555555556666655555500000000000000077666700000007766700000000000000000000000000000000000000000000000000000000000000000000
00000000005555555666655555000000000000007766676700000076676670000000000000000000000000000000000000000000000000000000000000000000
00000000000055555566665555000000000000777666766700000766776667000000000000000000000000000000000000000000000000000000000000000000
00000000000000555556665550000000000077766667766700007666756667000000000000000000000000000000000000000000000000000000000000000000
00000000000000005555665550000000000766666677666700776666756666700000000000000000000000000000000000000000000000000000000000000000
00000000000000000555565500000000766666666776666707666667756666700000000000000000000000000000000000000000000000000000000000000000
00000000000000000005556500000000777666667756666777777777556666670000000000000000000000000000000000000000000000000000000000000000
00000000000000000000056000000000000777777566666700000077577777770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000777577766700000077570000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000775700077700000007700000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000075700000000000007000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
