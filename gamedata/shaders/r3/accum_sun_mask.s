function element_0(shader, t_base, t_second, t_detail)
	shader:begin("accum_mask", "dumb")
		:fog(false)
		:zb(true, false)
	shader:dx10color_write_enable(false, false, false, false)
end

function element_1(shader, t_base, t_second, t_detail)
	shader:begin("accum_mask", "dumb")
		:fog(false)
		:zb(true, false)
	shader:dx10color_write_enable(false, false, false, false)
end

function element_2(shader, t_base, t_second, t_detail)
	shader:begin("stub_notransform_t", "accum_sun_mask")
		:fog(false)
		:zb(false, false)
		:blend(true, blend.zero,blend.one)
		:aref(true, 1)
	shader:dx10color_write_enable(false, false, false, false)
	shader:dx10texture("s_position", "$user$position")
	shader:dx10texture("s_normal", "$user$normal")
	shader:dx10texture("s_diffuse", "$user$albedo")

	shader:dx10sampler("smp_nofilter")
end

function element_3(shader, t_base, t_second, t_detail)
	shader:begin("accum_volume", "copy_p")
		:fog(false)
		:zb(false, false)
	shader:dx10texture("s_generic", "$user$accum_temp")
	shader:dx10sampler("smp_nofilter")
end

function element_4(shader, t_base, t_second, t_detail)
	shader:begin("stub_notransform_t", "copy")
		:fog(false)
		:zb(false, false)
	shader:dx10texture("s_generic", "$user$accum_temp")
	shader:dx10sampler("smp_nofilter")
end

function element_5(shader, t_base, t_second, t_detail)
	shader:begin("stub_notransform_t", "copy")
		:fog(false)
		:zb(false, false)
	shader:dx10texture("s_generic", "$user$accum")
	shader:dx10sampler("smp_nofilter")
end

