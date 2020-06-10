#version 440 core
		#define VERTEX_SHADER
		#ifdef VERTEX_SHADER

		layout (location = 0) in vec3 a_Position;
		layout(location = 1) in vec3 a_Normal;
		layout(location = 2) in vec3 a_Color;
		layout (location = 3) in vec2 a_TexCoord;

		uniform vec4 u_Color = vec4(1.0);
		uniform mat4 u_Model;
		uniform mat4 u_View;
		uniform mat4 u_Proj;

		out vec4 v_Color;
		out vec2 v_TexCoord;

		void main()
		{
			gl_Position = u_Proj * u_View * u_Model * vec4(a_Position, 1.0f);
			v_Color = u_Color;
			v_TexCoord = a_TexCoord;
		}
		#endif //VERTEX_SHADER
#define FRAGMENT_SHADER
		#ifdef FRAGMENT_SHADER

		uniform int u_UseTextures;
		uniform sampler2D u_AlbedoTexture;

		in vec4 v_Color;
		in vec2 v_TexCoord;
		out vec4 color;

		void main()
		{
			color = v_Color;
			if(u_UseTextures == -1)
				color = texture(u_AlbedoTexture, v_TexCoord) * v_Color;
		}
		#endif //FRAGMENT_SHADER