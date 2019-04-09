function love.conf(t)
	love.filesystem.setIdentity("Blasteroids")
	t.window.width = 800
	t.window.height = 600
	t.window.title = "Blasterds" .. t.window.width .. "x" .. t.window.height
	t.console = true
end