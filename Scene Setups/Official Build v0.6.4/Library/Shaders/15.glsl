
   ��uK�#Y'��X��                	                                    `      �(                                                                            B      7                                                       ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����                                                        ��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������                 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      �(          �u��69���u��69���� [4�iE                                                                                         
                 
   	                                             `�                         ����    ������������                                      �   ����   ������������������������                                             Q�                          ����    ������������                                     �   ����   ������������������������                               
                                       ����    ������������                                     �   ����    ������������������������                                                                      ����    ������������                                     �   ����   ������������������������                                  ,          \�                          ����    ������������                                     �      ����������������������������                                  4          \�                          ����    ������������                                     �      ����������������������������                                  ;          \�                          ����    ������������'                                     �       ����������������������������                                                                                     �?  �?  �?  �?  �?                                                                                                                                                                                                skybox u_Color u_Exposure u_GammaCorrection u_Model u_Proj u_View 
                      Q�                     a_Position        	              Q�                          ��������   
          R�                          ��������TexCoords gl_Position                                               color 
                  ����Q�                   a_Position 	                  ����Q�                   TexCoords                       R�                    color  �  !!NVvp5.0
OPTION NV_internal;
OPTION NV_bindless_texture;
PARAM c[12] = { program.local[0..11] };
ATTRIB vertex_attrib[] = { vertex.attrib[0..0] };
OUTPUT result_attrib[] = { result.attrib[0..0] };
TEMP R0, R1, R2, R3;
TEMP T;
MUL.F32 R0, c[5], c[0].y;
MAD.F32 R0, c[4], c[0].x, R0;
MAD.F32 R1, c[6], c[0].z, R0;
MUL.F32 R0, c[5], c[1].y;
MUL.F32 R2, vertex.attrib[0].y, c[9];
MAD.F32 R0, c[4], c[1].x, R0;
MAD.F32 R2, vertex.attrib[0].x, c[8], R2;
MAD.F32 R2, vertex.attrib[0].z, c[10], R2;
MAD.F32 R0, c[6], c[1].z, R0;
ADD.F32 R3, R2, c[11];
MAD.F32 R0, c[7], c[1].w, R0;
MUL.F32 R0, R3.y, R0;
MAD.F32 R1, c[7], c[0].w, R1;
MAD.F32 R2, R3.x, R1, R0;
MUL.F32 R0, c[5], c[2].y;
MUL.F32 R1, c[3].y, c[5];
MAD.F32 R0, c[4], c[2].x, R0;
MAD.F32 R1, c[3].x, c[4], R1;
MAD.F32 R0, c[6], c[2].z, R0;
MAD.F32 R1, c[3].z, c[6], R1;
MAD.F32 R0, c[7], c[2].w, R0;
MAD.F32 R0, R3.z, R0, R2;
MAD.F32 R1, c[3].w, c[7], R1;
MAD.F32 result.position, R3.w, R1, R0;
MUL.F32 result.attrib[0].xyz, vertex.attrib[0], {1, -1, 0, 0}.xyxw;
END
                                                                                                                                                                                                                                                                               ��������������������������������                                                                                                                                        ��������S  !!NVfp5.0
OPTION NV_internal;
OPTION NV_gpu_program_fp64;
OPTION NV_bindless_texture;
PARAM c[4] = { program.local[0..3] };
ATTRIB fragment_attrib[] = { fragment.attrib[0..0] };
TEMP R0, R1;
LONG TEMP D0;
TEMP T;
OUTPUT result_color0 = result.color;
PK64.U D0.x, c[3];
TEX.F R0, fragment.attrib[0], handle(D0.x), CUBE;
MOV.F R1.w, {1, 0, 0, 0}.x;
MOV.F R1.xyz, c[1];
MUL.F32 R1, R0, R1;
MUL.F32 R1, R1, c[0].x;
RCP.F32 R0.x, c[2].x;
POW.F32 result_color0.x, R1.x, R0.x;
POW.F32 result_color0.y, R1.y, R0.x;
POW.F32 result_color0.z, R1.z, R0.x;
POW.F32 result_color0.w, R1.w, {1, 0, 0, 0}.x;
END
     �?              �?  �?  �?      �?                                                                                                           �������������������������������                                                                                                                                      ��������                        