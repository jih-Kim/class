#pragma once
#include <cmath>
#include <iostream>

using std::sqrt;


double randomDouble() {
	return rand() / (RAND_MAX + 1.0);
}

double randomDouble(double min, double max) {
	return min + (max - min) * randomDouble();
}

class vec3 {
public:
	vec3() : v{0,0,0} {}
	vec3(double v0, double v1, double v2) : v{ v0,v1,v2 } {}
	double x() const { return v[0]; }
	double y() const { return v[1]; }
	double z() const { return v[2]; }

	vec3 operator -() const { return vec3(-v[0], -v[1], -v[2]); }
	double operator[](int i) const { return v[i]; }
	double& operator[](int i) { return v[i]; }
	vec3& operator+=(const vec3& v1) {
		v[0] = v[0] + v1.v[0];
		v[1] = v[1] + v1.v[1];
		v[2] = v[2] + v1.v[2];
		return *this;
	}

	vec3& operator*=(const float t) {
		v[0] = v[0] * t;
		v[1] = v[1] * t;
		v[2] = v[2] * t;
		return *this;
	}
	vec3& operator /=(const float t) {
		v[0] = v[0] / t;
		v[1] = v[1] / t;
		v[2] = v[2] / t;
		return *this;
	}

	double length() const {
		return sqrt(lengthSquare());
	}

	double lengthSquare() const {
		return v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
	}

	static vec3 random() {
		return vec3(randomDouble(), randomDouble(), randomDouble());
	}

	static vec3 random(double min, double max) {
		return vec3(randomDouble(min,max), randomDouble(min, max), randomDouble(min, max));
	}

	bool nearZero() const {
		const auto s = 1e-8;
		return (fabs(v[0] < s) && fabs(v[1] < s) && fabs(v[2] < s));
	}

public:
	double v[3];
};

vec3 operator+ (const vec3& u, const vec3& v1) {
	return vec3(u.v[0] + v1.v[0], u.v[1] + v1.v[1], u.v[2] + v1.v[2]);
}

vec3 operator- (const vec3& u, const vec3& v1) {
	return vec3(u.v[0] - v1.v[0], u.v[1] - v1.v[1], u.v[2] - v1.v[2]);
}

vec3 operator*(const vec3& u, const vec3& v1) {
	return vec3(u.v[0] * v1.v[0], u.v[1] * v1.v[1], u.v[2] * v1.v[2]);
}

vec3 operator*(double t, const vec3& v1) {
	return vec3(t * v1.v[0], t * v1.v[1], t * v1.v[2]);
}

vec3 operator*(const vec3& v1,double t) {
	return t*v1;
}

vec3 operator/(vec3 v, double t) {
	return (1 / t) * v;
}

double dot(const vec3& u, const vec3& v) {
	return u.v[0] * v.v[0] + u.v[1] * v.v[1] + u.v[2] * v.v[2];
}

vec3 cross(const vec3& u, const vec3& v) {
	return vec3(u.v[1] * v.v[2] - u.v[2] * v.v[1], u.v[2] * v.v[0] - u.v[0] * v.v[2], u.v[0] * v.v[1] - u.v[1] * v.v[0]);
}

vec3 unitVector(vec3 v) {
	return v / v.length();
}

vec3 randomInUnitSphere() {
	while (true) {
		vec3 p = vec3::random(-1.0, 1.0);
		if (p.lengthSquare() >= 1) continue;
		return p;
	}
}

vec3 randomInUnitDisk() {
	while (true) {
		vec3 p = vec3(randomDouble(-1, 1), randomDouble(-1, 1), 0);
		if (p.lengthSquare() >= 1) continue;
		return p;
	}
}

vec3 randomUnitVector() {
	return unitVector(randomInUnitSphere());
}

vec3 reflect(const vec3& v, const vec3& n) {
	return v - 2 * dot(v, n) * n;
}

vec3 refract(const vec3& uv, const vec3& n, double over) {
	double cos = fmin(dot(-uv, n), 1.0);
	vec3 rout = over * (uv + cos * n);
	vec3 paral = -sqrt(fabs(1.0 - rout.lengthSquare())) * n;
	return rout + paral;
}

using color = vec3;