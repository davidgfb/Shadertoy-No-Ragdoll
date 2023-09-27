
#define idxCenter         0
#define idxUpperBody      1
#define idxNeck           2
#define idxHead           3
#define idxRightShoulder  4
#define idxRightUpperArm  5
#define idxRightLowerArm  6
#define idxRightHand      7
#define idxLeftShoulder   8
#define idxLeftUpperArm   9
#define idxLeftLowerArm  10
#define idxLeftHand      11
#define idxLowerBody     12
#define idxRightHip      13
#define idxRightUpperLeg 14
#define idxRightLowerLeg 15
#define idxRightFoot     16
#define idxLeftHip       17
#define idxLeftUpperLeg  18
#define idxLeftLowerLeg  19
#define idxLeftFoot      20
#define idxModelPos      21
#define idxNone         256

#define modelPos vec3(0,5,0)

vec4 quat(vec3 p, float a) //quaternion
{
    p=normalize(p);
	return vec4(p*sin(a/2.0), cos(a/2.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  	int id = int(fragCoord.x) + int(iResolution.y) * int(fragCoord.y);
  	if (id > idxModelPos) discard;  
	vec4 Q = vec4(0,0,0,1);
    
  	switch(id)
  	{
		case idxCenter:
    		Q = quat(vec3(1),(iTime)*0.3);
      		break;
 		case idxUpperBody:
    		Q = quat(vec3(1,0,0),sin(iTime)*0.2+0.15);
      		break;
 		
        case idxRightUpperArm:
        	Q = quat(vec3(0,sin(iTime*0.3),cos(iTime*0.3)),sin(iTime*3.)*0.8);
      		break;
      	case idxRightLowerArm:
    		Q = quat(vec3(0,1,0),abs(sin(iTime)));
      		break;
      	
        case idxLeftUpperArm:
       		//Q = quat(vec3(0,0,1),radians(-90.));
       		Q = quat(vec3(0,sin(iTime*0.3),cos(iTime*0.3)),sin(iTime*3.)*0.8);
        	break;
      	case idxLeftLowerArm:
    		Q = quat(vec3(0,1,0),-abs(sin(iTime)));
      		break;
      	
        case idxRightUpperLeg:
        	Q = quat(vec3(1,0,-0.3),abs(sin(iTime+1.0)));
        	break;
      	case idxRightLowerLeg:
       		Q = quat(vec3(1,0,0),-abs(sin(iTime+1.0)));
        	break;
      	case idxRightFoot:
       		Q = quat(vec3(1,0,0),-0.5);
        	break;
      	case idxLeftHip:
        	break;
      	case idxLeftUpperLeg:
        	Q = quat(vec3(1,0,0.3),abs(sin(iTime)));
        	break;
      	case idxLeftLowerLeg:
       		Q = quat(vec3(1,0,0),-abs(sin(iTime)));
        	break;
      	case idxLeftFoot:
       		Q = quat(vec3(1,0,0),-0.5);
        	break;
      	case idxModelPos:
          	Q.xyz = modelPos;
       		break;
	}
	//Q = vec4(0,0,0,1);
    fragColor = vec4(Q);  
}
