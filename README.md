# I2C-Protocol

Controller - Peripheral communication using I2C protocol, in Verilog.
# Simulation
  ![Demo](./docs/demo1.png)
+ Enable signal is set high for 5ns;
+ START condition by pulling SDA low while SCL is high;
+ Sending addres 'b1100110 with rw bit set through SDA;
+ Slave (Peripheral) device compares its address, then sends ACK bit;
+ Master (Controller) receives ACK, continues SCL and reads SDA;
+ Slave device starts transmitting data byte 'b11100011 = 'hE3;
+ Master device read  and store data byte, and sends ACK;
+ Master executes STOP condition.
