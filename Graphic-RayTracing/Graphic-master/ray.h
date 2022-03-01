#pragma once
#include "vec3.h"

class ray {
public :
	ray() {}
	ray(const vec3& origin, const vec3& direct): orig(origin),dir(direct) {}
	vec3 origin() const { return orig; }
	vec3 direct() const { return dir; }

	vec3 at(double t) const {
		return vec3(orig.x() + dir.x()*t, orig.y() + dir.y() * t, orig.z() + dir.z() * t);
	}

public :
	vec3 orig;
	vec3 dir;
};