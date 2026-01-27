function element_0(shader, t_base, t_second, t_detail)
	shader:begin("editor", "debug_color")
		:fog(false)
		:zb(true, false)
		:blend(true, blend.srcalpha, blend.invsrcalpha)
		:sorting(2, false)
end