function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("stub_notransform_2uv", "mark_msaa_edges")
			: fog	(false)
			: zb 	(false,false)
	shader:dx10texture	("s_position", "$user$position")
	shader:dx10texture	("s_normal", "$user$normal")
	shader:dx10sampler	("smp_nofilter")
end