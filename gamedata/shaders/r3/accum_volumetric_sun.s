function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("stub_notransform_2uv", "accum_volumetric_sun")
			: fog		(false)
			: zb 		(false,false)
			: blend		(true,blend.one,blend.one)
			: sorting	(2, false)
	shader:dx10texture	("s_smap", "null")
	shader:dx10texture  ("s_smap_minmax",	"$user$smap_depth_minmax");
	shader:dx10texture	("s_position", "$user$position")
	shader:dx10texture	("jitter0", "$user$jitter_0")

	shader:dx10sampler	("smp_nofilter")
	shader:dx10sampler	("smp_jitter")
	shader:dx10sampler	("smp_smap")
end