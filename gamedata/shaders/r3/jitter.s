function jitter(shader)
	shader:dx10texture("jitter0", "$user$jitter_0")
	shader:dx10texture("jitter1", "$user$jitter_1")
	shader:dx10texture("jitter2", "$user$jitter_2")
	shader:dx10texture("jitter3", "$user$jitter_3")
	shader:dx10texture("jitter4", "$user$jitter_4")
	shader:dx10sampler("smp_jitter")
end