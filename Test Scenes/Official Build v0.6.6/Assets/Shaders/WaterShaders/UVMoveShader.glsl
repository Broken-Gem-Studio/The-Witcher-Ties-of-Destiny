#version 440 core 
#define VERTEX_SHADER 
#ifdef VERTEX_SHADER 
layout (location = 0) in vec3 a_Position; 
layout(location = 1) in vec3 a_Normal; 
layout(location = 2) in vec3 a_Color; 
layout (location = 3) in vec2 a_TexCoord;

uniform vec4 u_Color; 
uniform mat4 u_Model; 
uniform mat4 u_View; 
uniform mat4 u_Proj; 
uniform float time;

uniform vec2 UVsDirection = vec2(1.0, 1.0);
uniform float velocity = 1.0;

out vec4 v_Color; 
out vec2 v_TexCoord; 

void main()
{ 
    gl_Position = u_Proj * u_View * u_Model * vec4(a_Position, 1.0f); 
    v_Color = u_Color; 
    v_TexCoord = a_TexCoord + UVsDirection * velocity * time; 
}
#endif //VERTEX_SHADER

#define FRAGMENT_SHADER 
#ifdef FRAGMENT_SHADER 

in vec4 v_Color; 
in vec2 v_TexCoord; 

uniform int u_UseTextures;
uniform sampler2D u_AlbedoTexture; 

out vec4 color;

void main()
{
    //vec2 tCoords = v_TexCoord + UVsDirection * velocity;
    color = v_Color;
    if(u_UseTextures == 1)
        color = texture(u_AlbedoTexture, v_TexCoord);
} 
#endif //FRAGMENT_SHADER
