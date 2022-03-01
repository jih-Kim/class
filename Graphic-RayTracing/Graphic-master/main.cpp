#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
#include "vec3.h"
#include "ray.h"
#include "hitable.h"
#include "hitlist.h"
#include "sphere.h"
#include "camera.h"
#include "lambertian.h"
#include "metal.h"
#include "material.h"
#include "dielectric.h"
#include <limits>
#include <cstdlib>

using namespace std;

const double infinity = std::numeric_limits<double>::infinity();

double clamp(double x, double min, double max) {
	if (x < min) return min;
	if (x > max) return max;
	return x;
}

void writeColor(FILE* f, color pixel,int samples) {
	double r = pixel.x();
	double g = pixel.y();
	double b = pixel.z();

	double scale = 1.0 / samples;
	r = sqrt(r * scale);
	g = sqrt(g * scale);
	b = sqrt(b * scale);

	int ir = static_cast<int>(256 * clamp(r,0.0,0.999));
	int ig = static_cast<int>(256 * clamp(g, 0.0, 0.999));
	int ib = static_cast<int>(256 * clamp(b, 0.0, 0.999));
	fprintf(f, "%d %d %d\n", ir,ig,ib);
}

color rayColor(const ray& r,const hittable& world,int depth) {
	if (depth <= 0)
		return color(0, 0, 0);
	hitRecord temp;
	if (world.hit(r, 0.001, infinity, temp)) {
		ray scat;
		color atten;
		if (temp.matptr->scatter(r, temp, atten, scat))
			return atten * rayColor(scat, world, depth - 1);
		return color(0, 0, 0);
	}
	vec3 unitDirect = unitVector(r.direct());
	double t = 0.5 * (unitDirect.y() + 1.0);
	return color(1.0 - t + 0.5 * t, 1.0 - t + 0.7 * t, 1.0 - t + 1.0 * t);
	
}

int main() {
	const int imageWidth = 1024;
	const int imageHeight = 1024;
	const int samplesPerPixel = 10;
	const int maxDepth = 10;

	/*---------------Camera Part -------------------*/
	camera cam(vec3(-2,2,1),vec3(0,0,-1),vec3(0,1,0),90);
	//camera cam(vec3(-2, 2, 1), vec3(0, 0, -1), vec3(0, 1, 0), 20);
	/*---------------material-----------------------*/
	lambertian ground = lambertian(color(0.8, 0.8, 0.0));
	lambertian* gl = &ground;
	lambertian center = lambertian(color(0.1,0.2,0.5));
	lambertian* cl = &center;
	dielectric left = dielectric(1.5);
	dielectric* ml = &left;
	metal right = metal(color(0.8, 0.6, 0.2),1.0);
	metal* rl = &right;
	/*--------------Sphere--------------------------*/
	sphere s1 = sphere(vec3(0.0, 0.0, -1.0), 0.5,cl);
	sphere* sc1 = &s1;
	sphere s2 = sphere(vec3(0.0, -100.5, -1.0), 100.0,gl);
	sphere* sc2 = &s2;
	sphere s3 = sphere(vec3(-1.0, 0.0, -1.0), 0.5, ml);
	sphere* sc3 = &s3;
	sphere s5 = sphere(vec3(-1.0, 0.0, -1.0), -0.45, ml);
	sphere* sc5 = &s5;
	sphere s4 = sphere(vec3(1.0, 0.0, -1.0), 0.5, rl);
	sphere* sc4 = &s4;

	hitList hit(sc1);
	hit.add(sc2);
	hit.add(sc3);
	hit.add(sc5);
	hit.add(sc4);
	/*------------Render --------------------------*/
	FILE* f;
	f = fopen("output.ppm", "w");
	fprintf(f, "P3\n%d %d\n255\n", imageWidth, imageHeight);
	for (int j = imageHeight - 1; j >= 0; --j) {
		for (int i = 0; i < imageWidth; ++i) {
			color pixel(0.0, 0.0, 0.0);
			for (int s = 0; s < samplesPerPixel; ++s) {
				double u = (i + randomDouble()) / (imageWidth - 1);
				double v = (j + randomDouble()) / (imageHeight - 1);
				ray r = cam.getRay(u, v);
				pixel = pixel + rayColor(r, hit,maxDepth);
			}
			writeColor(f, pixel,samplesPerPixel);
		}
	}
	fclose(f);
}