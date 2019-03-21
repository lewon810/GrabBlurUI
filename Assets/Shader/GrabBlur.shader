// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/GrabBlur"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

		_BlurSize("Blur Size", Float)=1
		_Width("Width", Float)=1280
		_Height("Height", Float)=720

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        //Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

		GrabPass
        {
            "_GrabTex"
        }

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = v.texcoord;

                OUT.color = v.color * _Color;
                return OUT;
            }

			sampler2D _GrabTex;
            sampler2D _MainTex;
			float _BlurSize;
			float _Width;
			float _Height;

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
				half4 grabColor = (tex2D(_GrabTex, IN.texcoord));

				//blur params
				float v;
				float pi = 3.141592653589793;
				float e_step = 1.0 / _Width;
				float radius = max(_BlurSize , 0);
				int steps = int(min(radius * 0.7, sqrt(radius) * pi));
				float r = radius / steps;
				float t = 1.0 / (steps * 2 + 1);
				float x =IN.texcoord.x;
				float y =IN.texcoord.y;

				//blur horizontal
				half4 sum = tex2D(_GrabTex, float2(x, y)) * t;
				int i;
				for(i = 1; i <= steps; i++){
					v = (cos(i / (steps + 1) / pi) + 1) * 0.5;
					sum += tex2D(_GrabTex, float2(x + i * e_step * r, y)) * v * t;
					sum += tex2D(_GrabTex, float2(x - i * e_step * r, y)) * v * t;
					sum += tex2D(_GrabTex, float2(x, y + i * e_step * r)) * v * t;
					sum += tex2D(_GrabTex, float2(x, y - i * e_step * r)) * v * t;
				}

				#ifdef false
				//blur vertical
				e_step = 1.0 / _Height;
				half4 sum2 = tex2D(_GrabTex, float2(x, y)) * t;
				for(i = 1; i <= steps; i++){
					v = (cos(i / (steps + 1) / pi) + 1) * 0.5;
					sum += tex2D(_GrabTex, float2(x, y + i * e_step * r)) * v * t;
					sum += tex2D(_GrabTex, float2(x, y - i * e_step * r)) * v * t;
				}
				#endif

				//alpha blend
				color = (color.a * sum) + (color * (1.0 - color.a));
				color.a = 1;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                return color;
            }
        ENDCG
        }
    }
}
