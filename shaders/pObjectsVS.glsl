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
out vec4 vPosition;
out vec4 vDepth;
out vec4 vTexCoord;
out vec4 vLightSpaceCoord;

//Global Vars
//float invMax
float near = 0.1; 
float far  = 100.0; 

//Global Structures
struct sLight
{
   vec4 center;
	vec4 center_world;
	vec4 center_camera;
	vec4 center_clip;
    vec4 color;
    float intensity;
};

void lightInit(out sLight light, in vec3 center, in vec3 color, in float intensity)
{
	light.center_world = vec4(center, 1.0);
	light.center = inverse(uModelMat)*light.center_world;
	light.center_camera = uViewMat * light.center;
	light.center_clip = uProjectionMat * light.center_camera;
	light.color = vec4(color, 1.0);
	light.intensity = 1/intensity; 
}

void main(){

		//Position Pipeline
	mat4 modelViewMat = uViewMat * uModelMat; //Model View Matrix
    vec4 pos_world = uModelMat * aPosition; //World Space
	vec4 pos_camera = modelViewMat * aPosition; //Position in camera Space
	vec4 pos_clip = uProjectionMat * pos_camera; //Position in Clip Space
	gl_Position = pos_clip;
	
	//Normal Pipeline
	mat3 normalMat = transpose(inverse(mat3(modelViewMat)));
	vec3 norm_camera = normalMat * aNormal;
	//vec3 norm_camera = mat3(modelViewMat) * aNormal; //viewSpace Normal Blue Hue
	vec3 norm_clip = mat3(uProjectionMat) * norm_camera;
	
	//Light init
	sLight pointLight;
	//lightInit(pointLight, vec3(sin(time), 1.0, cos(time)), vec3(1.0), 1.0);
	lightInit(pointLight, vec3(0.0, 2.0 + sin(time), 0.0), vec3(1.0), 1.3);
	
	//Create Shadow Map
	//vDepth.w = 1.0/(distance(pos_world.xyz, pointLight.center_world.xyz)* pointLight.intensity);
	//mat4 lightViewMat = gluLookAt(pointLight.x, pointLight.y, pointLight.z, )
	//mat4 lightProjectionMat = gluPerspective(15, 1.0, near, far);
	vDepth.w = distance(pos_clip.xyz, pointLight.center_clip.xyz);
	
	//Shade the scenen
	//Convert view Space coords to light space coords
	vec4 vLightSpaceCoord = pos_camera / pos_camera.w; //in Light Space
	
	//Depth Test
	//Draw The Scene
	//vDepth.xyz = pointLight.center_camera.xyz;
    //vDepth.xyz = pointLight.center_clip.xyz - pos_clip.xyz;
	//vDepth.w = 1.0/(distance(pos_world.xyz, pointLight.center_world.xyz)* pointLight.intensity);
	
	//vTexCoord.xyz = vDepth.xyz *.5 + .5;
	//InClass
	//gl_Position = pos_clip;
	//vPosition = pos_world;
	//vNormal = vec4(norm_clip, 0.);
	
	
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
