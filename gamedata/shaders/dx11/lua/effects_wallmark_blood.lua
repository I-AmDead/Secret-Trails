function normal(shader, t_base, t_second, t_detail)
	shader:begin("effects_wallmark", "effects_wallmark_blood")
		:sorting(3, false)
		:blend(true, blend.srcalpha, blend.invsrcalpha)
		:zb(true, false)
		:fog(false)
		:wmark(true)

	shader:dx10texture("s_base", t_base)

	shader:dx10sampler("smp_base")
	shader:dx10sampler("smp_rtlinear")
end