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

//Varyings
out vec4 vColor;

void main(){
	//Position Pipeline
	mat4 modelViewMat = uViewMat * uModelMat; //Model View Matrix
	//vec4 pos_world = uModelMat * aPosition; //World Space
	vec4 pos_camera = modelViewMat * aPosition; //Position in camera Space
	vec4 pos_clip = uProjectionMat * pos_camera; //Position in Clip Space
	gl_Position = pos_clip;
	
	vColor = aPosition;

}
