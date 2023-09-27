const int idxCenter = 0, idxUpperBody = 1, idxNeck = 2, idxHead = 3,           
          idxRightShoulder = 4, idxRightUpperArm = 5, 
          idxRightLowerArm = 6, idxRightHand = 7, idxLeftShoulder = 8,
          idxLeftUpperArm = 9, idxLeftLowerArm = 10, idxLeftHand = 11,
          idxLowerBody = 12, idxRightHip = 13, idxRightUpperLeg = 14,
          idxRightLowerLeg = 15, idxRightFoot = 16, idxLeftHip = 17,
          idxLeftUpperLeg = 18, idxLeftLowerLeg = 19, idxLeftFoot = 20,
          idxModelPos = 21, idxNone = 256;

int parentIdx[22] = int[](idxNone, idxCenter, idxUpperBody,      
                          idxNeck, idxUpperBody, idxRightShoulder,  
                          idxRightUpperArm, idxRightLowerArm, 
                          idxUpperBody, idxLeftShoulder,   
                          idxLeftUpperArm, idxLeftLowerArm,   
                          idxCenter, idxLowerBody, idxRightHip,       
                          idxRightUpperLeg, idxRightLowerLeg, 
                          idxLowerBody, idxLeftHip, idxLeftUpperLeg,  
                          idxLeftLowerLeg, idxNone);

/*idxCenter, idxUpperBody, idxNeck, idxHead
  idxRightShoulder, idxRightUpperArm, idxRigthLowerArm
  idxRithHand, idxLeftShoulder, idxLeftUpperArm
  idxLeftLowerArm, idxLeftHand, idxLowerBody
  idxRightHip, idxRightUpperLeg, idxRightLowerLeg
  idxRightFoot, idxLeftHip, idxLeftUpperLeg
  idxLeftLowerLeg, idxLeftFoot, idxNone*/

#define tailCenter        vec3(0,0,0)

#define tailUpperBody     vec3(0,1.3,0)
#define tailNeck          vec3(0,0.4,0)
#define tailHead          vec3(0,0.6,0)

#define tailRightShoulder vec3(0.7,-0.2,-0.1)
#define tailRightUpperArm vec3(1.2,0,0)
#define tailRigthLowerArm vec3(1.2,0,0)
#define tailRigthHand     vec3(0.2,0,0)

#define tailLeftShoulder  tailRightShoulder*vec3(-1,1,1)
#define tailLeftUpperArm  tailRightUpperArm*vec3(-1,1,1)
#define tailLeftLowerArm  tailRigthLowerArm*vec3(-1,1,1)
#define tailLeftHand      tailRigthHand*vec3(-1,1,1)

#define tailLowerBody     vec3(0,-1.3,0)

#define tailRightHip      vec3(0.3,0,0)
#define tailRightUpperLeg vec3(0,-1.8,-0.1)
#define tailRightLowerLeg vec3(0,-1.5,0)
#define tailRightFoot     vec3(0,0,0.5)

#define tailLeftHip       tailRightHip*vec3(-1,1,1)
#define tailLeftUpperLeg  tailRightUpperLeg*vec3(-1,1,1)
#define tailLeftLowerLeg  tailRightLowerLeg*vec3(-1,1,1)
#define tailLeftFoot      tailRightFoot*vec3(-1,1,1)

#define tailNone          vec3(0,0,0)


vec3 pos[22] = vec3[](tailCenter, tailUpperBody, tailNeck, tailHead, 
                      tailRightShoulder, tailRightUpperArm,
                      tailRigthLowerArm, tailRigthHand,
                      tailLeftShoulder, tailLeftUpperArm,
                      tailLeftLowerArm, tailLeftHand,
                      tailLowerBody, tailRightHip, tailRightUpperLeg,
                      tailRightLowerLeg, tailRightFoot,
                      tailLeftHip, tailLeftUpperLeg, tailLeftLowerLeg,
                      tailLeftFoot, tailNone);


mat4 moveTo(vec3 p) {
  mat4 m = mat4(1);
  
  m[3].xyz = p;
  
  return m;
}

mat4 fromQuat(vec4 q) {
  float xx = q.x * q.x * 2.0,
        xy = q.x * q.y * 2.0, 
        yy = q.y * q.y * 2.0, 
        xz = q.x * q.z * 2.0,
        yz = q.y * q.z * 2.0,
        zz = q.z * q.z * 2.0,
        xw = q.x * q.w * 2.0,
        yw = q.y * q.w * 2.0,
        zw = q.z * q.w * 2.0;
  
  return mat4(1.0 - yy - zz, xy + zw, xz - yw, 0,
              xy - zw, 1.0 - xx - zz, yz + xw, 0,
              xz + yw, yz - xw, 1.0 - xx - yy, 0,
              0, 0, 0, 1);
}

vec4 getData (int id) {
  int row = int(iChannelResolution[0].y);
  
  return texelFetch(iChannel0, ivec2(id % row, id / row), 0);
}

void mainImage( out vec4 fragColor, vec2 fragCoord ) {
	int p = int(iResolution.y) * int(fragCoord.y) + int(fragCoord.x),
        idx = p / 3;
  	
    //if (idx > idxModelPos) discard;
    
    if (idx != idxModelPos) {
        mat4 m = fromQuat(getData(idx));  
		bool cond = true;
        
        while (cond) {
    		idx = parentIdx[idx];
    		
            if (idx != idxNone) m = m*moveTo(-pos[idx]) * fromQuat(getData(idx));
            
    		else cond = false;
  		}
        
    	// center move
   		m = m * moveTo(-getData(idxModelPos).xyz);   
    	fragColor = vec4(transpose(m)[p % 3]);
    
    } else fragColor = getData(idxModelPos);
}
