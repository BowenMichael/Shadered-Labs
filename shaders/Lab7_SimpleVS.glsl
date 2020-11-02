#version 330

//Author: Michael Bowen

//Uniforms
uniform mat4 uViewMat;
uniform mat4 uModelMat;
uniform mat4 uProjectionMat;
uniform mat4 uViewProjMat;
uniform float time;

//Attributes
layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;


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

//Global Structures
struct sLight
{
	vec4 center;
    vec4 color;
    float intensity;
};

void initPointLight(out sLight light, in vec3 center, in vec4 color, in float intensity)
{
  	light.center = vec4(center, 1.0);
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

float powerOfTwo (in float base, in int power){
    for(int i = power - 1; i >= 0; --i){
    	base *= base;
    }
	return base;
}

vec3 positionToViewSpace(vec3 objSpace){
	return mat3(uViewMat * uModelMat) * objSpace;
}

float calcDiffuseI(in sLight light, in vec3 surface, in vec3 surfaceNorm, inout vec3 normLightVec)
{
	vec3 lightVec = light.center.xyz - surface;
   float sqLightVecLen = lengthSq(lightVec);
    normLightVec = lightVec * inversesqrt(sqLightVecLen);
   float diffuseCoefficent = max(0.0, (dot(surfaceNorm, normLightVec)));
   float attenuation = (1.0 - sqLightVecLen/squareValue(light.intensity));
   return diffuseCoefficent * attenuation;

}

float calcSpecularI(in sLight light, in vec3 viewOrigin, in vec3 surface, in vec3 surfaceNorm, inout vec3 normLightVec ){
	vec3 viewVec = viewOrigin - surface;
   vec3 normViewVec = viewVec * inversesqrt(lengthSq(viewVec));
   vec3 halfWayVec = normLightVec + normViewVec;
   vec3 normHalfVec = halfWayVec * inversesqrt(lengthSq(halfWayVec));
   float specCoefficent = max(0.0, dot(surfaceNorm, normHalfVec));
   return powerOfTwo(specCoefficent, 6);
}

vec4 phongReflectance(in sLight light, in vec3 viewOrigin, in vec3 surface, in vec3 surfaceNorm, in vec4 diffuseColor, in vec4 specularColor){
	//Diffuse Intensity
   /*vec3 lightVec = lights[i].center.xyz - pos_camera.xyz;
   float sqLightVecLen = lengthSq(lightVec);
   vec3 normLightVec = lightVec * inversesqrt(sqLightVecLen);
   float diffuseCoefficent = max(0.0, (dot(norm_camera, normLightVec)));
   float attenuation = (1.0 - sqLightVecLen/squareValue(lights[i].intensity));
   float diffuseIntensity = diffuseCoefficent * attenuation;*/
   //Function
   vec3 normLightVec;
   float diffuseIntensity = calcDiffuseI(light, surface, surfaceNorm, normLightVec);
   
   
   
   //Specular Intensity
   /*vec3 viewVec = -pos_camera.xyz;
   vec3 normViewVec = viewVec * inversesqrt(lengthSq(viewVec));
   vec3 halfWayVec = normLightVec + normViewVec;
   vec3 normHalfVec = halfWayVec * inversesqrt(lengthSq(halfWayVec));
   float specCoefficent = max(0.0, dot(norm_camera, normHalfVec));
   float specualarIntensity = powerOfTwo(specCoefficent, 5);*/
   //float specualarIntensity = 0.0; //TO TEST DIFFUSE INTENSITY
   //Function
   float specualarIntensity = calcSpecularI(light, viewOrigin, surface, surfaceNorm, normLightVec);
   
   //Final Color Calculation
   return ((diffuseIntensity * diffuseColor + specualarIntensity * specularColor)    * light.color);  
   		
   	return specualarIntensity * specularColor;//Testing Specular Color
}

void main() {

   //color = vec4(abs(normal), 1.0);
   //gl_Position = matVP * matGeo * vec4(pos, 1);
   
   
   
   //Problem: gl_position is in "clipping space"
   //Problem: aPosition is in "object-space"
   //gl_Position.xyz = pos;
   
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
	mat4 modelViewMat = uViewMat * uModelMat; //Model View Matrix
	vec4 pos_camera = modelViewMat * aPosition; //CameraPosition
	vec4 pos_clip = uProjectionMat * pos_camera; //way 1
	gl_Position = pos_clip;

	//Normal Pipeline
	mat3 normalMat = transpose(inverse(mat3(modelViewMat)));
	vec3 norm_camera = normalMat * aNormal;
	//vec3 norm_camera = mat3(modelViewMat) * aNormal; //viewSpace Normal Blue Hue
	//vec3 norm_clip = mat3(uProjectionMat) * norm_camera;
   
    //Lighting init

   sLight lights[maxLights];
   int i = 0;

   initPointLight(lights[0], vec3(2.0, 0.0,  -2.0), vec4(1.0, 0.0, 0.0, 1.0), 5.0);
   initPointLight(lights[1], vec3(-2.0, 0.0,  -2.0), vec4(0.0, 1.0, 0.0, 1.0), 5.0);
   initPointLight(lights[2], vec3(0.0, -2.0,  -2.0), vec4(0.0, 0.0, 1.0, 1.0), 5.0);
   		
 
   
   //Diffuse Color
   //vec4 diffuseColor = vec4(aNormal * .5 + .5, 1.0); // Object_Space
   //vec4 diffuseColor = vec4(norm_camera * .5 + .5, 1.0); //View_Space
   vec4 diffuseColor = vec4(.5); //Test Gray diffuseColor
   
   //Specular Color
   vec4 specularColor = vec4(1.0);
   

//____________________________________
//PER_VERTEX, VIEW_SPACE
	
   //_______________________________
   //PHONG_REFLECTANCE
   
	//Function
	vec4 phongColorViewSpace;
	for(i = 0; i < maxLights; i++)
	{
		phongColorViewSpace += phongReflectance(lights[i], vec3(0.0), pos_camera.xyz,
												 norm_camera.xyz, diffuseColor, specularColor);
	}
	phongColorViewSpace += globalAmbientIntensity * globalAmbientColor;
//____________________________________
//PER_VERTEX, OBJECT_SPACE
		
   //_______________________________
   //PHONG_REFLECTANCE
   
   	vec4 phongColorObjectSpace;
	//Function
	for(i = 0; i < maxLights; i++){
		phongColorObjectSpace += phongReflectance(lights[i], lights[i].center.xyz, 
													aPosition.xyz, aNormal.xyz, diffuseColor, 
													specularColor);
   }
   	phongColorObjectSpace += globalAmbientIntensity * globalAmbientColor;
   //phongColorObjectSpace /= maxLights;
//___________________________________
//PER_VERTEX varying

   //Set Varying
   
   //Veiw Space
   //vColor = phongColorViewSpace; 
   
   //Object Space
   //vColor = phongColorObjectSpace;     
   
//____________________________________
//PER_FRAGMENT, VIEW_SPACE   
	
	//Varyings
	vNormal = vec4(norm_camera, 0.0);
	vPosition = pos_camera;
	
//____________________________________
//PER_FRAGMENT, VIEW_SPACE 
   
   //Varyings
   //vNormal = vec4(aNormal, 0.0);
   //vPosition = aPosition;

   	vDiffuseColor = diffuseColor;
	vSpecularColor = specularColor;

   
   //DEBUG
   
   //LIGHT
   //vColor = specularColor; //Test specularColor
   
   //vColor = aPosition;
   
   //Per-Fragment Shading. ie. Pass all needed info to fragment shader
   //vNormal = vec4(norm_camera, 0.0);
   
   //Pre-Vertex Calc + output. ie. Do all calculations in the vertex shader and pass the color
   //vColor = vec4(aNormal * 0.5 + 0.5, 1.0);
}
