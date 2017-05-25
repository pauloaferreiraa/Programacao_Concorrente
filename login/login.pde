import java.util.*;
import controlP5.*;
import java.net.*;
import java.util.concurrent.locks.*;
//carregar imagens background
PImage image_main_screen,image_login;


//caixas de texto e botoes
ControlP5 cp5;
//screens
final int main_screen = 0;
final int login_screen = 1;
final int game_screen = 2;
int state = main_screen;

final int button_width = 150;
final int button_height = 50;
final int textfield_width = 150;
final int textfield_height = 50;

Cliente c1 = null;
Message m = null;
Estado estado = null;


void setup(){
    cp5 = new ControlP5(this);

    size(800,600);
    image_main_screen = loadImage("main_screen.jpg");
    image_login = loadImage("login_screen.jpg");
  
    PFont pfont = createFont("Arial",20,true);
    PFont pfont_small = createFont("Arial",15,true);
    
    cp5.addButton("Connect") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)-(button_width/2),(height/2)-(button_height/2))
                 .setSize(button_width,button_height)
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      c1 = new Cliente();
                      //Caso o servidor nao esteja ligado, o connect vai dar exceçao e nao muda o estado
                      try{
                        c1.connect();
                        estado = new Estado();
                        m = new Message(c1.getPingSocket(),estado);
                        m.start();
                        state = login_screen;
                      }catch(Exception e){
                        state = main_screen;
                      }
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
       .setPasswordMode(true)
       ;  
                  
    cp5.addButton("Login") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)+70,(height/2)-100)
                 .setSize(button_width,button_height).hide()
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      String user = cp5.get(Textfield.class,"Username").getText();
                      c1.login(user,cp5.get(Textfield.class,"Password").getText());
                      cp5.hide();
                      state = game_screen;               
                      
                    }
                  });
       
    cp5.addButton("New account") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)+70,(height/2)-10)
                 .setSize(button_width+10,button_height).hide()
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      c1.create_account(cp5.get(Textfield.class,"Username").getText(),cp5.get(Textfield.class,"Password").getText());
                      cp5.hide();
                      state = game_screen;
                    }
                  });
                  
                   
    cp5.addButton("Disconnect") //botao disconnect da pagina
                 .setValue(0).setColorBackground(color(200)).setFont(pfont_small)
                 .setPosition(width-(button_width),height-(button_height))
                 .setSize(button_width/2+35,button_height/2).hide()
                 .onPress(new CallbackListener(){
                       public void controlEvent(CallbackEvent theEvent){
                           try{
                             c1.disconnect();
                             state=main_screen;
                           }catch(Exception e){}
                       }
                 });
                 
    cp5.addButton("Close Account") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)+70,(height/2)+70)
                 .setSize(button_width+20,button_height).hide()
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      c1.close_account(cp5.get(Textfield.class,"Username").getText(),cp5.get(Textfield.class,"Password").getText());
                      
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
    
    cp5.getController("Connect").show();
    cp5.getController("Login").hide();
    cp5.getController("New account").hide();
    cp5.getController("Close Account").hide();
    cp5.getController("Username").hide();
    cp5.getController("Password").hide();
    cp5.getController("Disconnect").hide();
   
    image(image_main_screen,0,0,width,height);
}

void show_login(){
  
  float centerX = width/2;
  float centerY  = height/2;
  
  
  image(image_login,0,0,width,height);
  
  cp5.getController("Login").show();
  cp5.getController("New account").show();
  cp5.getController("Close Account").show();
  cp5.getController("Username").show();
  cp5.getController("Password").show();
  cp5.getController("Disconnect").show();
}

void show_game_screen(){
  
}

void keyPressed(){
  if(state == game_screen){
    if(keyCode == UP){
      c1.sendMessage("\\walk");
    }
  }
}

  