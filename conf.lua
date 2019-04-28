function love.conf(t)
	love.filesystem.setIdentity("Blasteroids")
	t.version = "11.2"
	t.window.width = 800
	t.window.height = 600
	t.window.title = "Blasteroids " .. t.window.width .. "x" .. t.window.height
	t.console = true
end