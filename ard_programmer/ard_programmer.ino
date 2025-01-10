#define CLK_PIN 13
#define EN_PIN 12
#define DATA_PIN 11

#define TTO_BOARD_RESET 10

#define I2_PIN 2
#define I3_PIN 3
#define O3_PIN 4

//#define PROGRAM_MODE

// Data!
const char* bitstream_c = "0100000000000000000000100000000000000000000100000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000001000000000001000000000001000000000001000000000001000000";
//const uint8_t bitstream[] PROGMEM = {0x08, 0x00, 0x02, 0x30, 0x00, 0x05, 0x80, 0x08, 0x0C, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x00, 0x80, 0x08, 0x00, 0xC0};
const uint8_t bitstream_bit_len = 231;
uint8_t bit_counter = 0;

int i2_val;
int i3_val;

void setup() 
{
  // put your setup code here, to run once:

  i2_val = 1;
  i3_val = 0;

  Serial.begin(9600);

  while (!Serial) {
        ; // wait for serial port to connect. Needed for native USB
  }

  Serial.println("Serial is running");

  Serial.println("Type '1' to start");
  // Hacky: Block until a 1 is sent
  int do_run = -1;
  while (do_run != 49) // 49 is '1' in ASCII 
  {
    do_run = Serial.read();
    //Serial.println(do_run);
    delay(100);
  }

  Serial.println("Starting!");
  delay(1000);

  // enable pin (Output)
  pinMode(EN_PIN, OUTPUT);

  // clock pin (Output)
  pinMode(CLK_PIN, OUTPUT);

  // data pin (Output)
  pinMode(DATA_PIN, OUTPUT);

  // Reset board before reset
  pinMode(TTO_BOARD_RESET, OUTPUT);

  pinMode(I2_PIN, INPUT);
  pinMode(I3_PIN, INPUT);
  pinMode(O3_PIN, OUTPUT);

  // Initial pin states
  digitalWrite(EN_PIN, LOW);
  digitalWrite(CLK_PIN, LOW);
  //---

  // Reset board
  digitalWrite(TTO_BOARD_RESET, HIGH);
  delay(100);
  digitalWrite(TTO_BOARD_RESET, LOW);
  delay(100);
  digitalWrite(TTO_BOARD_RESET, HIGH);

  // write all 0s into SR!
  int init_i = 0;
  for (init_i = 0; init_i < bitstream_bit_len+50; init_i++) 
  {
    send_bit_str(0);
  }

  // PROGRAM PAL
  int b_i = 0;
  // program the PAL
  /*for (b_i = 0; b_i < sizeof(bitstream); b_i++) 
  {
    send_byte(bitstream[b_i]);

    //Serial.println("Read from bitstream array:");
    //Serial.println(bitstream[b_i]);
  }*/
  for (b_i = 0; b_i < bitstream_bit_len; b_i++) 
  {
    //send_bit_str(bitstream_c[230-b_i]);
    send_bit_str(bitstream_c[b_i]);
  }

  digitalWrite(CLK_PIN, LOW);
  digitalWrite(EN_PIN, HIGH);

  Serial.println("Programming done!");

  // Strobe enable pin
  /*delay(100);
  digitalWrite(EN_PIN, LOW);
  delay(100);*/

}

void loop() 
{
  /*
  // Apply a stimuli
  digitalWrite(I2_PIN, i2_val);

  // toggle between 0 and 1
  i3_val = (i3_val == 1) ? 0 : 1;

  digitalWrite(I3_PIN, i3_val);
  
  uint8_t result;
  result = digitalRead(O3_PIN);

  // Read output
  Serial.println("I2:");
  Serial.println(i2_val);

  Serial.println("I3:");
  Serial.println(i3_val);

  Serial.println("O3:");
  Serial.println(result);

  // wait some time
  delay(5000);
  */
}

void send_byte(uint8_t byte_value) 
{
  // -
  Serial.print("Byte: ");
  Serial.print(byte_value, HEX);
  Serial.print("\n");
  // -

  // mask byte
  uint8_t byte_mask = 0;
  uint8_t temp_bit_val = 0;

  int i;
  for (i = 0; i < 8; i++) 
  {
    // adjust mask
    byte_mask = 0 | (1 << i);

    //Serial.println("byte mask:");
    //Serial.println(byte_mask);

    // get bit
    temp_bit_val = byte_value & byte_mask;

    // send bit
    send_bit(temp_bit_val);
  }
}

// Bit value assumed to be only either 0 or 1!
void send_bit(uint8_t bit_value) 
{
  if (bit_counter < bitstream_bit_len) 
  {
    //-
  Serial.print("TX Bit: ");
  Serial.print(bit_value);
  Serial.print("\n");
  //-

  digitalWrite(DATA_PIN, bit_value);

  // toggle clock
  // (design reacts to rising edges?)
  digitalWrite(CLK_PIN, HIGH); 
  delay(10);            
  digitalWrite(CLK_PIN, LOW);  
  delay(10);

  bit_counter++;
  }
}

void send_bit_str(char bit_value) 
{
  if (bit_counter < bitstream_bit_len) 
  {
    //-
  Serial.println(bit_counter);
  Serial.print("TX Bit: ");
  Serial.print(bit_value);
  Serial.print("\n");
  //-

  if (bit_value == '0') 
  {
    digitalWrite(DATA_PIN, LOW);
  }
  else
  {
    digitalWrite(DATA_PIN, HIGH);
  }

  // toggle clock
  // (design reacts to rising edges?)
  digitalWrite(CLK_PIN, LOW); // unneccessary...
  #10
  digitalWrite(CLK_PIN, HIGH);
  delay(10);            
  digitalWrite(CLK_PIN, LOW);  
  delay(10);

  bit_counter++;
  }
}
