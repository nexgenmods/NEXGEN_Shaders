//########################################################//
//                                                        //
//                ReShade effect .fx file                 //
//                 github.com/NexgenMods                  //
//                 https://nexgenmods.com                 //
//                                                        //
//                      Support me:                       //
//                 patreon.com/nexgenmods                 //
//                                                        //
//  Compare Before & After of ReShade effects "Compare"   //
//                 by NEXGEN / NexgenMods                 //
//                                                        //
//Copyright (c) NEXGEN / Nexgen Mods. All rights reserved.//
//                                                        //
//########################################################//

#include "ReShadeUI.fxh"
uniform bool CP_USE_LINE <
    ui_label = "Use Separation line";
    ui_tooltip = "Enable this to draw a separation line on the center of the screen";
> = true;    
uniform float3 LineColor < __UNIFORM_COLOR_FLOAT3
	ui_label = "Line Color";
	ui_tooltip = "Choose any color";
> = float3(1.0, 1.0, 1.0); 
uniform int LineWidthPixels < __UNIFORM_SLIDER_INT1
	ui_units = " pixels";
	ui_label = "Line Width";
	ui_tooltip = "Choose line width in pixels";
	ui_min = 1; ui_max = 16;
> = 4;
uniform bool CP_USE_ZOOM_OFFSET <
    ui_label = "Use Zoom & Offset";
    ui_tooltip = "Enable this to draw a separation line on the center of the screen";
> = false; 
uniform float ZoomValue < __UNIFORM_SLIDER_FLOAT1
    ui_min = 1.0;
    ui_max = 2.0;
    ui_tooltip = "example tooltip"; >
    = 1.0;
uniform int XOffset < __UNIFORM_SLIDER_INT1
	ui_units = " pixels";
	ui_label = "X Offset";
	ui_tooltip = "Choose X Offset in pixels";
	ui_min = 0; ui_max = BUFFER_WIDTH;
> = 0;
uniform int YOffset < __UNIFORM_SLIDER_INT1
	ui_units = " pixels";
	ui_label = "Y Offset";
	ui_tooltip = "Choose Y Offset in pixels";
    ui_min = 0; ui_max = BUFFER_HEIGHT;
> = 0;
#include "ReShade.fxh"
texture BeforeTarget {Width = BUFFER_WIDTH;	Height = BUFFER_HEIGHT; };
sampler BeforeSampler { Texture = BeforeTarget; };
void ExamplePS0(float4 pos : SV_Position, float2 texcoord : TEXCOORD0, out float4 fragColor : SV_Target) {
    float3 col = tex2D(ReShade::BackBuffer, texcoord).rgb;
    fragColor = float4(col, 0.0);
}
float4 PS_Before5(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
    return tex2D(ReShade::BackBuffer, texcoord);
}
float4 PS_After5(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
    float4 fragColor;
    float2 center = float2(0.5, 0.5);
    float aspectRatio = BUFFER_WIDTH / BUFFER_HEIGHT;
    float2 leftTexcoord = texcoord;
    float2 rightTexcoord = texcoord;
    float XOffsetPixels = (float)XOffset / BUFFER_WIDTH;
    float YOffsetPixels = (float)YOffset / BUFFER_HEIGHT;
    if (CP_USE_ZOOM_OFFSET) {
        if (texcoord.x < center.x) {    
            leftTexcoord.x = (texcoord.x + 0.25) * aspectRatio + XOffsetPixels;
            leftTexcoord.y = texcoord.y + YOffsetPixels;
            leftTexcoord *= 1.0 / ZoomValue;
        } else {
            rightTexcoord.x = (texcoord.x - 0.25) * aspectRatio + XOffsetPixels;
            rightTexcoord.y = texcoord.y + YOffsetPixels;
            rightTexcoord *= 1.0 / ZoomValue;
        }
    }
    else {
        if (texcoord.x < center.x) {    
            leftTexcoord.x = (texcoord.x + 0.25) * aspectRatio;
            leftTexcoord.y = texcoord.y;
        } else {
            rightTexcoord.x = (texcoord.x - 0.25) * aspectRatio;
            rightTexcoord.y = texcoord.y;
        }
    }
    float3 col1 = tex2D(BeforeSampler, leftTexcoord).rgb;
    float3 col2 = tex2D(ReShade::BackBuffer, rightTexcoord).rgb;
    float LineWidth = (float)LineWidthPixels / BUFFER_WIDTH;
    float3 col3;
    if (CP_USE_LINE && abs(texcoord.x - center.x) < LineWidth) {
        col3 = LineColor;
    }
    return fragColor = float4(texcoord.x < center.x ? col1 + col3 : col2 + col3, 0.0);
}
technique Compare_Top
< 
    ui_tooltip = "            >> Compare v0.1 <<\n"
               "Only available via patreon.com/nexgenmods\n\n"
               "Put this at the top of the Shader list\n";
    ui_label = "Compare (Move to Top)";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Before5;
        RenderTarget = BeforeTarget;
    }
}
technique Compare_Bottom
<
    ui_tooltip = "            >> Compare v0.1 <<\n"
               "Only available via patreon.com/nexgenmods\n\n"
               "Put this at the bottom of the Shader list\n";
    ui_label = "Compare (Move to Bottom)";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_After5;
    }
}