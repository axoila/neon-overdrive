﻿Shader "Custom/Grid" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_Repetition ("Rate of lights", Range(3.14, 20)) = 12
		_Intensity ("Emission intensity", Range(0, 1)) = 0.5
		_Speed ("Wandering Speed", Range(1, 10)) = 3
		_GridScale ("Grid scale (UV)", Vector) = (1, 1, 0, 0)
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		uniform float4 origin0 = float4(0, 0, 0, 0);
		uniform float4 origin1 = float4(0, 0, 0, 0);
		uniform float radius0 = 0;
		uniform float radius1 = 0;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		half _Repetition;
		half _Intensity;
		half _Speed;

		float4 _GridScale;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			
			float2 uv = IN.uv_MainTex;

			float3 toPoint0 = origin0 - IN.worldPos;
			float3 toPoint1 = origin1 - IN.worldPos;

			float3 point1offset = normalize(toPoint0) * radius0 / length(toPoint0);
			float3 point2offset = normalize(toPoint1) * radius1 / length(toPoint1);

			uv += (point1offset + point2offset) * _GridScale.xy;

			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, uv) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			float movingBack = sin(clamp(fmod(_Time.y * _Speed + uv.y, _Repetition), 0, 3.14)) * _Intensity;
			o.Emission = c.rgb * movingBack;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}