first : main.o
	g++ -o first main.o

main.o : vec3.h sphere.h ray.h metal.h material.h lambertian.h hitlist.h hitable.h dielectric.h camera.h main.cpp
	g++ -c -o main.o main.cpp