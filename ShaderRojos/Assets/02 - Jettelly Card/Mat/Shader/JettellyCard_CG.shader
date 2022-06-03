Shader "Custom/JettellyCard" 
{
    Properties 
    {        
        _MainTex ("MainTex", 2D) = "white" {}       
        _ReflectionTex ("ReflectionTex", Cube) = "_Skybox" {}
        _ReflectionDepth ("Reflection Depth", Range(0, 1)) = 0.2 
        _GradientTex ("GradientTex", 2D) = "white" {}
        _GradientSpeed ("Gradient Speed", Range(0, 1)) = 0.1
        _GradientRadius ("Gradient Radius", Range(0, 1)) = 0.4
        _GradientHue ("Gradient Hue", Range(-1, 1)) = 0
        _GradientSaturation ("Gradient Saturation", Range(0, 2)) = 2
        _GradientSpecular ("Gradient Specular", Range(0, 1)) = 0.3        
        _MaskTex ("MaskTex", 2D) = "white" {}
        _MaskOpacity ("Mask Opacity", Range(0, 1)) = 1
        _NormalmapTex ("NormamapTex", 2D) = "bump" {}
        _NormalmapDepth ("Normalmap Depth", Range(0, 1)) = 1
    }
    SubShader 
    {
        Tags {"RenderType"="Opaque"}
        Blend SrcAlpha OneMinusSrcAlpha

        Pass 
        {        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma target 3.0               
            
            sampler2D _GradientTex; 
            sampler2D _MainTex; 
            sampler2D _MaskTex; 
            sampler2D _NormalmapTex; 
            samplerCUBE _ReflectionTex;
            float4 _GradientTex_ST;
            float4 _LightColor0;            
            float4 _MainTex_ST;  
            float4 _MaskTex_ST;    
            float4 _NormalmapTex_ST;  
            float _GradientRadius;    
            float _ReflectionDepth;
            float _GradientSaturation; 
            float _MaskOpacity; 
            float _NormalmapDepth;
            float _GradientSpecular;
            float _GradientHue;
            float _GradientSpeed;

            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct v2f 
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };

            v2f vert (appdata v) 
            {
                v2f o = (v2f)0;
                o.uv = v.uv;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag(v2f i) : COLOR 
            {      
                i.normalDir = normalize(i.normalDir); 
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);    
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);             
                float3 viewReflectDirection = reflect(-viewDirection, i.normalDir );  
                float3 halfDirection = normalize(viewDirection + lightDirection);                
                float attenuation = LIGHT_ATTENUATION(i);                
                float3 light_color = attenuation * _LightColor0.xyz;              
                float specPow = exp2(_GradientRadius * 10);  
                float ndotl = max(0, dot(i.normalDir, lightDirection));                
                float4 mask_tex = tex2D(_MaskTex,TRANSFORM_TEX(i.uv, _MaskTex));              
                float maskTransparency = (mask_tex.r * _MaskOpacity);
                float subtract = (1.0 - maskTransparency);                
                float4 main_tex = tex2D(_MainTex,TRANSFORM_TEX(i.uv, _MainTex));               
                float3 up_normals = UnpackNormal(tex2Dlod(_NormalmapTex,float4(TRANSFORM_TEX(i.uv, _NormalmapTex),0 ,0)));               
                float gradient_hue = _WorldSpaceCameraPos.x + _GradientHue;
                float2 gradient_uvs = (lerp(float3(0, 0, 1), up_normals.rgb, _NormalmapDepth).rg + gradient_hue + mul( unity_WorldToObject, float4(((viewReflectDirection * viewDirection) + lightDirection), 0) ).xyz.rgb.rg);                
                float4 gradient_tex = tex2Dlod(_GradientTex, float4(TRANSFORM_TEX(float2(gradient_uvs.x, gradient_uvs.y + (_Time.y * _GradientSpeed)), _GradientTex),0, 0));                               
                float3 gradient_saturation = (gradient_tex.rgb * _GradientSaturation);
                float3 specularColor = (subtract * lerp((main_tex.rgb * gradient_saturation), gradient_saturation, 1));
                float3 directSpecular = (floor(attenuation) * _LightColor0.xyz) * pow(max(0,dot(halfDirection,i.normalDir)),specPow) * specularColor; 
                float3 directDiffuse = max(0, ndotl) * light_color;
                float3 indirectDiffuse = float3(0, 0, 0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb;
                float3 mask_depth = lerp((_GradientSpecular * gradient_tex.rgb), dot((_GradientSpecular * gradient_tex.rgb), float3(0.4, 0.4, 0.4)), 1.0);
                float3 diffuseColor = lerp(lerp((mask_depth * main_tex.rgb),mask_depth, 1),main_tex.rgb, maskTransparency);
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
                float3 emissive = (texCUBElod(_ReflectionTex, float4(viewReflectDirection, 1)).rgb * _ReflectionDepth);
                float3 render = diffuse + directSpecular + emissive;
                return fixed4(render, 1);
            }
            ENDCG
        }
    }
}