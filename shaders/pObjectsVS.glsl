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


//Varyings
out vec4 vColor;
out vec4 vNormal;

//Global Structures
struct sLight
{
	vec4 center;
    vec4 color;
    float intensity;
};

void main(){

		//Position Pipeline
	mat4 modelViewMat = uViewMat * uModelMat; //Model View Matrix
	//vec4 pos_world = uModelMat * aPosition; //World Space
	vec4 pos_camera = modelViewMat * aPosition; //Position in camera Space
	vec4 pos_clip = uProjectionMat * pos_camera; //Position in Clip Space
	gl_Position = pos_clip;
	
	//Normal Pipeline
	mat3 normalMat = transpose(inverse(mat3(modelViewMat)));
	vec3 norm_camera = normalMat * aNormal;
	//vec3 norm_camera = mat3(modelViewMat) * aNormal; //viewSpace Normal Blue Hue
	vec3 norm_clip = mat3(uProjectionMat) * norm_camera;
	
	//InClass
	gl_Position = pos_clip;
	vNormal = vec4(norm_clip, 0.);
	
	
  	//vColor = vec4(-pos_camera.xyz, 0.0);
	//vPosition = gl_Position;
	//vColor = vec4(1.0);
	//vColor = aPosition;
	//vColor = pos_world;
	//vColor = pos_camera;
	//vColor = pos_clip;
    //vColor = gl_Position;
	//vColor = texture(tex, texCoord);
	

}
