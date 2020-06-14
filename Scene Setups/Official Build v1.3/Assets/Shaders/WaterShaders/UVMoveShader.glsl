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
out vec2 v_TexCoord; //sd

void main()
{
    vec2 waterDir = vec2(0.1, -2.0);
    //waterDir = UVsDirection;

    float vel = 0.1;
   vel = velocity;

    gl_Position = u_Proj * u_View * u_Model * vec4(a_Position, 1.0f); 
    v_Color = u_Color; 
    v_TexCoord = a_TexCoord + waterDir * vel * time; 
}
#endif //VERTEX_SHADER

#define FRAGMENT_SHADER 
#ifdef FRAGMENT_SHADER 

in vec4 v_Color; 
in vec2 v_TexCoord; 

uniform int u_UseTextures;
uniform sampler2D u_AlbedoTexture;

uniform float u_GammaCorrection = 1.8;

out vec4 color;

void main()
{
    //vec2 tCoords = v_TexCoord + UVsDirection * velocity;
    color = v_Color;
    if(u_UseTextures == 1)
        color *= texture(u_AlbedoTexture, v_TexCoord);

    color = pow(color, vec4(vec3(1.0/u_GammaCorrection), 1.0));
    color.a = v_Color.a;
} 
#endif //FRAGMENT_SHADER
