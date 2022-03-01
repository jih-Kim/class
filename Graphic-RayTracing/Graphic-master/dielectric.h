#pragma once
#include "vec3.h"
#include "ray.h"
#include "material.h"
#include "hitable.h"

class dielectric : public material {
public:
	dielectric(double index) : ir(index) {}
	virtual bool scatter(const ray& rln, const hitRecord& h, color& atten, ray& scat) const override {
		atten = color(1.0, 1.0, 1.0);
		double ratio = ir;
		if (h.front)
			ratio = 1.0 / ir;
		vec3 direct = unitVector(rln.direct());
		double cos = fmin(dot(-direct, h.normal), 1.0);
		double sin = sqrt(1.0 - cos * cos);
		bool canRefract = ratio * sin > 1.0;
		vec3 temp;
		if (canRefract)
			temp = reflect(direct, h.normal);
		else
			temp = refract(direct, h.normal, ratio);
		scat = ray(h.p, temp);
		return true;
	}
public:
	double ir;
};