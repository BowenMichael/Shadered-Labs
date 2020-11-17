#version 450

//Uniforms

//Attributes

//Varyings
in vec4 vNormal;
in vec4 vPosition;
in vec4 vDepth;
in vec4 vTexCoord;
in vec4 vLightSpaceCoord;

//Color Target
layout (location = 0) out vec4 rtFragColor;
layout (location = 1) out vec4 rtDepth;

void main(){
	//Prespective Divide
	//vec4 ndc = 
	vec3 screen_space = vLightSpaceCoord.xyz * .5 + .5;

	//vec3 ndc = vDepth.xyz / vDepth.z;
	vec2 uv = vTexCoord.xy / vTexCoord.z; 
	rtDepth = vec4(screen_space, vDepth.w );
	rtFragColor = vNormal;
	rtFragColor = vPosition;
}
