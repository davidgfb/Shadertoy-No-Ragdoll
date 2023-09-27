const int L = 0, R = 1, idxCenter = 0, idxUpperBody = 1, idxNeck = 2, 
          idxHead = 3,           
          idxRightShoulder = 4, idxRightUpperArm = 5, 
          idxRightLowerArm = 6, idxRightHand = 7, idxLeftShoulder = 8,
          idxLeftUpperArm = 9, idxLeftLowerArm = 10, idxLeftHand = 11,
          idxLowerBody = 12, idxRightHip = 13, idxRightUpperLeg = 14,
          idxRightLowerLeg = 15, idxRightFoot = 16, idxLeftHip = 17,
          idxLeftUpperLeg = 18, idxLeftLowerLeg = 19, idxLeftFoot = 20,
          idxModelPos = 21, idxNone = 256;

const vec3 x = vec3(1, 0, 0), y = vec3(0, 1, 0), z = vec3(0, 0, 1), 
           tailCenter = vec3(0), tailUpperBody = 1.3 * y,
           tailNeck = 0.4 * y, tailHead = 0.6 * y,
           tailRightShoulder = vec3(0.7, -0.2, -0.1),
           tailRightUpperArm = 1.2 * x,
           tailRigthLowerArm = 1.2 * x,
           tailRigthHand = x / 5.0,
           
           a = vec3(-1, 1, 1),
           tailLeftShoulder = tailRightShoulder * a,
           tailLeftUpperArm = tailRightUpperArm * a,
           tailLeftLowerArm = tailRigthLowerArm * a,
           tailLeftHand = tailRigthHand * a,

           tailLowerBody = -1.3 * y,
           tailRightHip = 0.3 * x,
           tailRightUpperLeg = vec3(0, -1.8, -0.1),
           tailRightLowerLeg = -1.5 * y, 
           tailRightFoot = z / 2.0,

           tailLeftHip = tailRightHip * a,
           tailLeftUpperLeg = tailRightUpperLeg * a,
           tailLeftLowerLeg = tailRightLowerLeg * a,
           tailLeftFoot = tailRightFoot * a,

           tailNone = vec3(0);

vec3 pos[22] = vec3[](tailCenter, tailUpperBody, tailNeck, tailHead, 
                      tailRightShoulder, tailRightUpperArm,
                      tailRigthLowerArm, tailRigthHand,
                      tailLeftShoulder, tailLeftUpperArm,
                      tailLeftLowerArm, tailLeftHand,
                      tailLowerBody, tailRightHip, tailRightUpperLeg,
                      tailRightLowerLeg, tailRightFoot,
                      tailLeftHip, tailLeftUpperLeg, tailLeftLowerLeg,
                      tailLeftFoot, tailNone);

#define ROW int(iChannelResolution[0].y)

mat4x3 bornMat(int idx) {
    idx *= 3;
    mat3x4 m = mat3x4(0);
    
    for(int i = 0; i < 3; i++, idx++) m[i] = texelFetch(iChannel0, 
        ivec2(idx % ROW, idx / ROW), 0); //vec2 con signo +/-
        
    return transpose(m);
}

vec3 modelPos() {
    int idx = idxModelPos * 3;
    
    return texelFetch(iChannel0, ivec2(idx % ROW, idx / ROW), 0).xyz;
}

vec3 transform(vec3 p, int idx) {
    return (bornMat(idx) * vec4(p, 1)).xyz;
}

mat3 lookat(vec3 rd) {
	vec3 w = normalize(rd), u = normalize(vec3(-w.z, 0, w.x));
    
    return mat3(u, cross(u, w), w);
}

mat2 rotate(float a) {
    float s = sin(a), c = cos(a);
    
	return mat2(c, s, -s, c);	
}

float smin(float a, float b, float k) {
    float h = clamp(((b - a) / k + 1.0) / 2.0, 0.0, 1.0);
    
    return h * (k * h + a - b - k) + b;
}

float smax(float a, float b, float k) {
    return smin(a, b, -k);
}

vec2 deCapsule( vec3 p, vec3 a, vec3 b) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    
    return vec2(length(pa - ba * h), h);
}

float deRoundBox(vec3 p, vec3 b, float r) {
  return length(max(abs(p) - b, 0.0)) - r;
}

