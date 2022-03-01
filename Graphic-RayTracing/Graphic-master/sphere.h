#include "hitable.h"
#include "ray.h"
#include "vec3.h"

class sphere : public hittable {
public:
	vec3 center;
	double radius;
	material* matptr;

public:
	sphere() {}
	sphere(vec3 cen, float r,material* m) : center(cen), radius(r),matptr(m) {};
	virtual bool hit(const ray& r, double tmin, double tmax, hitRecord& h) const override {
		vec3 oc = r.origin() - center;
		double a = r.direct().lengthSquare();
		double half_b = dot(oc,r.direct());
		double c = oc.lengthSquare() - radius * radius;

		double dis = half_b * half_b - a * c;
		if (dis < 0) return false;
		double sqrtd = sqrt(dis);

		double root = (-half_b - sqrtd) / a;
		if (root < tmin || tmax < root) {
			root = (-half_b + sqrtd) / a;
			if (root < tmin || tmax < root)
				return false;
		}
		h.t = root;
		h.p = r.at(h.t);
		vec3 onormal = (h.p - center) / radius;
		h.setFaceNormal(r, onormal);
		h.matptr = matptr;
		return true;
	}
};