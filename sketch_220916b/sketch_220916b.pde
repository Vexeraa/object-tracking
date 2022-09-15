import hypermedia.video.*; //Web kamerasından görüntü yakalamak için video kütüphanesi
import java.awt.Rectangle; //Yüz koordinatlarını takip eden dikdörtgen sınıfı.
import processing.serial.*; //Arduino ile iletişim kurmak için bağlantı kütüphanesi
 
OpenCV opencv; //Bir OpenCV nesnesi oluşturulur
 
//Ekran Boyutu Parametreleri
int width = 320;
int height = 240;
 
// Kontrast / parlaklık değerleri
int Kontrast_degeri = 0;
int Parlaklik_degeri = 0;
 
Serial port; // Seri bağlantı noktası
 
//Mevcut servo konumlarını takip etmek için değişkenler.
char Servo_Tilt_Pozisyon = 90;
char Servo_Pan_Pozisyon = 90;
//Arduino seri komut arabirimi için pan / tilt servo kimlikleri.
char Tilt_Servo_Kimlik = 0;
char Pan_Servo_Kimlik = 1;
 
//Bu değişkenler, algılanan nesnenin ortası için x ve y konumunu tutar.
int Yuz_Y_Orta_Konumu=0;
int Yuz_X_Orta_Konumu=0;
 
//Ekranın ortasına karşılık gelen değişkenler
// bu değişkenler midFace değerleriyle karşılaştırılacaktır
int Ekran_Y_Orta_Konumu = (height/2);
int Ekran_X_Orta_Konumu = (width/2);
int Orta_Ekran_Penceresi = 10; //Ekranın ortası için kabul edilebilir hata değeri
 
//Pozisyonu güncelleştirdiğimiz her sefer servoya uygulanacak değişim derecesi.
int Adim_Derecesi=1;
 
void setup() {
//Ekran için bir pencere oluşturur
size( 320, 240 );
 
opencv = new OpenCV( this );
opencv.capture( width, height ); // Açık video akışı
 
opencv.cascade( "C:/Users/osman/Documents/Processing/libraries/opencv/haarcascades/myhaar.xml" );
 
//Port noktası ve iletişim hızı seçimi
port = new Serial(this,"COM14", 9600);
 
println( "Kontrastı değiştirmek için bu ekran penceresinin içinde X ekseni üzerine fareyi sürükleyin." );
println( "Parlaklığı değiştirmek için bu ekran penceresinin içinde Y ekseni üzerine fareyi sürükleyin." );
 
//Cihazı düz ileri bakacak şekilde ayarlamak için 90 derecede pan / tilt açısını Arduino'ya gönderir.
port.write(Tilt_Servo_Kimlik); //Send the Tilt Servo ID
port.write(Servo_Tilt_Pozisyon); //Send the Tilt Position (currently 90 degrees)
port.write(Pan_Servo_Kimlik); //Send the Pan Servo ID
port.write(Servo_Pan_Pozisyon); //Send the Pan Position (currently 90 degrees)
}
 
 
public void stop() {
opencv.stop();
super.stop();
}
 
 
 
void draw() {
// yeni bir çerçeve yakalar
opencv.read();
//griye dönüştürür
opencv.convert( GRAY );
opencv.contrast( Kontrast_degeri );
opencv.brightness( Parlaklik_degeri );
 
// Işleme devam et
Rectangle[] faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );
 
// Resmi görüntüle
image( opencv.image(), 0, 0 );
 
// Nesne bölgesi çizer
noFill();
stroke(255,0,0);
for( int i=0; i<faces.length; i++ ) {
rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height );
}
 
//Tanıtılan nesne tespit edilmi kontrol et.
if(faces.length > 0){
// Bir yüz bulunursa, çerçevedeki ilk yüzün orta noktasını bulun.
// Buradaki .x ve .y kooordinatları dikdörtgenin sol üst köşesine karşılık gelir,
// Böylece dikdörtgenin orta noktasını bulmak için bu değerleri işlenir.
Yuz_Y_Orta_Konumu = faces[0].y + (faces[0].height/2);
Yuz_X_Orta_Konumu = faces[0].x + (faces[0].width/2);
 
//Nesnedeki Y bileşeninin ekranın ortasından aşağıda olup olmadığını kontrol et.
if(Yuz_Y_Orta_Konumu < (Ekran_Y_Orta_Konumu - Orta_Ekran_Penceresi)){
if(Servo_Tilt_Pozisyon >= 5)Servo_Tilt_Pozisyon -= Adim_Derecesi; // Ekranın ortasındaysa, tilt servosunu indirmek için tiit açısını birer derece azalt.
}
//Nesnedeki Y bileşeninin ekranın ortasından yukarıda olup olmadığını kontrol et.
else if(Yuz_Y_Orta_Konumu > (Ekran_Y_Orta_Konumu + Orta_Ekran_Penceresi)){
if(Servo_Tilt_Pozisyon <= 175)Servo_Tilt_Pozisyon +=Adim_Derecesi; //Tilt servo açısını birer derece arttır.
}
//Nesnedeki X bileşeni, ekranın ortasının solunda olup olmadığını kontrol et.
if(Yuz_X_Orta_Konumu < (Ekran_X_Orta_Konumu - Orta_Ekran_Penceresi)){
if(Servo_Pan_Pozisyon >= 5)Servo_Pan_Pozisyon -= Adim_Derecesi; //Servoyu sola hareket ettirmek için pan açısını birer derece azalt.
}
//Nesnedeki X bileşeninin ekranın sağında olup olmadığını kontrol et.
else if(Yuz_X_Orta_Konumu > (Ekran_X_Orta_Konumu + Orta_Ekran_Penceresi)){
if(Servo_Pan_Pozisyon <= 175)Servo_Pan_Pozisyon +=Adim_Derecesi; //Servoyu sağa hareket ettirmek için pan açısını birer derece arttır.
}
 
}
//Arduino'ya servo kimlik ve açılarını gönder
port.write(Tilt_Servo_Kimlik);
port.write(Servo_Tilt_Pozisyon);
port.write(Pan_Servo_Kimlik);
port.write(Servo_Pan_Pozisyon);
 
delay(1);
}
 
 
 
/**
* Ekrarnın Kontrast / parlaklık değerlerini değiştirir
*/
void mouseDragged() {
Kontrast_degeri = (int) map( mouseX, 0, width, -128, 128 );
Parlaklik_degeri = (int) map( mouseY, 0, width, -128, 128 );
}
