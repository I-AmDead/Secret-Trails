function element_0(shader, t_base, t_second, t_detail)
	shader:begin("stub_notransform_t", "dumb")
		:fog(false)
		:zb(false, false)
	shader:dx10color_write_enable(false, false, false, false)
	shader:dx10cullmode(1)
	shader:dx10stencil(true, cmp_func.lessequal, 255, 0, stencil_op.keep, stencil_op.keep, stencil_op.keep)
end

function element_1(shader, t_base, t_second, t_detail)
	local opt = shader:dx10Options()
	local w_mask = opt:msaa_enable() and 126 or 254
	shader:begin("stub_notransform_t", "dumb")
		:fog(false)
		:zb(false, false)
	shader:dx10color_write_enable(false, false, false, false)
	shader:dx10cullmode(1)
	shader:dx10stencil(true, cmp_func.always, 0, w_mask, stencil_op.zero, stencil_op.zero, stencil_op.zero)
end
