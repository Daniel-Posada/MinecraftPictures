import java.util.ArrayList;
import java.io.File;  

int numberOfBlocks = 365;

ArrayList<String> files = new ArrayList<String>();
PImage[] blocks = new PImage[numberOfBlocks];
color[] colors = new color[numberOfBlocks];
String picture = "Niko 150.jpg";

void settings() {
  PImage pic = loadImage(picture);
  size(pic.width*16,pic.height*16);
}

void setup(){
  File targetFolder = new File("/Users/Danny/Desktop/block");
  File[] listOfFiles = targetFolder.listFiles();
  PImage pic = loadImage(picture);
  loadPixels();
  
  //Adds files to Arraylist
  for (File file : listOfFiles){
      // Check that we are dealing with a file, not a directory,
      // and that it's filename ends with .png case-sensitive!
      if (file.isFile() && file.getName().endsWith("png"))
          files.add(file.getPath()); 
  }  
  //Turns Files into Images
  for(int i = 0; i < files.size(); i++)
    blocks[i] = loadImage(files.get(i));  
  
  
  //Assigns color averages to respective position on color array
  for(int i = 0; i < blocks.length;i++){
    float[] values = new float[3];
    loadPixels();
    for(int j = 0; j < 256;j++){
      values[0]+= red(blocks[i].pixels[j]);
      values[1]+= green(blocks[i].pixels[j]);
      values[2]+= blue(blocks[i].pixels[j]);
    }
    //Finds the Color Average for each block
    for(int j=0;j<3;j++)
      values[j]/=256;
    colors[i] = color(values[0],values[1],values[2]);
  }
  
  
  //finds the closest matching block
  int dimensions = pic.width*pic.height;
  int index = 0;
  int countx = 0;
  int county = 0;
  
  //Creates copy of image pixel data as a 2D array
  color[][] imagePixels = new color[pic.width][pic.height];
  int counter = 0;
  for(int i = 0; i < pic.height; i++) {
    for(int j = 0; j < pic.width; j++) {
      imagePixels[counter%pic.width][counter/pic.width] = pic.pixels[counter];
      counter++;
    }
  }
  
  //Dithering formula
  for(int i = 0; i < dimensions; i++){
    int x = i%pic.width;
    int y = i/pic.width;
    
    color oldPixel = imagePixels[x][y];
    color newPixel = colors[findClosestColor(oldPixel)];
    imagePixels[x][y] = newPixel;
    
    float[] error = new float[3];
    error[0] = red(oldPixel) - red(newPixel);
    error[1] = green(oldPixel) - green(newPixel);
    error[2] = blue(oldPixel) - blue(newPixel);
    
    if(x < pic.width-1 && x > 0 && y < pic.height-1) { //Takes care of edge cases
      errorDiffusion(x,y,error, imagePixels);
    }
    
    int wow = 765;
    float diff = 0;
    //Finds index of closest color block
    for(int j = 0; j < colors.length; j++){
      diff = abs(red(colors[j])-red(imagePixels[x][y])) + abs(green(colors[j])-green(imagePixels[x][y])) + abs(blue(colors[j])-blue(imagePixels[x][y]));
      if(diff < wow) {
        wow = int(diff);
        index = j;
      }
    }
     //Places Blocks
     image(blocks[index],countx*16,county*16); 
     if(countx == pic.width-1){
       countx = 0;
       county++;
     }
     else
       countx++;
  }
    
   //saves photo
   save("DitherTwo"+picture);
}

//Find index of color that most closely matches reference color 
int findClosestColor(color c) {
    int index = 0;
    int wow = 765;
    float diff = 0;
    //Finds index of closest block
    for(int j = 0; j < colors.length; j++){
      diff = abs(red(colors[j])-red(c)) + abs(green(colors[j])-green(c)) + abs(blue(colors[j])-blue(c));
      if(diff < wow) {
        wow = int(diff);
        index = j;
      }
    } 
    return index;
}

//Error Diffusion for Dithering 
void errorDiffusion(int x, int y, float[] quantErr, color[][] arr) {
    float newRed;
    float newGreen;
    float newBlue;
  
    newRed = red(arr[x + 1][y]) + quantErr[0] * (7/16.0);
    newGreen = green(arr[x + 1][y]) + quantErr[1] * (7/16.0);
    newBlue = blue(arr[x + 1][y]) + quantErr[2] * (7/16.0);
    arr[x + 1][y] = color(newRed,newGreen,newBlue);
    
    newRed = red(arr[x - 1][y + 1]) + quantErr[0] * (3/16.0);
    newGreen = green(arr[x - 1][y + 1]) + quantErr[1] * (3/16.0);
    newBlue = blue(arr[x - 1][y + 1]) + quantErr[2] * (3/16.0);
    arr[x - 1][y + 1] = color(newRed,newGreen,newBlue);
    
    newRed = red(arr[x][y + 1]) + quantErr[0] * (5/16.0);
    newGreen = green(arr[x][y + 1]) + quantErr[1] * (5/16.0);
    newBlue = blue(arr[x][y + 1]) + quantErr[2] * (5/16.0);
    arr[x][y + 1] = color(newRed,newGreen,newBlue);
    
    newRed = red(arr[x + 1][y + 1]) + quantErr[0] * (1/16.0);
    newGreen = green(arr[x + 1][y + 1]) + quantErr[1] * (1/16.0);
    newBlue = blue(arr[x + 1][y + 1]) + quantErr[2] * (1/16.0);
    arr[x + 1][y + 1] = color(newRed,newGreen,newBlue);
}
