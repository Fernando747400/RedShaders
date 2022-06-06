Shader "Cubo"
{
    Properties
    {
        [NoScaleOffset]Circles_Texture("Circles", 2D) = "white" {}
        [NoScaleOffset]Rainbow_Texture("Rainbow", 2D) = "white" {}
        Sample_Color("SampleColor", Float) = 0.5
        [NonModifiableTextureData][NoScaleOffset]_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0("Texture2D", 2D) = "white" {}
        [NonModifiableTextureData][NoScaleOffset]_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0("Texture2D", 2D) = "white" {}
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
          LOD 100

        Stencil{
            ref 1
            comp equal
            }
           
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.BaseColor = (_Multiply_99005517bb5a477e9204172f56020d5f_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.BaseColor = (_Multiply_99005517bb5a477e9204172f56020d5f_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.BaseColor = (_Multiply_99005517bb5a477e9204172f56020d5f_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.BaseColor = (_Multiply_99005517bb5a477e9204172f56020d5f_Out_2.xyz);
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.BaseColor = (_Multiply_99005517bb5a477e9204172f56020d5f_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.BaseColor = (_Multiply_99005517bb5a477e9204172f56020d5f_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_CULLFACE
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
            float FaceSign;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0_TexelSize;
        float4 _Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0_TexelSize;
        float4 Circles_Texture_TexelSize;
        float4 Rainbow_Texture_TexelSize;
        float Sample_Color;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        SAMPLER(sampler_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0);
        TEXTURE2D(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        SAMPLER(sampler_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0);
        TEXTURE2D(Circles_Texture);
        SAMPLER(samplerCircles_Texture);
        TEXTURE2D(Rainbow_Texture);
        SAMPLER(samplerRainbow_Texture);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_01b9a0b31f224c75878f124f4a30dd66_Out_0).samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.r;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_G_5 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.g;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_B_6 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.b;
            float _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_A_7 = _SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_RGBA_0.a;
            float _Property_f997da9245af4f559cf85a445bb7e14d_Out_0 = Sample_Color;
            float _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f997da9245af4f559cf85a445bb7e14d_Out_0, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2);
            float _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2;
            Unity_Add_float(_SampleTexture2D_1089da49eb3449e38d9c725f2e4ccf69_R_4, _Multiply_a53bf9233aa44e6d87b765d4cae70b1e_Out_2, _Add_4d11fb49ea6e4c3897229f90494602ac_Out_2);
            float2 _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0 = float2(_Add_4d11fb49ea6e4c3897229f90494602ac_Out_2, 0);
            float2 _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_11817ccb90c849ef8a58a4cb8e4b6982_Out_0, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float4 _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).tex, UnityBuildTexture2DStructNoScale(_Texture2DAsset_3da18e49c74647f59ba87dcaae530347_Out_0).samplerstate, _TilingAndOffset_32b38ebe9a6b45d3979053a7951cb540_Out_3);
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_R_4 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.r;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_G_5 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.g;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_B_6 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.b;
            float _SampleTexture2D_674b71b68292493b829abf36cbaa0294_A_7 = _SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0.a;
            float _IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0 = max(0, IN.FaceSign);
            float _Branch_90bc89a918654dd2820e2109561cb575_Out_3;
            Unity_Branch_float(_IsFrontFace_86ebfc3fabe6429c9036ae9c3cd69e59_Out_0, 0, 1, _Branch_90bc89a918654dd2820e2109561cb575_Out_3);
            float4 _Multiply_99005517bb5a477e9204172f56020d5f_Out_2;
            Unity_Multiply_float(_SampleTexture2D_674b71b68292493b829abf36cbaa0294_RGBA_0, (_Branch_90bc89a918654dd2820e2109561cb575_Out_3.xxxx), _Multiply_99005517bb5a477e9204172f56020d5f_Out_2);
            float _Split_703c992d901748f9b476046395dda95b_R_1 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[0];
            float _Split_703c992d901748f9b476046395dda95b_G_2 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[1];
            float _Split_703c992d901748f9b476046395dda95b_B_3 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[2];
            float _Split_703c992d901748f9b476046395dda95b_A_4 = _Multiply_99005517bb5a477e9204172f56020d5f_Out_2[3];
            surface.BaseColor = (_Multiply_99005517bb5a477e9204172f56020d5f_Out_2.xyz);
            surface.Alpha = _Split_703c992d901748f9b476046395dda95b_A_4;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}