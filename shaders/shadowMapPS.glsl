#version 450

//Uniforms
layout (location  = 0) uniform sampler2D uTex;
layout (location = 1) uniform vec2 uResolution;
layout (location = 2) uniform sampler2D uDepth;

//Attributes
layout (location = 2) in vec2 texCoord;

//Varyings
in vec4 vColor;
in vec4 vNormal;
in vec4 vPosition;
in vec2 vTexCoord;
in float vDepth;

//Color Target
layout (location = 0) out vec4 rtFragColor;

//Global Vars
float near = 0.1; 
float far  = 100.0; 

void main(){
	vec2 uv = vTexCoord;
	vec4 col = texture(uTex, uv.xy);
	vec4 depthMap = texture(uDepth, uv.xy);
	//float depth = depthMap.x  * 2. - 1.;
	//float linearDepth = (2.0 * near * far) / (far + near - depth * (far - near)) / far;
	
	//rtFragColor = col;
	//rtFragColor = vec4(vec3(linearDepth), 1.0);
	if(depthMap.z > depthMap.w)
		rtFragColor = vec4(1.0);
	else{
		rtFragColor = vec4(0.0);
	}
	//rtFragColor = vec4(vec3(depthMap.x),1.0);
}
