#pragma once
#include "ray.h"
#include "vec3.h"
#include "hitable.h"



class material {
public :
	virtual bool scatter(const ray& rln, const hitRecord& h, color& atten, ray& scat) const = 0;
};