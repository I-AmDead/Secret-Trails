function normal(shader, t_base, t_second, t_detail)
 shader:begin  	("deffer_model_flat", "models_lense_window")
      : fog    		(false)
      : zb     		(true,false)
      : blend           (true,blend.srcalpha,blend.zero)


      : sorting         (2, true)
	shader:dx10texture("s_base", t_base)
	shader:dx10sampler("smp_base")
	shader:dx10stencil(true, cmp_func.always, 255, 127, stencil_op.keep, stencil_op.keep, stencil_op.keep)
	shader:dx10stencil_ref(1)
end
