function element_0(shader, t_base, t_second, t_detail)
	shader:begin("stub_screen_space", "ogsr_blur")
		:fog(false)
		:zb(false, false)
	shader:dx10texture("s_image", "$user$generic0")
	shader:dx10texture("s_position", "$user$position")
	//shader:dx10texture("s_lut_atlas", "shaders\\lut_atlas")

	shader:dx10sampler("smp_nofilter")
	shader:dx10sampler("smp_rtlinear")
end

function element_1(shader, t_base, t_second, t_detail)
	shader:begin("stub_screen_space", "ogsr_blur")
		:fog(false)
		:zb(false, false)
	shader:dx10texture("s_image", "$user$blur_h_2")
	shader:dx10texture("s_position", "$user$position")
	//shader:dx10texture("s_lut_atlas", "shaders\\lut_atlas")

	shader:dx10sampler("smp_nofilter")
	shader:dx10sampler("smp_rtlinear")
end

function element_2(shader, t_base, t_second, t_detail)
	shader:begin("stub_screen_space", "ogsr_blur")
		:fog(false)
		:zb(false, false)
	shader:dx10texture("s_image", "$user$generic0")
	shader:dx10texture("s_position", "$user$position")
	//shader:dx10texture("s_lut_atlas", "shaders\\lut_atlas")

	shader:dx10sampler("smp_nofilter")
	shader:dx10sampler("smp_rtlinear")
end

function element_3(shader, t_base, t_second, t_detail)
	shader:begin("stub_screen_space", "ogsr_blur")
		:fog(false)
		:zb(false, false)
	shader:dx10texture("s_image", "$user$blur_h_4")
	shader:dx10texture("s_position", "$user$position")
	//shader:dx10texture("s_lut_atlas", "shaders\\lut_atlas")

	shader:dx10sampler("smp_nofilter")
	shader:dx10sampler("smp_rtlinear")
end

function element_4(shader, t_base, t_second, t_detail)
	shader:begin("stub_screen_space", "ogsr_blur")
		:fog(false)
		:zb(false, false)
	shader:dx10texture("s_image", "$user$generic0")
	shader:dx10texture("s_position", "$user$position")
	//shader:dx10texture("s_lut_atlas", "shaders\\lut_atlas")

	shader:dx10sampler("smp_nofilter")
	shader:dx10sampler("smp_rtlinear")
end

function element_5(shader, t_base, t_second, t_detail)
	shader:begin("stub_screen_space", "ogsr_blur")
		:fog(false)
		:zb(false, false)
	shader:dx10texture("s_image", "$user$blur_h_8")
	shader:dx10texture("s_position", "$user$position")
	//shader:dx10texture("s_lut_atlas", "shaders\\lut_atlas")

	shader:dx10sampler("smp_nofilter")
	shader:dx10sampler("smp_rtlinear")
end