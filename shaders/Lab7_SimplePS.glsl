#version 330

//Author: Michael Bowen

#ifdef GL_ES
precision highp float; // If GLSL ES is detected, add required precision setting.
#endif // GL_ES

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

float powerOfTwo (in float base, in int power){
    for(int i = power - 1; i >= 0; --i){
    	base *= base;
    }
	return base;
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
   return (diffuseIntensity * diffuseColor + specualarIntensity * specularColor) * light.color;  
   		
   	return specualarIntensity * specularColor;//Testing Specular Color
}


void main() {
	
	
   	//outColor = vec4(vColor); //Used for PER-VETEX 


   	   		
   	//Lighting init
   	sLight lights[maxLights];
   	int i = 0;
   initPointLight(lights[0], vec3(2.0, 0.0,  -2.0), vec4(1.0), 5.0);
   initPointLight(lights[1], vec3(-2.0, 0.0,  -2.0), vec4(1.0, 0.0, 0.0, 1.0), 5.0);
   initPointLight(lights[2], vec3(0.0, -2.0,  -2.0), vec4(0.5, 0.5, 1.0, 1.0), 5.0);
   
   	//Diffuse Color
   	//vec4 diffuseColor = vec4(vNormal.xyz * .5 + .5, 1.0);
   	vec4 diffuseColor = vec4(0.5);
   
   	//Specular Color
   	vec4 specularColor = vec4(1.0);
   

//____________________________________
//PER_FRAGMENT
	
   //_______________________________
   //PHONG_REFLECTANCE
   
	//Function
	vec4 phongColor;
	for(i = 0; i < maxLights; i++)
	{
		phongColor += phongReflectance(lights[i], lights[i].center.xyz, vPosition.xyz,
												 vNormal.xyz, vDiffuseColor, vSpecularColor);
	}
	phongColor += globalAmbientIntensity * globalAmbientColor;

//____________________________________
//PER_VERTEX, OBJECT_SPACE
		
   //_______________________________
   //PHONG_REFLECTANCE
   
	vec4 phongColorObjectSpace;
	//Function
	for(i = 0; i < maxLights; i++){
		phongColorObjectSpace += phongReflectance(lights[i], lights[i].center.xyz, 
													vPosition.xyz, vNormal.xyz, diffuseColor, 
													specularColor);
   }
   	phongColorObjectSpace += globalAmbientIntensity * globalAmbientColor;
   	
   //ViewSpace Render
   outColor = phongColor; 
   
   //Object Space Render
   //outColor = phongColorObjectSpace; 
   
   	//Debugging
	//PER-FRAGMENT Calculations 
	//vec4 N = normalize(vNormal);
	//outColor = vec4(N.xyz * 0.5 + 0.5, 1.0);   
}