
   ��GcL�e,�ĹIC�                	                                  `      �                                                                                                                                         ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����    ����                                                        ��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������                 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                              �          �u��69���u��69���r��|"ٲ                                                                                         
                 
   	                 
   	                         ^�                         ����    ������������                                      �   ����    ������������������������                                                screenTexture                       P�                     
                    P�                     aPos aTexCoords        	              P�                          ��������   
          R�                          ��������TexCoords gl_Position 	                                              FragColor                   ����P�                   
                ����P�                   aPos aTexCoords 	                  ����P�                   TexCoords 	                      R�                    FragColor  0  !!NVvp5.0
OPTION NV_internal;
OPTION NV_bindless_texture;
ATTRIB vertex_attrib[] = { vertex.attrib[0..1] };
OUTPUT result_attrib[] = { result.attrib[0..0] };
TEMP T;
MOV.F result.position.xy, vertex.attrib[0];
MOV.F result.position.zw, {0, 1, 0, 0}.xyxy;
MOV.F result.attrib[0].xy, vertex.attrib[1];
END
                ��������������������������������                                                                                                                                        ��������<  !!NVfp5.0
OPTION NV_internal;
OPTION NV_gpu_program_fp64;
OPTION NV_bindless_texture;
PARAM c[1] = { program.local[0] };
ATTRIB fragment_attrib[] = { fragment.attrib[0..0] };
LONG TEMP D0;
TEMP T;
OUTPUT result_color0 = result.color;
PK64.U D0.x, c[0];
TEX.F result_color0, fragment.attrib[0], handle(D0.x), 2D;
END
                                                                                                                                                  �������������������������������                                                                                                                                       ��������                        