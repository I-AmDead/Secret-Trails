function normal		(shader, t_base, t_second, t_detail)
	shader:begin	("deffer_model_flat","deffer_base_flat")
			: fog		(true)
	shader:sampler	("s_base")      :texture	(t_base)
	shader:sampler	("s_bump")      :texture	(t_base.."_bump")
	shader:sampler	("s_bumpX")     :texture	(t_base.."_bump#")
end

function l_special	(shader, t_base, t_second, t_detail)
	shader:begin	("shadow_direct_model",	"accum_emissivel")
			: zb 		(true,true)
			: fog		(true)
			: emissive 	(true)
end