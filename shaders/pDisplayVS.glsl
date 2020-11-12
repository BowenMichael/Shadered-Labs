#version 450

//Uniforms
uniform mat4 uViewMat;
uniform mat4 uModelMat;
uniform mat4 uProjectionMat;
uniform mat4 uViewProjMat;
uniform sampler2D tex;
uniform float time;

//Attributes
layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aTexCoord;

//Varyings
out vec4 vColor;
out vec2 vTexCoord;
out vec4 vPosition;

//Global Structures
struct sLight
{
	vec4 center;
    vec4 color;
    float intensity;
};

void main(){

	//InClass
	gl_Position = aPosition;
    //vTexCoord = aTexCoord; //:(
    vTexCoord = aPosition.xy *.5 + .5;
	
	



	
	//DEBUG
	//______________________________________________________
	//gl_Position = aPosition; //Point
	//gl_Position = pos_world; //Point
	//gl_Position = pos_camera; //Point
    //gl_Position = pos_clip; //Point if orthographic //in perspective w = distance from viewer ////gl_Position = pos_clip / pos_clip.w; //NDC SPACE in perspective
	

	//NOT IN VS
	//BTS of VS
	// NDC = CLIP / CLIP.W
	// W = 1
	//Visable region is contained within [-1, +1]
			
	


}
