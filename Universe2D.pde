//============================================================================================================================================================[ Global ]
float w, h;
float margin = 50;
float pxLengh = pow(2, 7);
float kmLengh = 1e5;
float slLengh(){ return kmLengh/299792; }
float px_km(){ return pxLengh/kmLengh; } float km_px(){ return 1/px_km(); }
float km_sl(){ return kmLengh/slLengh(); } float sl_km(){ return 1/km_sl(); }
float sl_px(){ return slLengh()/pxLengh; } float px_sl(){ return 1/sl_px(); }
float c = 2.59e10;//km/d
float zoomSpeed = 1.05;
PVector originPx = new PVector(pxLengh/2, pxLengh/2);
float pxSize = 4;
float[][] gravityPoints = new float[int(pxLengh) + 1][int(pxLengh) + 1];
color[][] colorPoints = new color[int(pxLengh)][int(pxLengh)];
//============================================================================================================================================================[ Principais ]
void setup() {//define as condiçoes iniciais
  size(1200, 600);
  w = width - margin;
  h = height - margin;
  colorMode(RGB, 100);
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void draw() {//atualiza a todo instante
  frameRate(24);
  background(5, 5, 10);
  fill(100);
  
  ClearColorGrid();
  
  float[] propEarth = {         0.1908,          0.5472,          0.8901,          0.9945,         1.0000};//criação da Terra
  color[] rgbEarth  = {color(95,88,60), color(95,60,18), color(94,36,20), color(51,34,18), color(0,30,40)};
  Orb earth = new Orb(6731, 5.972e24, new PVector(0, 0), propEarth, rgbEarth);
  
  float[] propblackHole = {      1.0000};//criação do buraco negro
  color[] rgbblackHole  = {color(0,0,0)};
  //Orb blackHole = new Orb(0.1, 2e30, new PVector(0, 0), propblackHole, rgbblackHole);

  float[] propMoon = {         0.1393,          0.2775,          0.9770,          1.0000};//criação da Lua
  color[] rgbMoon  = {color(99,25,13), color(42,05,00), color(15,15,15), color(58,58,58)};
  //Orb moon = new Orb(1737, 7.349e22, new PVector(-3.844e5/10, 0), propMoon, rgbMoon);
  
  MiniMap(180);
  Grid(pxLengh/32);
  DrawUniverse();
  GuideGrid(pxLengh/8);
  GuideGrid(pxLengh/4);
}
//============================================================================================================================================================[ Interações ]
void mouseWheel(MouseEvent event){//aproxima ou aumenta a visibilidade
  if(InsideGrid(RealToVirtual(mouseX, mouseY).x) && InsideGrid(RealToVirtual(mouseX, mouseY).y)){
    if(event.getCount()*5e3 + kmLengh > 2.5e4) kmLengh += event.getCount()*5e3;
    else kmLengh = 2.5e4;
    //originPx.x += -event.getCount()*pow(zoomSpeed, -event.getCount())*RealToVirtual(mouseX, mouseY).x/pxLengh/2;// - event.getCount()*originPx.x/2;
    //originPx.y += -event.getCount()*pow(zoomSpeed, -event.getCount())*RealToVirtual(mouseX, mouseY).y/pxLengh/2;// - event.getCount()*originPx.y/2;
    //originPx.y += event.getCount()*zoomSpeed*RealToVirtual(mouseX, mouseY).y/pxLengh;// - event.getCount()*originPx.y/2;
  }
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void mouseDragged(){
  originPx.x += (RealToVirtual(mouseX, mouseY).x - RealToVirtual(pmouseX, pmouseY).x);
  originPx.y += (RealToVirtual(mouseX, mouseY).y - RealToVirtual(pmouseX, pmouseY).y);
}
//============================================================================================================================================================[ Classes ]
class Orb{//corpo celeste redondo e com massa
  color rgb;
  float G = 4.98217402e-10;//km³/kg.d²
  float radius, mass;
  PVector position;
  PVector velocity;
  float[] propLayers;
  color[] colorLayers;
  Orb(float radius, float mass, PVector position, float[] prop, color[] rgb){
    propLayers = prop;
    colorLayers = rgb;
    this.radius = radius;//km
    this.mass = mass;//kg
    this.position = position;
    this.velocity = new PVector(0, 0);
    ApplyImage();
    ApplyGravity();
    //EllipseGuide();
  }
  void ApplyImage(){
    for(float r = 0.1; r < radius*px_km(); r += 0.1){
      for(float o = 0; o < TWO_PI; o += 0.01){
        int pxX = int(r*cos(o) + position.x*px_km() + originPx.x);
        int pxY = int(r*sin(o) + position.y*px_km() + originPx.y);
        if(InsideGrid(pxX) && InsideGrid(pxY))
          colorPoints[pxX][pxY] = ColorByProp(r/(radius*px_km()));
      }
    }
  }
  void ApplyGravity(){
    for(float y = 0; y <= pxLengh; y++){
      for(float x = 0; x <= pxLengh; x++){
        stroke(100, 10);
        PVector d = new PVector((x - originPx.x)*km_px() - (position.x + originPx.x), (y - originPx.y)*km_px() - (position.y + originPx.y));
        if(d.mag() > radius)
          gravityPoints[int(x)][int(y)] += G*mass/sq(d.mag()*km_px());
        else
          gravityPoints[int(x)][int(y)] += G*mass*d.mag()*km_px()/pow(radius*km_px(), 3);
          //gravityPoints[int(x)][int(y)] += G*mass/sq(radius*km_px());
          //gravityPoints[int(x)][int(y)] += -2*G*mass/d.mag();
      }
    }
  }
  /*void EllipseGuide(){
    float r1, r2;
    if(radius*px_km() < 8){ r1 = 8; r2 = 8; }
    else{ r1 = radius*px_km(); r2 = radius*px_km(); }
    stroke(100, 50); strokeWeight(0.5); noFill();
    ellipse(VirtualToReal(position.x*px_km() + originPx.x, position.y*px_km() + originPx.y).x,
            VirtualToReal(position.x*px_km() + originPx.x, position.y*px_km() + originPx.y).y, (r1 + 5)*2, (r1 + 10)*2*h/w);
    stroke(100, 30); strokeWeight(0.3); noFill();
    ellipse(VirtualToReal(position.x*px_km() + originPx.x, position.y*px_km() + originPx.y).x,
            VirtualToReal(position.x*px_km() + originPx.x, position.y*px_km() + originPx.y).y, (r2 + 5)*2, (r2 + 10)*2*h/w);
  }*/
  color ColorByProp(float prop){//metodo auxiliar q seleciona as cores certas
    int i = 0;
    do if(prop < propLayers[i]) return colorLayers[i]; while(propLayers[i++] < 1);
    return 0;
  }
}
//============================================================================================================================================================[ Auxiliares ]
boolean InsideGrid(float a){ return 0 <= a && a < pxLengh; }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PVector VirtualToReal(float x, float y){//retorna a coordenada real a partir de dada coordenada virtual 
  return new PVector((( x + y)*w/pxLengh + margin)/2,
                 (h + (-x + y)*h/pxLengh + margin)/2);
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PVector RealToVirtual(float x, float y){//retorna a coordenada virtual a partir de dada coordenada real
  return new PVector(((2*x - margin)*pxLengh/w - (2*y - margin - h)*pxLengh/h)/2,
                     ((2*y - margin - h)*pxLengh/h + (2*x - margin)*pxLengh/w)/2);
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void GetFill(float x, float y){//aplica a cor (preenchimento) do ponto especificado
  if(!InsideGrid(x) || !InsideGrid(y)) return;
  if(gravityPoints[int(x)][int(y)] >= c) fill(0);
  else if(colorPoints[int(x)][int(y)] != 0) fill(colorPoints[int(x)][int(y)]);
  else noFill();
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void GetStroke(float x, float y, float weight){//aplica a cor (borda) do ponto especificado
  if(!InsideGrid(x) || !InsideGrid(y)) return;
  strokeWeight(weight);
  if(colorPoints[int(x)][int(y)] != 0) stroke(colorPoints[int(x)][int(y)]);
  else noStroke();
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void ClearColorGrid(){//limpa as cores na malha
  for(int y = 0; y <= pxLengh; y++){
    for(int x = 0; x <= pxLengh; x++){
      if(x != pxLengh && y != pxLengh) colorPoints[x][y] = 0;
      gravityPoints[x][y] = 0;
    }
  }
}
//============================================================================================================================================================[ Interface ]
void MiniMap(float mapSize){//desenha um mini mapa no canto da tela
  float zeroX = w - mapSize + margin/2;
  float zeroY = h - mapSize + margin/2;
  float mapScale = mapSize/pxLengh;
  stroke(100, 100, 100, 50); strokeWeight(1); noFill();
  rect(zeroX, zeroY, mapSize, mapSize);
  for(float y = 0; y < pxLengh; y++){
    for(float x = 0; x < pxLengh; x++){
      noStroke(); GetFill(x, y);
      rect(zeroX + x*mapScale, zeroY + y*mapScale, mapScale, mapScale);
    }
  }
  stroke(100, 50); strokeWeight(1); noFill();
  if(InsideGrid(originPx.y))
    line(zeroX, zeroY + originPx.y*mapScale, zeroX + pxLengh*mapScale, zeroY + originPx.y*mapScale);
  if(InsideGrid(originPx.x))
    line(zeroX + originPx.x*mapScale, zeroY, zeroX + originPx.x*mapScale, zeroY + pxLengh*mapScale);
  stroke(100, 20); strokeWeight(1); noFill();
  float mod = 16;
  for(float x = 1; x < pxLengh/mod; x++)
    line(zeroX + x*mapScale*mod, zeroY, zeroX + x*mapScale*mod, zeroY + mapSize);
  for(float y = 1; y < pxLengh/mod; y++)
    line(zeroX, zeroY + y*mapScale*mod, zeroX + mapSize, zeroY + y*mapScale*mod);
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void DrawUniverse(){//desenha os objetos do universo
  for(int y = 0; y < pxLengh; y++){
    for(int x = 0; x < pxLengh; x++){
      beginShape();
      noStroke(); GetFill(x, y);
      vertex(VirtualToReal(x, y).x, VirtualToReal(x, y).y + gravityPoints[x][y]);
      vertex(VirtualToReal(x, y + 1).x, VirtualToReal(x, y + 1).y + gravityPoints[x][y + 1]);
      vertex(VirtualToReal(x + 1, y + 1).x, VirtualToReal(x + 1, y + 1).y + gravityPoints[x + 1][y + 1]);
      vertex(VirtualToReal(x + 1, y).x, VirtualToReal(x + 1, y).y + gravityPoints[x + 1][y]);
      endShape();
    }
  }
  stroke(100, 100, 100, 60); strokeWeight(1); noFill();
  beginShape();
  vertex(VirtualToReal(0, 0).x, VirtualToReal(0, 0).y);
  vertex(VirtualToReal(0, pxLengh).x, VirtualToReal(0, pxLengh).y);
  vertex(VirtualToReal(pxLengh, pxLengh).x, VirtualToReal(pxLengh, pxLengh).y);
  vertex(VirtualToReal(pxLengh, 0).x, VirtualToReal(pxLengh, 0).y);
  vertex(VirtualToReal(0, 0).x, VirtualToReal(0, 0).y);
  endShape();
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void Grid(float mod){//desenha a malha com triangulos isometricos
  noStroke(); fill(100, 80);
  text(String.format("%.3f", -originPx.x*sl_px()) + " s.luz", VirtualToReal(0, pxLengh/2).x, VirtualToReal(0, pxLengh/2).y);
  text(String.format("%.3f", -originPx.y*sl_px()) + " s.luz", VirtualToReal(pxLengh/2, 0).x, VirtualToReal(pxLengh/2, 0).y);
  text(String.format("%.3f", (pxLengh - originPx.x)*sl_px()) + " s.luz", VirtualToReal(pxLengh, pxLengh/2).x, VirtualToReal(pxLengh, pxLengh/2).y);
  text(String.format("%.3f", (pxLengh - originPx.y)*sl_px()) + " s.luz", VirtualToReal(pxLengh/2, pxLengh).x, VirtualToReal(pxLengh/2, pxLengh).y);
  text(0, VirtualToReal(originPx.x, originPx.y).x,VirtualToReal(originPx.x, originPx.y).y);
  stroke(100, 50); strokeWeight(1); noFill();
  if(InsideGrid(originPx.y))
    line(VirtualToReal(0, originPx.y).x, VirtualToReal(0, originPx.y).y, VirtualToReal(pxLengh, originPx.y).x, VirtualToReal(pxLengh, originPx.y).y);
  if(InsideGrid(originPx.x))
    line(VirtualToReal(originPx.x, 0).x, VirtualToReal(originPx.x, 0).y, VirtualToReal(originPx.x, pxLengh).x, VirtualToReal(originPx.x, pxLengh).y);
  for(int y = 0; y < pxLengh; y += mod){
    beginShape(TRIANGLE_STRIP);
    for(int x = 0; x <= pxLengh; x += mod){
      stroke(100, 100, 100, 5); strokeWeight(0.25); noFill();
      vertex(VirtualToReal(x, y).x, VirtualToReal(x, y).y + gravityPoints[x][y]);
      vertex(VirtualToReal(x, y + mod).x, VirtualToReal(x, y + mod).y + gravityPoints[x][y + int(mod)]);
    }
    endShape();
  }
  
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void GuideGrid(float mod){//marca linhas guias
  stroke(100, 100, 100, mod); strokeWeight(0.5 + mod/50); noFill();
  for(int y = 0; y <= pxLengh; y++){
    for(int x = 0; x <= pxLengh; x++){
      if(x != pxLengh && y%mod == 0)
        line(VirtualToReal(x, y).x, VirtualToReal(x, y).y + gravityPoints[x][y], VirtualToReal(x + 1, y).x, VirtualToReal(x + 1, y).y + gravityPoints[x + 1][y]);
      if(y != pxLengh && x%mod == 0)
        line(VirtualToReal(x, y).x, VirtualToReal(x, y).y + gravityPoints[x][y], VirtualToReal(x, y + 1).x, VirtualToReal(x, y + 1).y + gravityPoints[x][y + 1]);
    }
  }
}