float deUpperBody(vec3 p) {
    int idx = idxUpperBody;
    p = transform(p, idx);
    vec3 q = p;
    p -= pos[idx] * 0.6;
    float de = 1.0;
	q.x = abs(q.x) - 0.1;
    vec2 c = vec2(p.y, smax(length(p.xz * vec2(1, 1.3)), 
        -(length(q.xz * vec2(1.5, 1) - vec2(0, -0.5)) - 0.5), 0.25)); 
   	c.x = (c.x > 0.0) ? pow(c.x, 1.5) : c.x / 1.8;
    de = min(de, length(c) - 0.6);   
    p.x = p.x - 2.0 * smin(0.0, p.x, 0.1) - 0.28;  
    p.z -= 0.4;
    de = smin(de, length(p) - 0.2, 0.3);
    
    return de;
}

float deLowerBody(vec3 p) {
    int idx = idxLowerBody;
    p = transform(p, idx);
    float de = 1.0;
    vec2 s = deCapsule(p, vec3(0), pos[idx]);
    de = min(de, s.x - 0.3);
    p -= pos[idx] * 0.85;
	vec2 c = vec2(-p.y, length(p.xz * vec2(1, 1.8))); 
    de = smin(de, length(c) - 0.5, 0.6);
    
    //de = smax(de,-(length(p*vec3(1,0.7,0.7)-vec3(0,0.3,0.28))-0.06),0.03);
    p.x = p.x - 2.0 * smin(0.0, p.x, 0.02) - 0.28;  
    p.z -= -0.25;
    p.y -= -0.15;
    de = smin(de, length(p) - 0.2, 0.3);
    
    return de;
}

float deNeck(vec3 p) {
    int idx = idxNeck;
    p = transform(p, idx);
    vec2 de = deCapsule(p, vec3(0), pos[idx]);
    
    return de.x - 0.15;
}

float deHead(vec3 p) {
    int idx = idxHead;
    p = transform(p, idx);
    
    return deRoundBox(p - pos[idx] / 2.0, vec3(0.3), 0.1);
}

float deUpperArm(vec3 p, int LR) {
    int idx = (LR == R) ? idxRightUpperArm : idxLeftUpperArm;
    p = transform(p, idx);
    vec2 de = deCapsule(p, vec3(0), pos[idx]);
    
    return de.x - smoothstep(1.5, 0.7, de.y) / 5.0;
}

float deLowerArm(vec3 p, int LR) {
    int idx = (LR == R) ? idxRightLowerArm : idxLeftLowerArm;
    p = transform(p, idx);
    vec2 de = deCapsule(p, vec3(0), pos[idx]);
    
    return de.x - smoothstep(1.5, 0.4, de.y) * 0.18;
}

float deHand(vec3 p, int LR) {
    int idx = (LR == R) ? idxRightHand : idxLeftHand;
    p = transform(p, idx);
    float de = 1.0;
    p -= pos[idx] / 2.0;
    vec2 c = vec2(p.x, length(p.yz * vec2(1, 1.3))); 
   	c.x = (c.x > 0.0) ? pow(c.x, 1.1) : c.x / 2.0;
    de = min(de, length(c) - 0.15); 
    //vec2 s = deCapsule(p, vec3(0,0.1,0), vec3(pos[idx].x*0.25,0.15,0.1));
    //de = smin(de, s.x - 0.03,0.05);
    
    return de;
}

float deUpperLeg(vec3 p, int LR) {
    int idx = (LR==R)?idxRightUpperLeg:idxLeftUpperLeg;
    p = transform(p, idx);
    vec2 de = deCapsule(p, vec3(0), pos[idx]);
    return de.x - smoothstep(1.6,0.6,de.y)*0.3;
}

float deLowerLeg(vec3 p, int LR)
{
    int idx = (LR==R)?idxRightLowerLeg:idxLeftLowerLeg;
    p = transform(p, idx);
    vec2 de = deCapsule(p, vec3(0), pos[idx]);
    return de.x - smoothstep(1.6,0.6,de.y)*0.2;
}
float deFoot(vec3 p, int LR)
{
    int idx = (LR==R)?idxRightFoot:idxLeftFoot;
    p = transform(p, idx);
    p-=pos[idx]*0.45;
    vec2 c = vec2(p.z, length(p.xy*vec2(1,1.3))); 
   	c.x = (c.x>0.)?pow(c.x,1.5):c.x/2.0;
    return length(c)-0.2;
}

