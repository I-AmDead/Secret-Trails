function elemets(shader, t_base, t_second, t_detail, ps_shader, jitter_enable)
	local opt = shader:dx10Options()
	local dest = opt:fp16_blend_enable() and blend.one or blend.zero
	shader:begin("accum_volume", ps_shader)
		:fog(false)
		:zb(false, false)
		:blend(opt:fp16_blend_enable(), blend.one, dest)
	shader:dx10texture("s_position", "$user$position")
	shader:dx10texture("s_normal", "$user$normal")
	shader:dx10texture("s_accumulator", "$user$accum")
	shader:dx10texture("s_lmap", t_base)
	shader:dx10texture("s_diffuse", "$user$albedo")
	
	if jitter_enable then
		shader:dx10texture("s_smap", "$user$smap_depth")
		jitter.jitter(shader)
		shader:dx10sampler("smp_smap")
	end

	shader:dx10sampler("smp_nofilter")
	shader:dx10sampler("smp_material")
	shader:dx10sampler("smp_rtlinear")
end

function element_0(shader, t_base, t_second, t_detail)
	shader:begin("stub_notransform", "copy")
		:fog(false)
		:zb(false, false)
	shader:dx10texture("s_base", t_base)
	shader:dx10sampler("smp_nofilter")
end

function element_1(shader, t_base, t_second, t_detail)
	elemets(shader, t_base, t_second, t_detail, "accum_spot_unshadowed", false)
end

function element_2(shader, t_base, t_second, t_detail)
	elemets(shader, t_base, t_second, t_detail, "accum_spot_normal", true)
end

function element_3(shader, t_base, t_second, t_detail)
	elemets(shader, t_base, t_second, t_detail, "accum_spot_fullsize", true)
end

function element_4(shader, t_base, t_second, t_detail)
	elemets(shader, t_base, t_second, t_detail, "accum_spot_fullsize", true)
end