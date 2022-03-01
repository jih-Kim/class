Coms 327 Project 2 part a
-----------------------------------------------------------------------------------------------------------------------------------
SoundSamples.cpp and SoundSamples.h
In this class, there is three constructor and copy constructor.

SoundSamples()
This is the default constructor which takes no variable and set length to 0 and sample rate to 8000.

SoundSamples(float* sample, int length, float samplerate)
This constructor takes three variable which is float* sample, int length, float samplerate save the variable.

SoundSamples(int length, float samplerate)
This constructor takes two variable which is int length, float samplerate and save the varaible.

SoundSamples(const SoundSamples& target)
This is copy constructor. This constructor deep copies the traget data.

SetSampleRate(float sample)
This setter method set the samplerate as sample

getSempleRate()
This getter method brings the samplerate

setlength(int length)
This setter method set the length

length()
This getter method brings the length

getSamples()
This getter method brings the sample, which is float *

setSamples(float* sample)
This setter method set the sample

operator=(const SoundSamples& sound)
This is overload operator of =. It deep copy the sound

operator[](int index)
This is overload operator of []. It returns a reference to the sample at a specific index

operator+(const SoundSamples& sound)
This is overload operator of +. It appends one SoundSample to another.

-----------------------------------------------------------------------------------------------------------------------------------
main.cpp
This main ask user to input the five thing which is type, SampleRate, frequency, duration, and filename. Type is 1 for sin, 2 for square, 3 for triangle, 4 for sawtooth.
It calculate the wave data using the input data and save the data into the file.

-----------------------------------------------------------------------------------------------------------------------------------
SawtoothWave.cpp and SawtoothWave.h
This is subclass of wave class.

SawtoothWave(string names)
This is constructor of sawtoothwave. It saves the name.

float generateFunction(float time)
This calculate the data using the time. It return float data and called several time when user call generateFunction method.

-----------------------------------------------------------------------------------------------------------------------------------
SineWave.cpp and SineWave.h
This is subclass of wave class.

SineWave(string names)
This is constructor of sawtoothwave. It saves the name.

float generateFunction(float time)
This calculate the data using the time. It return float data and called several time when user call generateFunction method.

-----------------------------------------------------------------------------------------------------------------------------------
SquareWave.cpp and SquareWave.h
This is subclass of wave class.

SquareWave(string names)
This is constructor of squarewave. It saves the name.

float generateFunction(float time)
This calculate the data using the time. It return float data and called several time when user call generateFunction method.

-----------------------------------------------------------------------------------------------------------------------------------
TriangleWave.cpp and TriangleWave.h
This is subclass of wave class.

TriangleWave(string names)
This is constructor of Trianglewave. It saves the name.

float generateFunction(float time)
This calculate the data using the time. It return float data and called several time when user call generateFunction method.

-----------------------------------------------------------------------------------------------------------------------------------
soundio.cpp and soundio.h
This class uses only one method which is save data to the file.

void OutPutSound(SoundSamples* samples, string filename)
This method save the samples data to the file which has filename.

-----------------------------------------------------------------------------------------------------------------------------------
wave.cpp and wave.h
Wave()
This is default constructor for wave class. It sets name as noName.

Wave(string names)
This constructor using one variable. It save the names to the wave.

void setName(string names)
This is setter method for name. It sets name as names.

string getName()
This is getter method for name. It brings the name.

SoundSamples* generateSamples(float frequency, float samplerate, float duration)
This function calculate the data using the generateFunction method and save data to the result which returns when the method is finish.

---------------------------------------------------------------------------------------------------------------------------
Coms 327 Project 2 part b
---------------------------------------------------------------------------------------------------------------------------
TestMain.cpp
Testing the two method that added by part b
The program ask user to enter the type, duration, filename, delay, attenuation, atime, alevel, dtime, slevel, rtime, and multiple node.
When the user want to finish the program simply type the minus value when the program ask for node value.
Then the program save the data value to the filename which user typed and then finish the program.

----------------------------------------------------------------------------------------------------------------------------
SoundSamples.cpp
Add two additional method.
void reverb2(float delay, float attenuation)
This value calculate the reverb function using delay and attenuation. It replace the sample data (which is calculate by the program)
that store in the sound data.

void adsr(float atime, float alevel, float dtime, float slevel, float rtime)
This method calculate the new sample data and then replace this sample data to old sample data.