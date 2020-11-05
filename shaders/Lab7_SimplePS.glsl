#version 450 

//Author: Michael Bowen

#ifdef GL_ES
precision highp float; // If GLSL ES is detected, add required precision setting.
#endif // GL_ES

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
//layout (location = 2) in vec4 aTexcoord; //2d uv

//Global Variables
float globalAmbientIntensity = .1;
vec4 globalAmbientColor = vec4(1.0);
const int maxLights = 3;

//Varying
in vec4 vColor;
in vec4 vNormal;
in vec4 vPosition;
in vec4 vDiffuseColor;
in vec4 vSpecularColor;
in vec4 vTexcoord;
in vec4 vCameraPosition;
in mat4 vMat;

//Inputs


//Output
out vec4 outColor;

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

float calcDiffuseI(in sLight light, in vec4 surface, in vec4 surfaceNorm, inout vec4 normLightVec)
{
	vec4 lightVec = light.center - surface;
   float sqLightVecLen = lengthSq(lightVec);
    normLightVec = lightVec * inversesqrt(sqLightVecLen);
   float diffuseCoefficent = max(0.0, (dot(surfaceNorm, normLightVec)));
   float attenuation = (1.0 - sqLightVecLen/squareValue(light.intensity));
   return diffuseCoefficent * attenuation;

}

float calcSpecularI(in sLight light, in vec4 cameraPosition, in vec4 surface, in vec4 surfaceNorm, in vec4 normLightVec ){
   vec4 viewVec = cameraPosition - surface;
   vec4 normViewVec = viewVec * inversesqrt(lengthSq(viewVec));
   vec4 halfWayVec = reflect(-normLightVec, surfaceNorm);//normLightVec + normViewVec; //NOT HALF WAY VECTOR ACTUALLY REFLECTION VECTOR
   vec4 normHalfVec = halfWayVec * inversesqrt(lengthSq(halfWayVec));
   float specCoefficent = max(0.0, dot(surfaceNorm, normHalfVec));
   return powerOfTwo(specCoefficent, 6);
}

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
   	//return specualarIntensity * specularColor;//Testing Specular Color
}


void main() {
	
	vec4 n = normalize(vNormal); //When vNormal is brought into pixel space the size is changed
   	outColor = vColor; //Used for PER-VETEX 
     		
   	//Lighting init
   	sLight lights[maxLights];
   	int i = 0;
   initPointLight(lights[0], vec3(2.0, 0.0,  -2.0), vec4(1.0), 5.0);
   initPointLight(lights[1], vec3(-2.0, 0.0,  -2.0), vec4(1.0, 0.0, 0.0, 1.0), 5.0);
   initPointLight(lights[2], vec3(0.0, -2.0,  -2.0), vec4(0.5, 0.5, 1.0, 1.0), 5.0);
  
      

//____________________________________
//PER_FRAGMENT
	
   //_______________________________
   //PHONG_REFLECTANCE
   
	//Function
	vec4 phongColor;
	for(i = 0; i < maxLights; i++)
	{
		//Creates a temporary sLight to give a point in the relevat space
		sLight tmp;
		vec4 light_space = vMat * lights[i].center; 
		initPointLight(tmp, light_space.xyz, lights[i].color, lights[i].intensity);
		phongColor += phongReflectance(tmp, vPosition, n, vDiffuseColor, vSpecularColor, vCameraPosition);
	}
	phongColor += globalAmbientIntensity * globalAmbientColor;

//____________________________________
//PER_VERTEX, OBJECT_SPACE
		
   //_______________________________
   //PHONG_REFLECTANCE
   
	//vec4 phongColorObjectSpace;
	//Function
	//for(i = 0; i < maxLights; i++){
	//	phongColorObjectSpace += phongReflectance(lights[i], lights[i].center.xyz, 
	//												vPosition.xyz, vNormal.xyz, vDiffuseColor, 
	//												vSpecularColor);
   //}
   	//phongColorObjectSpace += globalAmbientIntensity * globalAmbientColor;
   	
   //PER_FRAGMENT Render
   outColor = phongColor; 
   
   	//Debugging
   	//Texcoord output
   	//outColor = texture(tex, vTexcoord.xy);
   	
	//PER-FRAGMENT Calculations 
	//vec4 N = normalize(vNormal);
	//outColor = vec4(N.xyz * 0.5 + 0.5, 1.0);   
}