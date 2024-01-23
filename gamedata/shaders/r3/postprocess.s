function normal		(shader, t_base, t_second, t_detail)
	local opt = shader:dx10Options()
	local t_sbase = opt:msaa_enable() == 1 and "$user$generic" or "$user$albedo"
	shader:begin	("stub_notransform_postpr","postprocess")
			: fog	(false)
			: zb 	(false,false)
	shader:dx10texture	("s_base0", t_sbase)
	shader:dx10texture	("s_base1", t_sbase)
	shader:dx10texture	("s_noise", "fx\\fx_noise2")

	shader:dx10sampler	("smp_rtlinear")
	shader:dx10sampler	("smp_linear")
end

function l_special      (shader, t_base, t_second, t_detail)
	local opt = shader:dx10Options()
	local t_sbase = opt:msaa_enable() == 1 and "$user$generic" or "$user$albedo"
	shader:begin	("stub_notransform_postpr","postprocess_CM")
			: fog	(false)
			: zb 	(false,false)
	shader:dx10texture	("s_base0", t_sbase)
	shader:dx10texture	("s_base1", t_sbase)
	shader:dx10texture	("s_noise", "fx\\fx_noise2")
	shader:dx10texture	("s_grad0", "$user$cmap0")
	shader:dx10texture	("s_grad1", "$user$cmap1")

	shader:dx10sampler	("smp_rtlinear")
	shader:dx10sampler	("smp_linear")
end