#pragma once
#include "vec3.h"
#include "ray.h"

class camera {
private:
	vec3 origin;
	vec3 llc;
	vec3 hor;
	vec3 ver;
	vec3 w, u, v;

public :
	camera() {
		double viewHeight = 2.0;
		double viewWidth = 2.0;
		double length = 1.0;
		origin = vec3(0, 0, 0);
		hor = vec3(viewWidth, 0, 0);
		ver = vec3(0, viewHeight, 0);
		llc = origin - hor / 2 - ver / 2 - vec3(0, 0, length);
	}

	camera(vec3 lookfrom, vec3 lookat, vec3 vup, double fov) {
		double theta = fov * 3.14 / 180.0;
		double h = tan(theta / 2);
		double viewHeight = 2.0 * h;
		double viewWidth = viewHeight;

		w = unitVector(lookfrom - lookat);
		u = unitVector(cross(vup, w));
		v = cross(w, u);

		origin = lookfrom;
		hor = viewWidth * u;
		ver = viewHeight * v;
		llc = origin - hor / 2 - ver / 2 - w;
	}

	ray getRay(double s, double t) const {
		return ray(origin, llc + s * hor + t * ver - origin);
	}
};