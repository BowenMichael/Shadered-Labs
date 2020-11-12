#version 450

//Uniforms
layout (location  = 0) uniform sampler2D uTex;
layout (location = 1) uniform vec2 uResolution;

//Attributes
layout (location = 2) in vec2 texCoord;

//Varyings
in vec4 vColor;
in vec2 vTexCoord;
in vec4 vPosition;
in vec2 vResolution;
//out sampler2D outputTex;

//Color Target
layout (location = 0) out vec4 rtFragColor;

void main(){
	//Inclass	
	//1) uv = screen Location / screen Resolution
	//2) (aPosition)
	//vec2 uv = gl_FragCoord.xy / uResolution;
	vec2 uv = vTexCoord;
	vec4 col = texture(uTex, uv.xy);
	
	rtFragColor = col;
	
	
	//rtFragColor = texture(tex, vTexCoord);
	
	
	//MANUAL PERSPECTIVE DIVIDE
	//vec4 ndc = vColor / vColor.w;
	//rtFragColor = ndc;
	//[-1,1] Containst all visual space
	
	//Screen Space
	//vec4 screen_space = ndc * 0.5 + .5;
	//rtFragColor = screen_space;
	//NDC[-1,1] to screen_space[0,1]
	//rtFragColor = texture(tex, vTexCoord.xy);
	
	
	//rtFragColor.b = 0.0f;
	
	//___________________________________
	//DEBUG
	//rtFragColor = vec4(1.0, .5, 0.0, 1.);
	
	//gl_FragCoord
	//rtFragColor = vec4(uv, 0., 1.);;
}
