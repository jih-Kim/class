#pragma once
#include "material.h"
#include "ray.h"
#include "vec3.h"
#include "hitable.h"

class lambertian : public material {
public:
	color colors;
public:
	lambertian(const color& a) : colors(a) {}
	virtual bool scatter(const ray& rln, const hitRecord& h, color& atten, ray& scat) const override {
		vec3 scatdir = h.normal + randomUnitVector();
		if (scatdir.nearZero())
			scatdir = h.normal;
		scat = ray(h.p, scatdir);
		atten = colors;
		return true;
	}
};