function normal(shader, t_base, t_second, t_detail)
	shader:begin("stub_notransform_2uv", "create_minmax_sm")
		:fog(false)
		:zb(false,false)
	shader:dx10texture("s_smap", "$user$smap_depth")
	shader:dx10sampler("smp_nofilter")
end