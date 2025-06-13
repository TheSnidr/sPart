/// @description
draw_text(10, 10, DemoText + "\nPress a digit (1-9) on your keyboard to switch demo." + "\n" +
"FPS: " + string(fps) + "\n" + 
"Draw calls: " + string(partSystem.drawCalls) + "\n" +
"Emitters: " + string(ds_list_size(partSystem.activeEmitterList) / 2) + "\n" +
"Particles: " + string(partSystem.particleNum));