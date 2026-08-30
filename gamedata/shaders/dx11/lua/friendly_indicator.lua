function normal(shader, t_base, t_second, t_detail)
	shader:begin("stub_default", "stub_default")
		:blend(true,blend.srcalpha,blend.invsrcalpha)
		:zb(true,false)
	shader:dx10texture("s_base", t_base)
	shader:dx10sampler("smp_base")
end