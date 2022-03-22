void MainLight_half(out half3 Direction)
{
#ifndef SHADERGRAPH_PREVIEW
	Light light = GetMainLight();
	Direction = light.direction;
#else
	Direction = half3(0, 1, 0);
#endif
}