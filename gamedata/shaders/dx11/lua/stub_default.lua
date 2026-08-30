function normal(shader, t_base, t_second, t_detail)
	shader:begin("stub_default", "stub_default")
	shader:dx10texture("s_base", t_base)
	shader:dx10sampler("smp_base")
end