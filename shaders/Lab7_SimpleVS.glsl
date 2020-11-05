#version 450 

//Author: Michael Bowen

//Uniforms
uniform mat4 uViewMat;
uniform mat4 uModelMat;
uniform mat4 uProjectionMat;
uniform mat4 uViewProjMat;
uniform sampler2D tex;
uniform float time;

//Attributes
//Object-Space
layout (location = 0) in vec4 aPosition; //3d position in space
layout (location = 1) in vec3 aNormal; //normal

//Texture-Space
layout (location = 2) in vec4 aTexcoord; //2d uv

//Global Variables
float globalAmbientIntensity = .1;
vec4 globalAmbientColor = vec4(1.0);
const int maxLights = 3;

//varying
out vec4 vColor;
out vec4 vNormal;
out vec4 vPosition;
out vec4 vDiffuseColor;
out vec4 vSpecularColor;
out vec4 vTexcoord;
out vec4 vCameraPosition;
out mat4 vMat;

//Global Structures
struct sLight
{
	vec4 center;
    vec4 color;
    float intensity;
};

void initPointLight(out sLight light, in vec3 center, in vec4 color, in float intensity)
{
  	light.center = uModelMat * vec4(center, 1.0);
    light.color = color;
    light.intensity = intensity;
    
}

//Global Functions
float squareValue(float v){
	return v*v;
}

float lengthSq(vec3 x)
{
    return dot(x, x);
}

float lengthSq(vec4 x)
{
    return dot(x, x);
}

float powerOfTwo (in float base, in int power){
    for(int i = power - 1; i >= 0; --i){
    	base *= base;
    }
	return base;
}

vec3 positionToViewSpace(vec3 objSpace){
	return mat3(uViewMat * uModelMat) * objSpace;
}

float calcDiffuseI(in sLight light, in vec4 surface, in vec4 surfaceNorm, inout vec4 normLightVec)
{
   vec4 lightVec = light.center - surface;
   float sqLightVecLen = lengthSq(lightVec);
   normLightVec = lightVec * inversesqrt(sqLightVecLen);
   float diffuseCoefficent = max(0.0, (dot(surfaceNorm, normLightVec)));
   float attenuation = (1.0 - sqLightVecLen/squareValue(light.intensity));
   return diffuseCoefficent * attenuation;

}

//________________________________________________________
//
	//light: 	input of light to reflect
	//surface: 	input point of vertex/fragment
	//surfaceNorm: 	input vector of normal vector at vetex/fragment
	//normLightVec: normalized vector
float calcSpecularI(in sLight light, in vec4 cameraPosition, in vec4 surface, in vec4 surfaceNorm, in vec4 normLightVec ){
   vec4 viewVec = cameraPosition - surface;
   vec4 normViewVec = viewVec * inversesqrt(lengthSq(viewVec));
   vec4 halfWayVec = reflect(-normLightVec, surfaceNorm);//normLightVec + normViewVec; //NOT HALF WAY VECTOR ACTUALLY REFLECTION VECTOR
   vec4 normHalfVec = halfWayVec * inversesqrt(lengthSq(halfWayVec));
   float specCoefficent = max(0.0, dot(surfaceNorm, normHalfVec));
   return powerOfTwo(specCoefficent, 6);
}

//________________________________________________________
//Caclculating phongReflectance before adding ambient Color
	//light: 	input of light to reflect
	//surface: 	input point of vertex/fragment
	//surfaceNorm: 	input vector of normal vector at vetex/fragment
	//diffuseColor: input color to diffuse at a particular vertex/fragment
	//speculatColor: 	input color for specular highlight at vetex/fragment
	//camera: 	input point of camera in relevant space
	//Final Color: 	output color at a specific vertex/fragment
vec4 phongReflectance(in sLight light, in vec4 surface, in vec4 surfaceNorm, in vec4 diffuseColor, in vec4 specularColor, in vec4 camera){
	//Diffuse Intensity
   //Function
   vec4 normLightVec;
   float diffuseIntensity = calcDiffuseI(light, surface, surfaceNorm, normLightVec);
   
   //Specular Intensity
   //Function
   float specualarIntensity = calcSpecularI(light, camera, surface, surfaceNorm, normLightVec);
   
   //Final Color Calculation
   return ((diffuseIntensity * diffuseColor + specualarIntensity * specularColor)    * light.color);  
   	
   	//DEBUGGING
   	return specualarIntensity * specularColor;//Testing Specular Color
}

