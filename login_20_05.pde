import java.util.*;
import controlP5.*;

//carregar imagens background
PImage image_main_screen,image_login;


//caixas de texto e botoes
ControlP5 cp5;
//screens
final int main_screen = 0;
final int login_screen = 1;
int state = main_screen;

final int button_width = 150;
final int button_height = 50;
final int textfield_width = 150;
final int textfield_height = 50;

void setup(){
    cp5 = new ControlP5(this);

    size(800,600);
    image_main_screen = loadImage("main_screen.jpg");
    image_login = loadImage("login_screen.jpg");
  
    PFont pfont = createFont("Arial",20,true);
    
    cp5.addButton("Connect") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)-(button_width/2),(height/2)-(button_height/2))
                 .setSize(button_width,button_height)
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      Cliente.connect();
                      state = login_screen;
                      cp5.getController("Connect").hide();
                    }
                  });
                  
     cp5.addTextfield("Username")
       .setPosition((width/2)-100,(height/2)-100)
       .setSize(textfield_width,textfield_height)
       .setFont(pfont)
       .setFocus(true)
       .setColor(color(255,255,255)).hide()
       ;
       
    cp5.addTextfield("Password")
       .setPosition((width/2)-100,(height/2)-10)
       .setSize(textfield_width,textfield_height)
       .setFont(pfont)
       .setFocus(true)
       .setColor(color(255,255,255)).hide()
       ;  
                  
    cp5.addButton("Login") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)+70,(height/2)-100)
                 .setSize(button_width,button_height).hide()
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      println(cp5.get(Textfield.class,"Username").getText());
                      println(cp5.get(Textfield.class,"Password").getText());
                    }
                  });
    
    cp5.addButton("New account") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)+70,(height/2)-10)
                 .setSize(button_width+10,button_height).hide()
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      println(cp5.get(Textfield.class,"Username").getText());
                      println(cp5.get(Textfield.class,"Password").getText());
                    }
                  });
    
     
    
                  
    
}

void draw() {
  background(0);
  switch (state){
    case main_screen:
      show_main_screen();
      break;
    case login_screen:
      show_login();
      break;
  } 
}

void show_main_screen(){
    float centerX = width/2;
    float centerY  = height/2;
    float w = 150;
    float h = 50;
   
    image(image_main_screen,0,0,width,height);
}

void show_login(){
  
  float centerX = width/2;
  float centerY  = height/2;
  
  
  image(image_login,0,0,width,height);
  
  cp5.getController("Login").show();
  cp5.getController("New account").show();
  cp5.getController("Username").show();
  cp5.getController("Password").show();
}



void controlEvent(ControlEvent theEvent) {
   
}

  