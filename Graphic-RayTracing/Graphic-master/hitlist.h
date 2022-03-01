#pragma once
#include "hitable.h"
#include <list>
using namespace std;

class hitList : public hittable {
public :
	hitList() {}
	hitList(hittable* object) { add(object); }
	void clear() { objects.clear(); }
	void add(hittable* object) { objects.push_back(object); }

	virtual bool hit(const ray& r, double tmin, double tmax, hitRecord& rec) const override {
		hitRecord temp;
		bool hit = false;
		double closest = tmax;
		for (const auto& object : objects) {
			if (object->hit(r, tmin, closest, temp)) {
				hit = true;
				closest = temp.t;
				rec = temp;
			}
		}
		return hit;
	}


public :
	list<hittable*> objects;
};