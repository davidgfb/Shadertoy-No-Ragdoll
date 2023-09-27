const int idxCenter = 0, idxUpperBody = 1, idxNeck = 2, idxHead = 3,           
          idxRightShoulder = 4, idxRightUpperArm = 5, 
          idxRightLowerArm = 6, idxRightHand = 7, idxLeftShoulder = 8,
          idxLeftUpperArm = 9, idxLeftLowerArm = 10, idxLeftHand = 11,
          idxLowerBody = 12, idxRightHip = 13, idxRightUpperLeg = 14,
          idxRightLowerLeg = 15, idxRightFoot = 16, idxLeftHip = 17,
          idxLeftUpperLeg = 18, idxLeftLowerLeg = 19, idxLeftFoot = 20,
          idxModelPos = 21, idxNone = 256;

const vec3 x = vec3(1, 0, 0), y = vec3(0, 1, 0), modelPos = 5.0 * y; 

vec4 quat(vec3 p, float a) { //quaternion
    p = normalize(p);
	
    return vec4(p * sin(a / 2.0), cos(a / 2.0));
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {
  	int id = int(iResolution.y) * int(fragCoord.y) + int(fragCoord.x);
  	
    //if (id > idxModelPos) discard;  
	
    float t = iTime * 0.3, a = abs(sin(iTime + 1.0)), s = sin(iTime), 
          a1 = abs(s); 
    
    vec4 Q = vec4(0, 0, 0, 1), 
         Q1 = quat(vec3(0, sin(t), cos(t)), sin(iTime * 3.0) * 0.8),
         Q2 = quat(x, -0.5);
    
    switch (id) {
		case idxCenter:
    		Q = quat(vec3(1), t);
      		
            break;
 		
        case idxUpperBody:
    		Q = quat(x, s / 5.0 + 0.15);
      		
            break;
 		
        case idxLeftUpperArm:
        case idxRightUpperArm:
       		//Q = quat(vec3(0,0,1), radians(-90.0));            
       		Q = Q1;
        	
            break;
        
        case idxLeftLowerArm:
    		Q = quat(y, -a1);
      		
            break;
            
        case idxRightLowerArm:
    		Q = quat(y, a1);
      		
            break;
      	
        case idxLeftUpperLeg:
        	Q = quat(vec3(1, 0, 0.3), a1);
        	
            break;
            
        case idxRightUpperLeg:
        	Q = quat(vec3(1, 0, -0.3), a);
        	
            break;
      	
        case idxLeftLowerLeg:
       		Q = quat(x, -a1);
        	
            break;
            
        case idxRightLowerLeg:
       		Q = quat(x, -a);
        	
            break;
      	
        case idxLeftFoot:
        case idxRightFoot:
       		Q = Q2;
        	
            break;
        
        case idxModelPos:
          	Q.xyz = modelPos;
       		
            break;
	}
	
    //Q = vec4(0,0,0,1);
    fragColor = Q;  
}
