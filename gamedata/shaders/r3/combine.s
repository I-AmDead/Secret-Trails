function element_0(shader, t_base, t_second, t_detail)
	shader:begin("combine_1", "combine_1")
		:fog(false)
		:zb(false, false)
		:blend(true, blend.invsrcalpha,blend.srcalpha)
		:dx10stencil(true, cmp_func.lessequal, 255, 0, stencil_op.keep, stencil_op.keep, stencil_op.keep)
		:dx10stencil_ref(1)
	shader:dx10texture("s_position", "$user$position")
	shader:dx10texture("s_normal", "$user$normal")
	shader:dx10texture("s_diffuse", "$user$albedo")
	shader:dx10texture("s_accumulator", "$user$accum")
	shader:dx10texture("s_tonemap", "$user$tonemap")
	shader:dx10texture("env_s0", "$user$env_s0")
	shader:dx10texture("env_s1", "$user$env_s1")
	shader:dx10texture("sky_s0", "$user$sky0")
	shader:dx10texture("sky_s1", "$user$sky1")

	jitter.jitter(shader)

	shader:dx10sampler("smp_nofilter")
	shader:dx10sampler("smp_material")
	shader:dx10sampler("smp_rtlinear")
end

function elements(shader, t_base, t_second, t_detail, ps_shader)
	local opt = shader:dx10Options()
	local t_sdist = opt:msaa_enable() and "$user$generic1_r" or "$user$generic1"
	shader:begin("stub_notransform_aa_AA", ps_shader)
		:fog(false)
		:zb(false, opt:msaa_enable())
	shader:dx10texture("s_position", "$user$position")
	shader:dx10texture("s_mask_flare_1", "$user$SunShaftsMaskSmoothed")
	shader:dx10texture("s_mask_flare_2", "$user$sun_shafts1")
	shader:dx10texture("s_normal", "$user$normal")
	shader:dx10texture("s_image", "$user$generic0")
	shader:dx10texture("s_bloom", "$user$bloom1")
	shader:dx10texture("s_distort", t_sdist)
	shader:dx10texture("s_noise", "fx\\blue_noise")
	shader:dx10texture("s_flares", "$user$flares")

	shader:dx10sampler("smp_base")
	shader:dx10sampler("smp_nofilter")
	shader:dx10sampler("smp_rtlinear")
end

function element_1(shader, t_base, t_second, t_detail)
	elements(shader, t_base, t_second, t_detail, "combine_2_naa")
end

function element_2(shader, t_base, t_second, t_detail)
	elements(shader, t_base, t_second, t_detail, "combine_2_naa_d")
end
