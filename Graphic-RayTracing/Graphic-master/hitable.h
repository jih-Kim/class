#pragma once
#include "ray.h"
#include "vec3.h"

class material;

struct hitRecord {
	vec3 p;
	vec3 normal;
	double t;
	bool front;
	material* matptr;
	
	void setFaceNormal(const ray& r, const vec3& onormal) {
		if (dot(r.direct(),onormal) > 0.0) {
			normal = -onormal;
			front = false;
		}
		else {
			normal = onormal;
			front = true;
		}
	}
};

class hittable {
public:
	virtual bool hit(const ray& r, double tmin, double tmax, hitRecord& h) const = 0;
};