float map(vec3 p)
{
    float len=length(p-modelPos()), r = 5.;
    if (len>r) return len -r+ 0.001;   
    
    float de = 1.0;
    de = min(de, deUpperBody(p));
    de = smin(de, deNeck(p),0.1);
    de = smin(de, deHead(p),0.1);
    de = smin(de, deLowerBody(p),0.3);
    de = smin(de, deUpperArm(p, L),0.4);
    de = smin(de, deUpperArm(p, R),0.4);
    de = smin(de, deLowerArm(p, L),0.03);
    de = smin(de, deLowerArm(p, R),0.03);
    de = smin(de, deHand(p, L),0.1);
    de = smin(de, deHand(p, R),0.1);    
    de = smin(de, deUpperLeg(p, L),0.1);
    de = smin(de, deUpperLeg(p, R),0.1);
    de = smin(de, deLowerLeg(p, L),0.05);
    de = smin(de, deLowerLeg(p, R),0.05);
    de = smin(de, deFoot(p, L),0.1);
    de = smin(de, deFoot(p, R),0.1);
    return de;
}

vec3 calcNormal(vec3 pos){
  vec2 e = vec2(1, -1) * 0.002;
  return normalize(
    e.xyy*map(pos+e.xyy)+e.yyx*map(pos+e.yyx)+ 
    e.yxy*map(pos+e.yxy)+e.xxx*map(pos+e.xxx)
  );
}
    
vec3 doColor(vec3 p)
{
	const float precis = 0.001;
 	if(deLowerLeg(p,L)<precis) return vec3(1,0.2,0);
 	return vec3(0.5,0.9,0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (fragCoord.xy * 2.0 - iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0,5,8);
    vec3 rd = normalize(vec3(p, 2));
    vec3 ta = vec3(0,5,0);
    
    // camera sequence 
	float phaseTime, tmpTime = mod(iTime,30.0);
  	int phaseNumber; 	
  	#define PH(n,v) if (tmpTime >= 0.0) {phaseTime = tmpTime; phaseNumber = n;}  tmpTime -= float(v);  
    
    PH(0, 7)
    PH(1, 5)
    PH(2, 5)
    PH(3, 3)
        
    switch (phaseNumber) {
    	case 0:
        	ro.xz *= rotate(iTime*0.1);
   			break;
    	case 1:
        	ta.x +=3.;
   			ro.z += -phaseTime * 4.0;
    		break;
    	case 2:
   			ta.y =6.0-phaseTime *0.5;
        	ro.z -=2.0;
    		 break;
    	case 3: 
   			ta.x =5.0-phaseTime *1.5;
        	ro.z -=-1.0+phaseTime * 0.2;
     		ro.xz *= rotate(0.5);
  		 	break;
    }    

	rd = lookat(ta-ro) * rd;
    
	vec3 col =vec3(0.05,0.1,0.3)- vec3(p.y*p.y)*0.5;
    col = mix(col, texture(iChannel3, p * 0.1 - iTime * 0.005).xyz, 0.3);
    
    
	const float maxd = 100.0, precis = 0.001;
	float t = 0.0, d;
 	for(int i = 0; i < 128; i++)
  	{
		vec3 p=ro + rd * t;
    	t += d =map(p);
    	if(d < precis || t > maxd) break;
  	}
  	if(d < precis)
  	{
	  	vec3 p = ro + rd * t;
	 	vec3 nor = calcNormal(p);
    	vec3 li = normalize(vec3(1));
        vec3 bg = col;
        col = doColor(p);
        float dif = clamp(dot(nor, li), 0.3, 1.0);
        float amb = max(0.5 + 0.5 * nor.y, 0.0);
        float spc = pow(clamp(dot(reflect(normalize(p - ro), nor), li), 0.0, 1.0), 30.0);
        col *= dif * amb ;
        col += spc;
        col = clamp(col,0.0,1.0);
        col = pow(col, vec3(0.7));        
    }
    fragColor = vec4(col, 1.0);;
}
