

/* data_len is the length of the data arrays. */
#define data_len 8

const int latchPin = 12; //Pin connected to latch pin (ST_CP) of 74HC595
const int clockPin = 11; //Pin connected to clock pin (SH_CP) of 74HC595
const int dataPin = 10; //Pin connected to Data in (DS) of 74HC595

const int msgeq7_analog = 14;
const int msgeq7_strobe = 9;
const int msgeq7_reset = 3;

int spectrumValue[7];
#define ARM_MATH_CM4

byte data[data_len] = {1,1,1,1,1,1,1,1};
byte dataInv[data_len] = {1,1,1,1,1,1,1,1};

void setup() {

  // MSGEQ7 chip stuff
  pinMode(msgeq7_reset, OUTPUT);
  pinMode(msgeq7_strobe, OUTPUT);
  pinMode(msgeq7_analog, INPUT);
  analogReference(DEFAULT);
  
  digitalWrite(msgeq7_reset, LOW);
  digitalWrite(msgeq7_strobe, HIGH);

  

  // SHIFT REGISTER STUFF
  pinMode(latchPin, OUTPUT);
  Serial.begin(9600);
  
  /* randomSeed(analogRead(1)); */
  clear_arrs();
  
  blinkAll_2Bytes(2,500); 
}


void msgeq7_loop(){
  Serial.println("---");
 digitalWrite(msgeq7_reset, HIGH);
 digitalWrite(msgeq7_reset, LOW);

 for (int i = 0; i < 7; i++)
 {
   digitalWrite(msgeq7_strobe, LOW);
   delayMicroseconds(30); // to allow the output to settle
   spectrumValue[i] = analogRead(msgeq7_analog);
   
   // comment out/remove the serial stuff to go faster
   // - its just here for show
   if (spectrumValue[i] < 10)
     {
       Serial.print(" <10 ");
       Serial.print(spectrumValue[i]);
     }
   else if (spectrumValue[i] < 100 )
     {
       Serial.print(" <100 ");
       Serial.print(spectrumValue[i]);
     }
   else
     {
       Serial.print(" ");
       Serial.print(spectrumValue[i]);
     }
   
   digitalWrite(msgeq7_strobe, HIGH);
 }
 Serial.println();
}



/* void shift_arr(boolean posx, boolean posy){ */
/*   dataArrayRED[posx] = dataArrayRED[posx] << 1; */
/*   dataArrayGREEN[posy] =   dataArrayGREEN[posy] << 1; */
/* } */


void clear_arrs(){
  int i =0;
  for(i=0; i<data_len; i++){
    data[i] = 0;
    dataInv[i]= 0;
  }
}

void set_x_y(int x, int y){
  char m = 1;
  m = m << x;
  // might need to put 1 in data[y]
  data[y] = (m | data[y]);
  dataInv[y] = (data[y] ^ 255); // inverts it.

}

int delay_time = 30;

void loop(){
  //  test_all();
  random_test_1();
}

void random_test(){
  clear_arrs();


  int random_passes = random(0,64);
  int i = 0;
  for(i=0; i<random_passes; i++){
    int randx = random(0, 7);
    int randy = random(0, 7);
    set_x_y(randx,randy);
  }


 for (int j = 0; j < data_len; j++) {
    set( data[j],dataInv[j]);
    delay(delay_time);
  }
  for (int j = data_len; j > 0; j--) {
    set( data[j],dataInv[j]);
    delay(delay_time);
  }

}

void random_test_1(){
  delay_time = 100;
  clear_arrs();


  int random_passes = 10;//random(1,1);
  int i = 0;
  for(i=0; i<random_passes; i++){
    int randx = random(0, 7);
    int randy = random(0, 7);
    set_x_y(randx,randy);
  }


 for (int j = 0; j < data_len; j++) {
    set( data[j],dataInv[j]);
    delay(delay_time);
  }
  for (int j = data_len; j > 0; j--) {
    set( data[j],dataInv[j]);
    delay(delay_time);
  }

}




void test_all(){
  int i =0;
  for(int y = 0; y<8; y++){
      clear_arrs();
    for(int x=0;x<8;x++){

      set_x_y(x,y);
    
    
    
    for (int j = 0; j < data_len; j++) {
      set( data[j],dataInv[j]);
      delay(delay_time);
    }
    /* for (int j = data_len; j > 0; j--) { */
    /*   set( data[j],dataInv[j]); */
    /*   delay(delay_time); */
    /* } */
    }
  }

}



void set(byte x, byte y){
  digitalWrite(latchPin, 0);
  shiftOut(dataPin, clockPin, x);   
  shiftOut(dataPin, clockPin, y);
  //return the latch pin high to signal chip that it 
  //no longer needs to listen for information
  digitalWrite(latchPin, 1);
}

// the heart of the program
void shiftOut(int myDataPin, int myClockPin, byte myDataOut) {
  // This shifts 8 bits out MSB first, 
  //on the rising edge of the clock,
  //clock idles low

  //internal function setup
  int i=0;
  int pinState;
  pinMode(myClockPin, OUTPUT);
  pinMode(myDataPin, OUTPUT);

  //clear everything out just in case to
  //prepare shift register for bit shifting
  digitalWrite(myDataPin, 0);
  digitalWrite(myClockPin, 0);

  //for each bit in the byte myDataOut�
  //NOTICE THAT WE ARE COUNTING DOWN in our for loop
  //This means that %00000001 or "1" will go through such
  //that it will be pin Q0 that lights. 
  for (i=7; i>=0; i--)  {
    digitalWrite(myClockPin, 0);

    //if the value passed to myDataOut and a bitmask result 
    // true then... so if we are at i=6 and our value is
    // %11010100 it would the code compares it to %01000000 
    // and proceeds to set pinState to 1.
    if ( myDataOut & (1<<i) ) {
      pinState= 1;
    }
    else {	
      pinState= 0;
    }

    //Sets the pin to HIGH or LOW depending on pinState
    digitalWrite(myDataPin, pinState);
    //register shifts bits on upstroke of clock pin  
    digitalWrite(myClockPin, 1);
    //zero the data pin after shift to prevent bleed through
    digitalWrite(myDataPin, 0);
  }

  //stop shifting
  digitalWrite(myClockPin, 0);
}


//blinks the whole register based on the number of times you want to 
//blink "n" and the pause between them "d"
//starts with a moment of darkness to make sure the first blink
//has its full visual effect.
void blinkAll_2Bytes(int n, int d) {
  digitalWrite(latchPin, 0);
  shiftOut(dataPin, clockPin, 0);
  shiftOut(dataPin, clockPin, 0);
  digitalWrite(latchPin, 1);
  delay(200);
  for (int x = 0; x < n; x++) {
    digitalWrite(latchPin, 0);
    shiftOut(dataPin, clockPin, 255);
    shiftOut(dataPin, clockPin, 255);
    digitalWrite(latchPin, 1);
    delay(d);
    digitalWrite(latchPin, 0);
    shiftOut(dataPin, clockPin, 0);
    shiftOut(dataPin, clockPin, 0);
    digitalWrite(latchPin, 1);
    delay(d);
  }
}
