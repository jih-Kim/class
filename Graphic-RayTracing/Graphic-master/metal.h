#pragma once
#include "ray.h"
#include "vec3.h"
#include "material.h"
#include "hitable.h"

class metal : public material {
public :
	metal(const color& a, double f) : colors(a), fuzy(f<1 ? f:1) {}
	virtual bool scatter(const ray& rln, const hitRecord& rec, color& atten, ray& scat) const override {
		vec3 reflected = reflect(unitVector(rln.direct()), rec.normal);
		scat = ray(rec.p, reflected + fuzy*randomInUnitSphere());
		atten = colors;
		return (dot(scat.direct(), rec.normal) > 0);
	}
public:
	color colors;
	double fuzy;
};