function normal(shader, t_base, t_second, t_detail)
	local opt = shader:dx10Options()
	local dest = opt:fp16_blend_enable() and blend.one or blend.zero
	shader:begin("accum_volume", "accum_indirect")
		:fog(false)
		:zb(false, false)
		:blend(opt:fp16_blend_enable(), blend.one, dest)
	shader:dx10texture("s_position", "$user$position")
	shader:dx10texture("s_normal", "$user$normal")
	shader:dx10texture("s_material", "$user$material")
	shader:dx10texture("s_diffuse", "$user$albedo")
	shader:dx10texture("s_accumulator", "$user$accum")

	shader:dx10sampler("smp_nofilter")
	shader:dx10sampler("smp_material")
end