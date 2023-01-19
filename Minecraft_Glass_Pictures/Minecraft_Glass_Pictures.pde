import java.util.ArrayList;
import java.io.File;  

ArrayList<String> files = new ArrayList<String>();
PImage[] blocks = new PImage[365];
PImage[] glass = new PImage[16];
color[] colors = new color[6205]; //Original blocks: 293 //Total Original Blocks: 4981
String picture = "kiwi.jpeg";

void settings() {
  PImage pic = loadImage(picture);
  size(pic.width*16,pic.height*16);
}

void setup(){
  File targetFolder = new File("/Users/Danny/Desktop/block");
  File[] listOfFiles = targetFolder.listFiles();
  PImage pic = loadImage(picture);
  
  //Adds files to Arraylist
  for (File file : listOfFiles){
      // Check that we are dealing with a file, not a directory,
      // and that it's filename ends with .png case-sensitive!
      if (file.isFile() && file.getName().endsWith("png"))
          files.add(file.getPath()); 
  }  
  //Turns Block files into Images
  for(int i = 0; i < files.size(); i++)
    blocks[i] = loadImage(files.get(i)); 

  //Does the same with the Glass File
  files = new ArrayList<String>();
  targetFolder = new File("/Users/Danny/Desktop/Glass");
  listOfFiles = targetFolder.listFiles();
  for (File file : listOfFiles){
      // Check that we are dealing with a file, not a directory,
      // and that it's filename ends with .png case-sensitive!
      if (file.isFile() && file.getName().endsWith("png"))
          files.add(file.getPath()); 
  }  
  for(int i = 0; i < files.size(); i++)
    glass[i] = loadImage(files.get(i)); 
  
  //Finds and assigns color averages of solid blocks
  loadPixels();
  for(int i = 0; i < blocks.length; i++){
    float[] values = new float[3];
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
  
  //Finds and Assings color averages to glass + solid blocks
  int count = blocks.length;
  loadPixels();
  for(int g = 0; g < glass.length; g++) {
    for(int b = 0; b < blocks.length; b++) {
      float[] values = new float[3];
      for(int j = 0; j < 256; j++){
        float a = alpha(glass[g].pixels[j])/255;
        values[0] += getColor(red(glass[g].pixels[j]),red(blocks[b].pixels[j]),a); 
        values[1] += getColor(green(glass[g].pixels[j]),green(blocks[b].pixels[j]),a); 
        values[2] += getColor(blue(glass[g].pixels[j]),blue(blocks[b].pixels[j]),a);
      }
      for(int j=0;j<3;j++)
        values[j]/=256;
      colors[count] = color(values[0],values[1],values[2]);
      count++;
    }
  }
  
  //finds the closest matching color
  int dimensions = pic.width*pic.height;
  int index = 0;
  int countx = 0;
  int county = 0;
  for(int i = 0; i < dimensions; i++){
    int wow = 765;
    float diff = 0;
    for(int j = 0; j < colors.length; j++){
      diff = abs(red(colors[j])-red(pic.pixels[i])) + abs(green(colors[j])-green(pic.pixels[i])) + abs(blue(colors[j])-blue(pic.pixels[i]));
      if(diff < wow) {
        wow = int(diff);
        index = j;
      }
    }
     //Places Blocks
     image(blocks[index-blocks.length*int(index/blocks.length)],countx*16,county*16); 
     //Places Glass
     if(index >= blocks.length)
       image(glass[(index/blocks.length)-1],countx*16,county*16);
    
     if(countx == pic.width-1){
       countx = 0;
       county++;
     }
     else
       countx++;
   }
   
   //saves photo
   save("GlasscraftTwo "+picture);
}

public int getColor(float g, float b, float a) { ///float a has to be a decimal between 0 and 1
  float c = g*a +b*(1-a);
  c /= a + (1-a);
  return (int)c;
}
