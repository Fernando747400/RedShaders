#ifndef MAINLIGHT_INCLUDED
#define MAINLIGHT_INCLUDED

void LightDirection_float(out float3 direction, out float3 color, out float distanceAttenuation)
{   // it's fundamental to follow the same "vector order" in the Graph Inspector. First the Direction, then the Color and so on ... 
#ifdef SHADERGRAPH_PREVIEW
    direction = float3(0, 1, 0);
    color = float3(1, 1, 1);
    distanceAttenuation = 1.0;
#else

#if defined(UNIVERSAL_LIGHTING_INCLUDED)
    Light mainLight = GetMainLight();
    direction = mainLight.direction;
    color = mainLight.color;
    distanceAttenuation = mainLight.distanceAttenuation;
#endif

#endif
}

#endif

