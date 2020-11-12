#version 450

//Uniforms

//Attributes

//Varyings
in vec4 vNormal;

//Color Target
layout (location = 0) out vec4 rtFragColor;

void main(){
	rtFragColor = vNormal;
}
