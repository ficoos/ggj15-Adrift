function love.conf(t)
    t.author = "Spoop Team"
    t.identity = "spoop"
    t.version = "0.9.1"

    t.window.title = "Adrift"
    t.window.fullscreen = false
    t.window.vsync = false
    t.window.fsaa = 4
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = false
    t.window.minwidth = 300
    t.window.minheight = 300

    -- modules
    t.modules.joystick = true
    t.modules.audio = true
    t.modules.keyboard = true
    t.modules.event = true
    t.modules.image = true
    t.modules.graphics = true
    t.modules.timer = true
    t.modules.mouse = true
    t.modules.sound = true
    t.modules.thread = false
    t.modules.physics = true

    t.console = false
end
