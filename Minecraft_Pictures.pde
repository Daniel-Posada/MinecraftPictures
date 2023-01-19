import java.util.ArrayList;
import java.io.File;  

int numberOfBlocks = 365;

ArrayList<String> files = new ArrayList<String>();
PImage[] blocks = new PImage[numberOfBlocks];
color[] colors = new color[numberOfBlocks];
String picture = "Snickers.png";

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
  
  //Assings color averages to respective position on color array
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
  
  //finds the closest matching color
  int dimensions = pic.width*pic.height;
  int index = 0;
  int countx = 0;
  int county = 0;
  for(int i = 0; i < dimensions; i++){
    int wow = 765;
    float diff = 0;
    //Finds index of closest block
    for(int j = 0; j < colors.length; j++){
      diff = abs(red(colors[j])-red(pic.pixels[i])) + abs(green(colors[j])-green(pic.pixels[i])) + abs(blue(colors[j])-blue(pic.pixels[i]));
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
   save("MineTwo"+picture);
}
