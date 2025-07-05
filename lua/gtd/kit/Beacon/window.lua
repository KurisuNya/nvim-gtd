local vim, api = vim, vim.api
local win = {}

local obj = {}
obj.__index = obj

function obj:bufopt(name, value)
	if type(name) == "table" then
		for key, val in pairs(name) do
			api.nvim_set_option_value(key, val, { buf = self.bufnr })
		end
	else
		api.nvim_set_option_value(name, value, { buf = self.bufnr })
	end
	return self
end

function obj:winopt(name, value)
	if type(name) == "table" then
		for key, val in pairs(name) do
			api.nvim_set_option_value(key, val, { scope = "local", win = self.winid })
		end
	else
		api.nvim_set_option_value(name, value, { scope = "local", win = self.winid })
	end
	return self
end

function obj:wininfo()
	return self.bufnr, self.winid
end

function win:new_float(float_opt)
	vim.validate({
		float_opt = { float_opt, "t", true },
	})
	self.bufnr = api.nvim_create_buf(false, false)
	self.winid = api.nvim_open_win(self.bufnr, false, float_opt)
	return setmetatable(win, obj)
end

return win
