import peasy.*;

/**
 * This sketch shows how to use the FFT class to analyze a stream
 * of sound. Change the number of bands to get more spectral bands
 * (at the expense of more coarse-grained time resolution of the spectrum).
 */

import processing.sound.*;

// Declare the sound source and FFT analyzer variables
SoundFile sample;
FFT fft;

// Define how many FFT bands to use (this needs to be a power of two)
int bands = 128;

// Define a smoothing factor which determines how much the spectrums of consecutive
// points in time should be combined to create a smoother visualisation of the spectrum.
// A smoothing factor of 1.0 means no smoothing (only the data from the newest analysis
// is rendered), decrease the factor down towards 0.0 to have the visualisation update
// more slowly, which is easier on the eye.
float smoothingFactor = 0.2;

// Create a vector to store the smoothed spectrum data in
float[] sum = new float[bands];

// Variables for drawing the spectrum:
// Declare a scaling factor for adjusting the height of the rectangles
int scale = 1;
// Declare a drawing variable for calculating the width of the 
float barWidth;

int cols, rows;
int scl = 20;
int w = 600;
int h = 600;

float[][] terrain;

PeasyCam camera;

public void setup() {
  camera = new PeasyCam(this, 0, 0, 0, 50);
  
  size(600, 600, P3D);
  background(255);

  // Calculate the width of the rects depending on how many bands we have
  barWidth = width/float(bands);

  // Load and play a soundfile and loop it.
  sample = new SoundFile(this, "song.mp3");
  sample.loop();

  // Create the FFT analyzer and connect the playing soundfile to it.
  fft = new FFT(this, bands);
  fft.input(sample);
  
  cols = w / scl;
  rows = h / scl;
  
  terrain = new float[bands][bands];
  
}

public void draw() {
  // Set background color, noStroke and fill color
  background(0);
  stroke(255);
  noFill();
  
  //translate(width/2, height/2);
  rotateX(PI/3);
  
  translate(-w/2, -h/2);
  
  // Perform the analysis
  fft.analyze();

  for (int i = 0; i < bands-1; i++) {
    // Smooth the FFT spectrum data by smoothing factor
    sum[i] += (fft.spectrum[i] - sum[i]) * smoothingFactor;

    // Draw the rectangles, adjust their height using the scale factor
    //rect(i*barWidth, height, barWidth, -sum[i]*height*scale);
    terrain[i][i] = +sum[i]*(height/2)*scale;
  }
  
  for(int y = 0; y < rows; y+=2) {
    beginShape(TRIANGLE_STRIP);
    
    
    int random = (int)random(1,3);
    for(int x = 0; x < cols; x++)
    {
      if(random == 1) {
        vertex(x*scl, y*scl, terrain[x][x]);
      }
      else {
        vertex(x*scl, y*scl, -terrain[x][x]);
      }
      
      vertex(x*scl, (y+1)*scl);
    }
    endShape();
  }
  
}