void main() {
   //color = vec4(abs(normal), 1.0);
   //gl_Position = matVP * matGeo * vec4(pos, 1);
   
   //Problem: gl_position is in "clipping space"
   //Problem: aPosition is in "object-space"
   //gl_Position = aPosition;
   
   //position in worldspace
   //vec4 pos_world =  uModelMat * aPosition;
   //gl_Position = pos_world;
   
   //position in Camera space
   //vec4 pos_camera = uViewMat * pos_world;
   //gl_Position = pos_camera;
   
   //Model-veiw-projection Matrix
   //position in clip space
   
   //pos_clip = uViewProjMat * pos_world; //way 2
   //pos_clip = uProjectionMat * uViewMat * uModelMat * pos; //way 3
   
  
	//POSITION PIPELINE
	mat4 modelViewMat = uModelMat * uViewMat; //Model View Matrix
	vec4 pos_camera = modelViewMat * aPosition; //CameraPosition
	vec4 pos_clip = uProjectionMat * pos_camera; //way 1
	gl_Position = pos_clip;

	//Normal Pipeline
	mat3 normalMat = transpose(inverse(mat3(modelViewMat)));
	vec3 norm_camera = normalMat * aNormal;
	//vec3 norm_camera = mat3(modelViewMat) * aNormal; //viewSpace Normal Blue Hue
	vec3 norm_clip = mat3(uProjectionMat) * norm_camera;
	
	//TEXTURE PIPELINE
	mat4 atlasMat =   mat4(0.5, 0.0, 0.0, 0.0,
						   0.0, 0.5, 0.0, 0.0,
						   0.0, 0.0, 1.0, 0.0,
						   0.25, 0.25, 0.0, 1.0);
	vec4 uv_atlas = atlasMat * aTexcoord;
	//vTexcoord = uv_atlas;
	vTexcoord = aTexcoord;
	
   //Camera Pipline
   mat4 modelMatInv = inverse(uModelMat);
   vec4 camera_camera = vec4(0.0);
   vec4 camera_object = modelMatInv * camera_camera;
   
    //Lighting init
   sLight lights[maxLights];
   int i = 0;
   initPointLight(lights[0], vec3(2.0, 0.0,  -2.0), vec4(1.0), 5.0);
   initPointLight(lights[1], vec3(-2.0, 0.0,  -2.0), vec4(1.0, 0.0, 0.0, 1.0), 5.0);
   initPointLight(lights[2], vec3(0.0, -2.0,  -2.0), vec4(0.5, 0.5, 1.0, 1.0), 5.0);
   		
   //Diffuse Color
   //vec4 diffuseColor = vec4(aNormal * .5 + .5, 1.0); // Object_Space
   //vec4 diffuseColor = vec4(norm_camera * .5 + .5, 1.0); //View_Space
   vec4 diffuseColor = vec4(0.5);
   //vec4 diffuseColor = texture(tex, vTexcoord.xy); //Test Gray diffuseColor
   
   //Specular Color
   vec4 specularColor = vec4(1.0);
   
   globalAmbientColor = texture(tex, aTexcoord.xy);
   

   

//____________________________________
//PER_VERTEX, VIEW_SPACE
	
   //_______________________________
   //PHONG_REFLECTANCE
   
	//Function
	vec4 phongColorViewSpace = vec4(0.0); //Explicit os that the computer puts some rather than nothing
	for(i = 0; i < maxLights; i++)
	{
		sLight tmp;
		//convert light position to view space from world space
		vec4 light_view_position = uViewMat * lights[i].center;
		initPointLight(tmp, light_view_position.xyz, lights[i].color, lights[i].intensity); //created temp light for calc
		phongColorViewSpace += phongReflectance(tmp, pos_camera,
												 vec4(norm_camera, 0.0), diffuseColor, specularColor, camera_camera);
	}
	phongColorViewSpace += globalAmbientIntensity * globalAmbientColor;
//____________________________________
//PER_VERTEX, OBJECT_SPACE
		
   //_______________________________
   //PHONG_REFLECTANCE
   
   	vec4 phongColorObjectSpace = vec4(0.0);
   	
	//Function
	for(i = 0; i < maxLights; i++){
		//convert light position to object space from world space
		sLight tmp;
		vec4 light_object_position = modelMatInv * lights[i].center;//world space to object space
		initPointLight(tmp, light_object_position.xyz, lights[i].color, lights[i].intensity); //created temp light for calc
		
		//Function
		phongColorObjectSpace += phongReflectance(tmp, aPosition, vec4(aNormal, 0.0), diffuseColor, specularColor, camera_object);
   }
   	phongColorObjectSpace += globalAmbientIntensity * globalAmbientColor;

//___________________________________
//PER_VERTEX varying

   //Set Varying
   
   //Veiw Space
   vColor = phongColorViewSpace; 
   
   //Object Space
   vColor = phongColorObjectSpace;     
   
//____________________________________
//PER_FRAGMENT, VIEW_SPACE   
	
	//Varyings
	vNormal = vec4(norm_camera, 0.0);
	vPosition = pos_camera;
	vCameraPosition = camera_camera;
	vMat = uViewMat;
	
//____________________________________
//PER_FRAGMENT, Object_SPACE 
   
   //Varyings
   vNormal = vec4(aNormal, 0.0);
   vPosition = aPosition;
   vCameraPosition = camera_object;
   vMat = modelMatInv;

//___________________________________
//COMMON VARYINGS
   	vDiffuseColor = diffuseColor;
	vSpecularColor = specularColor;
 
//__________________________________  
//DEBUG
   //Testing Texcoord
   //vTexcoord = aTexcoord;
   //gl_Position = uProjectionMat * modelViewMat * aTexcoord;
   
   //vColor = vec4()
   
   //LIGHT
   //vColor = specularColor; //Test specularColor
   
   //vColor = aPosition;
   //vColor = vec4(aNormal, 1.0);
   
   //Per-Fragment Shading. ie. Pass all needed info to fragment shader
   //vNormal = vec4(norm_camera, 0.0);
   
   //Pre-Vertex Calc + output. ie. Do all calculations in the vertex shader and pass the color
   //vColor = vec4(aNormal * 0.5 + 0.5, 1.0);
}
