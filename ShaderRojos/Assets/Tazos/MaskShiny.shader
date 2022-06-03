Shader "Unlit/MaskShiny"
{
     Properties
    {
        Vector1_caf5230dcb5b4e188d7fcff085a66996("Disolve", Range(0, 1)) = 0
        Vector1_d34580062b8d4009b43fe7f2cf79f456("EdgeWidth", Range(0, 0.1)) = 0.04
        [HDR]Color_7b71681ba7424d908ba5bc7f696f92e5("EdgeColor", Color) = (0, 1, 0.7600644, 0)
        [NoScaleOffset]Texture2D_bade94d03d3b425f97615a259844da8a("Texture", 2D) = "white" {}
        Vector1_248b0a04eb054b48897e7239df5dcf55("Height", Float) = 0.01903
        Vector3_7e971d107bad484993324916f96c4a29("DisolveVector", Vector) = (3, 0, 3, 0)
        Vector1_28a577b8ad204d15af5a0dc3320f16ef("Speed", Float) = 5
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
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
        Blend One Zero
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
            #define _AlphaClip 1
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
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bade94d03d3b425f97615a259844da8a);
            float4 _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0 = SAMPLE_TEXTURE2D(_Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.tex, _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_R_4 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.r;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_G_5 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.g;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_B_6 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.b;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_A_7 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.a;
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1;
            Unity_OneMinus_float(_Step_a1ff088f7c274b72978504224275e7e4_Out_2, _OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1);
            float4 _Property_e46fb08a44a448038ec9d2fcb888ba49_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_7b71681ba7424d908ba5bc7f696f92e5) : Color_7b71681ba7424d908ba5bc7f696f92e5;
            float4 _Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2;
            Unity_Multiply_float((_OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1.xxxx), _Property_e46fb08a44a448038ec9d2fcb888ba49_Out_0, _Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.BaseColor = (_SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
        Blend One Zero
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
            #define _AlphaClip 1
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
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bade94d03d3b425f97615a259844da8a);
            float4 _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0 = SAMPLE_TEXTURE2D(_Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.tex, _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_R_4 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.r;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_G_5 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.g;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_B_6 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.b;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_A_7 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.a;
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1;
            Unity_OneMinus_float(_Step_a1ff088f7c274b72978504224275e7e4_Out_2, _OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1);
            float4 _Property_e46fb08a44a448038ec9d2fcb888ba49_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_7b71681ba7424d908ba5bc7f696f92e5) : Color_7b71681ba7424d908ba5bc7f696f92e5;
            float4 _Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2;
            Unity_Multiply_float((_OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1.xxxx), _Property_e46fb08a44a448038ec9d2fcb888ba49_Out_0, _Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.BaseColor = (_SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
        Blend One Zero
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
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
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
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
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
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
        Blend One Zero
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
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
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
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
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
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
        Blend One Zero
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
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
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
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
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
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
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
            float3 positionWS;
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
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
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
            output.interp0.xyz =  input.positionWS;
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
            output.positionWS = input.interp0.xyz;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bade94d03d3b425f97615a259844da8a);
            float4 _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0 = SAMPLE_TEXTURE2D(_Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.tex, _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_R_4 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.r;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_G_5 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.g;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_B_6 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.b;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_A_7 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.a;
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1;
            Unity_OneMinus_float(_Step_a1ff088f7c274b72978504224275e7e4_Out_2, _OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1);
            float4 _Property_e46fb08a44a448038ec9d2fcb888ba49_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_7b71681ba7424d908ba5bc7f696f92e5) : Color_7b71681ba7424d908ba5bc7f696f92e5;
            float4 _Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2;
            Unity_Multiply_float((_OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1.xxxx), _Property_e46fb08a44a448038ec9d2fcb888ba49_Out_0, _Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.BaseColor = (_SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.xyz);
            surface.Emission = (_Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2.xyz);
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
        Blend One Zero
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
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
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
            float3 positionWS;
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
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
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
            output.interp0.xyz =  input.positionWS;
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
            output.positionWS = input.interp0.xyz;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bade94d03d3b425f97615a259844da8a);
            float4 _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0 = SAMPLE_TEXTURE2D(_Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.tex, _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_R_4 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.r;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_G_5 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.g;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_B_6 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.b;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_A_7 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.a;
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.BaseColor = (_SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.xyz);
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
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
        Blend One Zero
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
            #define _AlphaClip 1
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
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bade94d03d3b425f97615a259844da8a);
            float4 _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0 = SAMPLE_TEXTURE2D(_Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.tex, _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_R_4 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.r;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_G_5 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.g;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_B_6 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.b;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_A_7 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.a;
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1;
            Unity_OneMinus_float(_Step_a1ff088f7c274b72978504224275e7e4_Out_2, _OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1);
            float4 _Property_e46fb08a44a448038ec9d2fcb888ba49_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_7b71681ba7424d908ba5bc7f696f92e5) : Color_7b71681ba7424d908ba5bc7f696f92e5;
            float4 _Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2;
            Unity_Multiply_float((_OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1.xxxx), _Property_e46fb08a44a448038ec9d2fcb888ba49_Out_0, _Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.BaseColor = (_SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
        Blend One Zero
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
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
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
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
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
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
        Blend One Zero
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
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
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
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
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
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
        Blend One Zero
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
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
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
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
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
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
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
            float3 positionWS;
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
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
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
            output.interp0.xyz =  input.positionWS;
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
            output.positionWS = input.interp0.xyz;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bade94d03d3b425f97615a259844da8a);
            float4 _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0 = SAMPLE_TEXTURE2D(_Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.tex, _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_R_4 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.r;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_G_5 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.g;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_B_6 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.b;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_A_7 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.a;
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1;
            Unity_OneMinus_float(_Step_a1ff088f7c274b72978504224275e7e4_Out_2, _OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1);
            float4 _Property_e46fb08a44a448038ec9d2fcb888ba49_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_7b71681ba7424d908ba5bc7f696f92e5) : Color_7b71681ba7424d908ba5bc7f696f92e5;
            float4 _Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2;
            Unity_Multiply_float((_OneMinus_0c8faf942cf84c66b94809b801b778ef_Out_1.xxxx), _Property_e46fb08a44a448038ec9d2fcb888ba49_Out_0, _Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.BaseColor = (_SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.xyz);
            surface.Emission = (_Multiply_cacefcb35d4343aea38bf398f66a2283_Out_2.xyz);
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
        Blend One Zero
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
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
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
            float3 positionWS;
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
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 TimeParameters;
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
            output.interp0.xyz =  input.positionWS;
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
            output.positionWS = input.interp0.xyz;
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
        float Vector1_caf5230dcb5b4e188d7fcff085a66996;
        float Vector1_d34580062b8d4009b43fe7f2cf79f456;
        float4 Color_7b71681ba7424d908ba5bc7f696f92e5;
        float4 Texture2D_bade94d03d3b425f97615a259844da8a_TexelSize;
        float Vector1_248b0a04eb054b48897e7239df5dcf55;
        float3 Vector3_7e971d107bad484993324916f96c4a29;
        float Vector1_28a577b8ad204d15af5a0dc3320f16ef;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bade94d03d3b425f97615a259844da8a);
        SAMPLER(samplerTexture2D_bade94d03d3b425f97615a259844da8a);

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
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
            float3 _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0 = Vector3_7e971d107bad484993324916f96c4a29;
            float3 _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, _Property_1fa9a9e27e8c4fddbaac5f594c81fe06_Out_0, _Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2);
            float _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_9d888eb44bcf45ffb0f0b2ae36fd9850_Out_0, _Multiply_311752e590a6403ab99d949c5e902c4a_Out_2);
            float _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1;
            Unity_Sine_float(_Multiply_311752e590a6403ab99d949c5e902c4a_Out_2, _Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1);
            float _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3;
            Unity_Remap_float(_Sine_8b5721525c9e48a9bdfcc533082b188a_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3);
            float _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2;
            Unity_Subtract_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, -0.1, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2);
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_75e774e8ed81435283952e0e5f508bc0_Out_0 = Vector1_d34580062b8d4009b43fe7f2cf79f456;
            float _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2;
            Unity_Subtract_float(_OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1, _Property_75e774e8ed81435283952e0e5f508bc0_Out_0, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2);
            float _Step_a1ff088f7c274b72978504224275e7e4_Out_2;
            Unity_Step_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_fb8af087f0c744028b50853a7516bb15_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2);
            float _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3;
            Unity_Smoothstep_float(_Remap_28ec8464a6b94fa88a36b760604f8cd4_Out_3, _Subtract_b39908a3ebcd46e8b7c83a271582ae1b_Out_2, _Step_a1ff088f7c274b72978504224275e7e4_Out_2, _Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3);
            float _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1;
            Unity_OneMinus_float(_Smoothstep_d61633c30e974ed3b1e31dd98d53cf18_Out_3, _OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1);
            float _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2;
            Unity_Power_float(_OneMinus_36bd54c9c98f481894b7da9a8d6fa587_Out_1, 3, _Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2);
            float3 _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2;
            Unity_Multiply_float(_Multiply_71f15c97a74c4bfc8e894aed6333ab25_Out_2, (_Power_be4c8f192a2141d0b643ff54e78b6f16_Out_2.xxx), _Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2);
            float3 _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            Unity_Add_float3(_Multiply_df5fdfc30a4e4deea544dbbc4451ba5e_Out_2, IN.ObjectSpacePosition, _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2);
            description.Position = _Add_1c59d6df14e64dd29dea40525ddbc928_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bade94d03d3b425f97615a259844da8a);
            float4 _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0 = SAMPLE_TEXTURE2D(_Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.tex, _Property_72bbe07fcc634fdcb5fff7c6c0f2977f_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_R_4 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.r;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_G_5 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.g;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_B_6 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.b;
            float _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_A_7 = _SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.a;
            float _Split_6f85bad314f440e198d1cddbf136f8e1_R_1 = IN.ObjectSpacePosition[0];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_G_2 = IN.ObjectSpacePosition[1];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_B_3 = IN.ObjectSpacePosition[2];
            float _Split_6f85bad314f440e198d1cddbf136f8e1_A_4 = 0;
            float _Property_ea33fe95516441848586d2dd0654972e_Out_0 = Vector1_248b0a04eb054b48897e7239df5dcf55;
            float _Divide_90e8abcd7c1649d59d452213845329cd_Out_2;
            Unity_Divide_float(_Split_6f85bad314f440e198d1cddbf136f8e1_G_2, _Property_ea33fe95516441848586d2dd0654972e_Out_0, _Divide_90e8abcd7c1649d59d452213845329cd_Out_2);
            float _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3;
            Unity_Remap_float(_Divide_90e8abcd7c1649d59d452213845329cd_Out_2, float2 (0, 1), float2 (0.05, 0.95), _Remap_931b2524a8cf4367aae96ff3f510b276_Out_3);
            float _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            Unity_OneMinus_float(_Remap_931b2524a8cf4367aae96ff3f510b276_Out_3, _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1);
            float _Property_f1513644037b464aac82f98106c2fc9f_Out_0 = Vector1_28a577b8ad204d15af5a0dc3320f16ef;
            float _Multiply_8626a10a346246bb934153394b39ee82_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_f1513644037b464aac82f98106c2fc9f_Out_0, _Multiply_8626a10a346246bb934153394b39ee82_Out_2);
            float _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1;
            Unity_Sine_float(_Multiply_8626a10a346246bb934153394b39ee82_Out_2, _Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1);
            float _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
            Unity_Remap_float(_Sine_bdea25e5072f40338c71e25fd6bb128e_Out_1, float2 (-1, 1), float2 (0, 1), _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3);
            surface.BaseColor = (_SampleTexture2D_7ecc3468083448fb93f99f359ae9b5f7_RGBA_0.xyz);
            surface.Alpha = _OneMinus_2f90c38311f34d85a52477ed2b09aa70_Out_1;
            surface.AlphaClipThreshold = _Remap_46362de317dd4453bf6eafa85d0c7212_Out_3;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
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
